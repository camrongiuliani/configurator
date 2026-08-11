from __future__ import annotations

import sys
from pathlib import Path
from typing import Any
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from configurator import (  # noqa: E402
    ConfigAccessLog,
    ConfigScope,
    Configuration,
    KeyType,
    ProxyScope,
)


class ConfigurationDefaultsTests(unittest.TestCase):
    def test_empty_configuration_has_one_scope_and_dart_defaults(self) -> None:
        config = Configuration()

        self.assertEqual(len(config.scopes), 1)
        self.assertEqual(config.current_scope_name, config.scopes[0].name)
        self.assertFalse(config.flag("missingFlag"))
        self.assertEqual(config.color("missingColor"), "")
        self.assertEqual(config.image("missingImage"), "")
        self.assertEqual(config.image_list("missingImages"), [])
        self.assertEqual(config.route(404), "")
        self.assertEqual(config.size("missingSize"), 14.0)
        self.assertEqual(config.padding("missingPadding"), 0.0)
        self.assertEqual(config.margin("missingMargin"), 0.0)
        self.assertIsNone(config.misc("missingValue"))
        self.assertEqual(config.text_style("missingStyle"), {})
        self.assertEqual(config.translations("missingString"), {})

    def test_proxy_scope_is_the_concrete_scope_type(self) -> None:
        scope = ProxyScope(name="proxy")

        self.assertIsInstance(scope, ConfigScope)


class ConfigurationLookupTests(unittest.TestCase):
    def test_all_value_kinds_are_available(self) -> None:
        translations = {
            "welcomeTitle": {"en_us": "Welcome", "de_de": "Willkommen"},
            "goodbyeTitle": {"en_us": "Goodbye"},
        }
        scope = ConfigScope(
            name="complete",
            flags={"newCheckout": True},
            colors={"brandPrimary": "#123456"},
            images={
                "heroImage": "hero.png",
                "galleryImages": ["one.png", "two.png"],
            },
            routes={7: "/checkout"},
            sizes={"bodyText": 16},
            paddings={"cardInset": 12.5},
            margins={"pageMargin": 24},
            misc={"retryCount": 3},
            text_styles={"bodyStyle": {"fontSize": 16, "fontWeight": 500}},
            translations=translations,
        )
        config = Configuration([scope])

        self.assertTrue(config.flag("newCheckout"))
        self.assertEqual(config.color("brandPrimary"), "#123456")
        self.assertEqual(config.image("heroImage"), "hero.png")
        self.assertEqual(config.image_list("heroImage"), ["hero.png"])
        self.assertEqual(
            config.image_list("galleryImages"), ["one.png", "two.png"]
        )
        self.assertEqual(config.route(7), "/checkout")
        self.assertEqual(config.size("bodyText"), 16.0)
        self.assertEqual(config.padding("cardInset"), 12.5)
        self.assertEqual(config.margin("pageMargin"), 24.0)
        self.assertEqual(config.misc("retryCount"), 3)
        self.assertEqual(
            config.text_style("bodyStyle"),
            {"fontSize": 16, "fontWeight": 500},
        )
        self.assertIs(config.translations("welcomeTitle"), translations)
        self.assertIs(config.current_translations("welcomeTitle"), translations)

    def test_higher_weight_wins_even_when_inserted_earlier(self) -> None:
        high = ConfigScope(name="high", weight=10, colors={"brand": "high"})
        low = ConfigScope(name="low", weight=1, colors={"brand": "low"})

        config = Configuration([high, low])

        self.assertEqual(config.color("brand"), "high")

    def test_later_scope_wins_equal_weight_tie(self) -> None:
        first = ConfigScope(name="first", weight=5, colors={"brand": "first"})
        second = ConfigScope(name="second", weight=5, colors={"brand": "second"})

        config = Configuration([first, second])

        self.assertEqual(config.color("brand"), "second")

    def test_camel_case_keys_are_not_normalized(self) -> None:
        config = Configuration(
            [ConfigScope(name="base", flags={"newCheckoutEnabled": True})]
        )

        self.assertTrue(config.flag("newCheckoutEnabled"))
        self.assertFalse(config.flag("new_checkout_enabled"))

    def test_image_list_returns_a_copy(self) -> None:
        source = ["one.png", "two.png"]
        config = Configuration(
            [ConfigScope(name="base", images={"galleryImages": source})]
        )

        result = config.image_list("galleryImages")
        result.append("three.png")

        self.assertEqual(source, ["one.png", "two.png"])


