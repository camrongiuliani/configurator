"""Weighted configuration resolution and event subscriptions."""

from __future__ import annotations

from collections.abc import Callable, Iterable, Mapping, Sequence
from itertools import count
from threading import RLock
from time import time
from typing import Any, TypeAlias, TypeVar, cast

from .models import ConfigAccessLog, ConfigScope, KeyType, TextStyle, TranslationMap


Unsubscribe: TypeAlias = Callable[[], None]
ChangeCallback: TypeAlias = Callable[["Configuration"], None]
AccessCallback: TypeAlias = Callable[[ConfigAccessLog[Any, Any]], None]

K = TypeVar("K")
V = TypeVar("V")
CallbackT = TypeVar("CallbackT", ChangeCallback, AccessCallback)


class Configuration:
    """Resolve configuration values from a weighted stack of scopes.

    A higher weight wins. Scope insertion order breaks weight ties, with the
    later scope taking precedence. The configuration always retains at least
    one scope so `current_scope_name` remains available.
    """

    def __init__(self, scopes: Iterable[ConfigScope] = ()) -> None:
        initial = list(scopes)
        self._scopes: list[ConfigScope] = initial or [self._default_scope()]
        self._lock = RLock()
        self._change_callbacks: dict[int, ChangeCallback] = {}
        self._access_callbacks: dict[int, AccessCallback] = {}
        self._subscription_ids = count()

    @staticmethod
    def _default_scope() -> ConfigScope:
        return ConfigScope.empty(str(int(time() * 1000)))

    @property
    def scopes(self) -> tuple[ConfigScope, ...]:
        """A snapshot of scopes in insertion order."""

        with self._lock:
            return tuple(self._scopes)

    @property
    def current_scope_name(self) -> str:
        """The name of the most recently inserted scope."""

        with self._lock:
            return self._scopes[-1].name

    def push_scope(
        self,
        scope: ConfigScope,
        *,
        check_equality: bool = True,
        notify: bool = True,
    ) -> bool:
        """Append a scope, returning whether the configuration changed."""

        with self._lock:
            if check_equality and scope == self._scopes[-1]:
                return False
            self._scopes.append(scope)

        if notify:
            self.notify_listeners()
        return True

    def pop_scope(self, *, notify: bool = True) -> ConfigScope | None:
        """Remove and return the latest scope, preserving the final scope."""

        with self._lock:
            if len(self._scopes) == 1:
                return None
            removed = self._scopes.pop()

        if notify:
            self.notify_listeners()
        return removed

    def pop_scope_until(
        self,
        predicate: Callable[[ConfigScope], bool],
        *,
        notify: bool = True,
    ) -> tuple[ConfigScope, ...]:
        """Pop scopes until `predicate` accepts the current scope."""

        removed: list[ConfigScope] = []
        with self._lock:
            while len(self._scopes) > 1 and not predicate(self._scopes[-1]):
                removed.append(self._scopes.pop())

        if removed and notify:
            self.notify_listeners()
        return tuple(removed)

    def remove_scope_where(
        self,
        predicate: Callable[[ConfigScope], bool],
        *,
        notify: bool = True,
    ) -> tuple[ConfigScope, ...]:
        """Remove all matching scopes and return them in insertion order."""

        with self._lock:
            matches = [(scope, predicate(scope)) for scope in self._scopes]
            removed = [scope for scope, should_remove in matches if should_remove]
            if not removed:
                return ()
            self._scopes = [
                scope for scope, should_remove in matches if not should_remove
            ]
            if not self._scopes:
                self._scopes.append(self._default_scope())

        if notify:
            self.notify_listeners()
        return tuple(removed)

    def remove_last_scope_where(
        self,
        predicate: Callable[[ConfigScope], bool],
        *,
        notify: bool = True,
    ) -> ConfigScope | None:
        """Remove and return the latest scope accepted by `predicate`."""

        removed: ConfigScope | None = None
        with self._lock:
            for index in range(len(self._scopes) - 1, -1, -1):
                if predicate(self._scopes[index]):
                    removed = self._scopes.pop(index)
                    break
            if removed is None:
                return None
            if not self._scopes:
                self._scopes.append(self._default_scope())

        if notify:
            self.notify_listeners()
        return removed

    def subscribe(
        self,
        callback: ChangeCallback,
        *,
        emit_current: bool = False,
    ) -> Unsubscribe:
        """Subscribe to mutations and return an idempotent unsubscribe callback."""

        subscription_id = self._add_subscription(self._change_callbacks, callback)
        if emit_current:
            callback(self)
        return self._unsubscribe_callback(self._change_callbacks, subscription_id)

    def subscribe_access(self, callback: AccessCallback) -> Unsubscribe:
        """Subscribe to successful value lookups."""

        subscription_id = self._add_subscription(self._access_callbacks, callback)
        return self._unsubscribe_callback(self._access_callbacks, subscription_id)

    def notify_listeners(self) -> None:
        """Notify current change subscribers with this configuration."""

        with self._lock:
            callbacks = tuple(self._change_callbacks.values())
        for callback in callbacks:
            callback(self)

    def flag(self, key: str) -> bool:
        resolved = self._resolve("flags", key)
        if resolved is None:
            return False
        scope, raw = resolved
        value = raw is True
        self._emit_access(KeyType.FLAG, scope, key, value)
        return value

    def color(self, key: str) -> str:
        resolved = self._resolve("colors", key)
        if resolved is None:
            return ""
        scope, value = resolved
        self._emit_access(KeyType.COLOR, scope, key, value)
        return cast(str, value)

    def image(self, key: str) -> str:
        resolved = self._resolve("images", key)
        if resolved is None:
            return ""
        scope, raw = resolved
        value = raw if isinstance(raw, str) else ""
        self._emit_access(KeyType.IMAGE, scope, key, value)
        return value

    def image_list(self, key: str) -> list[str]:
        resolved = self._resolve("images", key)
        if resolved is None:
            return []
        scope, raw = resolved
        if isinstance(raw, str):
            value = [raw]
        elif isinstance(raw, Sequence):
            value = [item for item in raw if isinstance(item, str)]
        else:
            value = []
        self._emit_access(KeyType.IMAGE_LIST, scope, key, value)
        return value

    def route(self, key: int) -> str:
        resolved = self._resolve("routes", key)
        if resolved is None:
            return ""
        scope, raw = resolved
        value = raw if isinstance(raw, str) else ""
        self._emit_access(KeyType.ROUTE, scope, key, value)
        return value

    def size(self, key: str) -> float:
        return self._number("sizes", KeyType.SIZE, key, 14.0)

    def padding(self, key: str) -> float:
        return self._number("paddings", KeyType.PADDING, key, 0.0)

    def margin(self, key: str) -> float:
        return self._number("margins", KeyType.MARGIN, key, 0.0)

    def misc(self, key: str) -> Any:
        resolved = self._resolve("misc", key)
        if resolved is None:
            return None
        scope, value = resolved
        self._emit_access(KeyType.MISC, scope, key, value)
        return value

    def text_style(self, key: str) -> TextStyle:
        resolved = self._resolve("text_styles", key)
        if resolved is None:
            return {}
        scope, value = resolved
        self._emit_access(KeyType.TEXT_STYLE, scope, key, value)
        return cast(TextStyle, value)

    def translations(self, key: str) -> TranslationMap:
        resolved = self._resolve("translations", key)
        if resolved is None:
            return {}
        scope, _ = resolved
        value = scope.translations
        self._emit_access(KeyType.TRANSLATION, scope, key, value)
        return value

    def current_translations(self, key: str) -> TranslationMap:
        """Dart-compatible alias for `translations`."""

        return self.translations(key)

    def _number(
        self,
        mapping_name: str,
        key_type: KeyType,
        key: str,
        default: float,
    ) -> float:
        resolved = self._resolve(mapping_name, key)
        if resolved is None:
            return default
        scope, raw = resolved
        value = float(cast(float, raw))
        self._emit_access(key_type, scope, key, value)
        return value

    def _resolve(self, mapping_name: str, key: K) -> tuple[ConfigScope, Any] | None:
        with self._lock:
            winner: tuple[int, int, ConfigScope, Mapping[Any, Any]] | None = None
            for index, scope in enumerate(self._scopes):
                values = cast(Mapping[Any, Any], getattr(scope, mapping_name))
                if key not in values:
                    continue
                candidate = (scope.weight, index, scope, values)
                if winner is None or candidate[:2] > winner[:2]:
                    winner = candidate

            if winner is None:
                return None
            return winner[2], winner[3][key]

    def _emit_access(
        self,
        key_type: KeyType,
        scope: ConfigScope,
        key: K,
        value: V,
    ) -> None:
        event = ConfigAccessLog(key_type, scope, key, value)
        with self._lock:
            callbacks = tuple(self._access_callbacks.values())
        for callback in callbacks:
            callback(event)

    def _add_subscription(
        self,
        subscriptions: dict[int, CallbackT],
        callback: CallbackT,
    ) -> int:
        with self._lock:
            subscription_id = next(self._subscription_ids)
            subscriptions[subscription_id] = callback
        return subscription_id

    def _unsubscribe_callback(
        self,
        subscriptions: dict[int, Any],
        subscription_id: int,
    ) -> Unsubscribe:
        def unsubscribe() -> None:
            with self._lock:
                subscriptions.pop(subscription_id, None)

        return unsubscribe
