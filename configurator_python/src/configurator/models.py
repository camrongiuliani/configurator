"""Typed data models used by the Configurator runtime."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Generic, Mapping, Sequence, TypeAlias, TypeVar


ImageValue: TypeAlias = str | Sequence[str]
TextStyle: TypeAlias = Mapping[str, Any]
TranslationMap: TypeAlias = Mapping[str, Mapping[str, str]]


class KeyType(str, Enum):
    """The kind of configuration value represented by an access event."""

    FLAG = "flag"
    COLOR = "color"
    IMAGE = "image"
    IMAGE_LIST = "imageList"
    ROUTE = "route"
    SIZE = "size"
    PADDING = "padding"
    MARGIN = "margin"
    MISC = "misc"
    TEXT_STYLE = "textStyle"
    TRANSLATION = "string"

    # Keep both names for clarity while serializing the event kind exactly as
    # Dart's KeyType.string value.
    STRING = "string"


@dataclass(slots=True)
class ConfigScope:
    """A named collection of configuration values with a precedence weight.

    Mapping keys are never normalized. In particular, camel-case keys emitted
    by the shared YAML compiler remain camel-case in this runtime.
    """

    name: str
    weight: int = 0
    part_files: Sequence[str] = field(default_factory=tuple)
    flags: Mapping[str, bool] = field(default_factory=dict)
    colors: Mapping[str, str] = field(default_factory=dict)
    images: Mapping[str, ImageValue] = field(default_factory=dict)
    routes: Mapping[int, str | None] = field(default_factory=dict)
    sizes: Mapping[str, float] = field(default_factory=dict)
    paddings: Mapping[str, float] = field(default_factory=dict)
    margins: Mapping[str, float] = field(default_factory=dict)
    misc: Mapping[str, Any] = field(default_factory=dict)
    text_styles: Mapping[str, TextStyle] = field(default_factory=dict)
    translations: TranslationMap = field(default_factory=dict)

    @classmethod
    def empty(cls, name: str) -> ConfigScope:
        """Create an empty scope with the supplied name."""

        return cls(name=name)

    def to_dict(self) -> dict[str, Any]:
        """Return a shallow, serializable representation of this scope."""

        return {
            "name": self.name,
            "weight": self.weight,
            "partFiles": list(self.part_files),
            "flags": dict(self.flags),
            "colors": dict(self.colors),
            "images": dict(self.images),
            "routes": dict(self.routes),
            "sizes": dict(self.sizes),
            "paddings": dict(self.paddings),
            "margins": dict(self.margins),
            "misc": dict(self.misc),
            "textStyles": dict(self.text_styles),
            "translations": {
                key: dict(locales) for key, locales in self.translations.items()
            },
        }


# The Dart package exposes a concrete ProxyScope. Python's ConfigScope is
# already concrete, so an alias provides source-level parity without a duplicate type.
ProxyScope = ConfigScope


K = TypeVar("K")
V = TypeVar("V")


@dataclass(frozen=True, slots=True)
class ConfigAccessLog(Generic[K, V]):
    """A successful configuration lookup and the scope that supplied it."""

    type: KeyType
    scope: ConfigScope
    key: K
    value: V


# Compatibility with the Dart model's ConfigKeyLog name.
ConfigKeyLog = ConfigAccessLog