class ConfigurationMutationTests(unittest.TestCase):
    def test_change_subscription_observes_actual_mutations(self) -> None:
        base = ConfigScope(name="base")
        override = ConfigScope(name="override")
        config = Configuration([base])
        observed: list[tuple[str, ...]] = []
        unsubscribe = config.subscribe(
            lambda current: observed.append(tuple(s.name for s in current.scopes))
        )

        self.assertTrue(config.push_scope(override))
        self.assertFalse(config.push_scope(override))
        self.assertIs(config.pop_scope(), override)
        self.assertIsNone(config.pop_scope())
        unsubscribe()
        unsubscribe()
        config.push_scope(ConfigScope(name="ignored"))

        self.assertEqual(observed, [("base", "override"), ("base",)])

    def test_subscribe_can_emit_current_value(self) -> None:
        config = Configuration([ConfigScope(name="base")])
        observed: list[str] = []

        config.subscribe(
            lambda current: observed.append(current.current_scope_name),
            emit_current=True,
        )

        self.assertEqual(observed, ["base"])

    def test_pop_scope_until_stops_at_matching_scope(self) -> None:
        base = ConfigScope(name="base")
        middle = ConfigScope(name="middle")
        latest = ConfigScope(name="latest")
        config = Configuration([base, middle, latest])

        removed = config.pop_scope_until(lambda scope: scope.name == "middle")

        self.assertEqual(removed, (latest,))
        self.assertEqual(config.scopes, (base, middle))

    def test_bulk_remove_preserves_non_empty_invariant(self) -> None:
        first = ConfigScope(name="first")
        second = ConfigScope(name="second")
        config = Configuration([first, second])

        removed = config.remove_scope_where(lambda _scope: True)

        self.assertEqual(removed, (first, second))
        self.assertEqual(len(config.scopes), 1)
        self.assertNotIn(config.current_scope_name, {"first", "second"})

    def test_remove_last_scope_where_removes_latest_match(self) -> None:
        first = ConfigScope(name="match")
        middle = ConfigScope(name="middle")
        latest = ConfigScope(name="match")
        config = Configuration([first, middle, latest])

        removed = config.remove_last_scope_where(lambda scope: scope.name == "match")

        self.assertIs(removed, latest)
        self.assertEqual(config.scopes, (first, middle))

    def test_notify_false_suppresses_mutation_event(self) -> None:
        config = Configuration([ConfigScope(name="base")])
        observed: list[str] = []
        config.subscribe(lambda current: observed.append(current.current_scope_name))

        config.push_scope(ConfigScope(name="quiet"), notify=False)
        config.pop_scope(notify=False)

        self.assertEqual(observed, [])


class ConfigurationAccessEventTests(unittest.TestCase):
    def test_access_events_identify_winning_scope_and_returned_value(self) -> None:
        low = ConfigScope(name="low", weight=1, colors={"brand": "low"})
        high = ConfigScope(
            name="high",
            weight=10,
            colors={"brand": "high"},
            paddings={"cardInset": 8},
        )
        config = Configuration([low, high])
        events: list[ConfigAccessLog[Any, Any]] = []
        unsubscribe = config.subscribe_access(events.append)

        self.assertEqual(config.color("brand"), "high")
        self.assertEqual(config.padding("cardInset"), 8.0)
        self.assertEqual(config.color("missing"), "")
        unsubscribe()
        unsubscribe()
        config.color("brand")

        self.assertEqual(len(events), 2)
        self.assertEqual(events[0].type, KeyType.COLOR)
        self.assertIs(events[0].scope, high)
        self.assertEqual(events[0].key, "brand")
        self.assertEqual(events[0].value, "high")
        self.assertEqual(events[1].type, KeyType.PADDING)
        self.assertEqual(events[1].value, 8.0)

    def test_translation_event_uses_translation_type(self) -> None:
        translations = {"welcomeTitle": {"en_us": "Welcome"}}
        config = Configuration(
            [ConfigScope(name="base", translations=translations)]
        )
        events: list[ConfigAccessLog[Any, Any]] = []
        config.subscribe_access(events.append)

        config.translations("welcomeTitle")

        self.assertEqual(events[0].type, KeyType.TRANSLATION)
        self.assertEqual(KeyType.STRING, KeyType.TRANSLATION)
        self.assertEqual(events[0].type.value, "string")


if __name__ == "__main__":
    unittest.main()
