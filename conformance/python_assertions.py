"""Execute assertions against a Configurator-generated Python module."""

from __future__ import annotations

from configurator import ConfigScope, Configuration
from conformance_root_config import (
    GENERATED_CONFORMANCE_ROOT,
    ConformanceRootConfig,
)


def verify_generated_configuration() -> None:
    assert GENERATED_CONFORMANCE_ROOT.weight == 7
    runtime = Configuration([GENERATED_CONFORMANCE_ROOT])
    config = ConformanceRootConfig(runtime)

    # Values from the root survive the part merge.
    assert config.flags.enabled_search is True
    assert runtime.color("rootOnly") == "AABBCC"
    assert config.images.logo == "assets/root-logo.svg"
    assert config.images.gallery == ["assets/one.png", "assets/two.png"]
    assert runtime.route(2) == "/root-only"
    assert config.paddings.screen == 8.0
    assert config.margins.screen == 4.0
    assert config.misc.retry_count == 3
    assert config.misc.labels == ["alpha", "beta"]
    assert config.text_styles.header["typeface"]["family"] == "Inter"

    # The deepest part wins for duplicate semantic keys.
    assert config.flags.shared_flag is True
    assert config.flags.base_only is True
    assert config.flags.deepest_only is True
    assert config.colors.primary == "708090"
    assert runtime.route(1) == "/override"
    assert config.sizes.card_width == 24.0
    assert config.misc.rollout_stage == "override"

    # `strings` and `i18n` produce one normalized translation map. Identical
    # aliases are accepted and the deepest part overrides the root locale.
    translations = config.translations.greeting
    assert translations["greeting"] == {
        "en": "Override hello",
        "es": "Hola",
    }, translations
    assert runtime.current_translations("status")["status"] == {"en": "Ready"}
    assert translations["rootOnly"] == {"en": "Root only"}


def verify_runtime_precedence() -> None:
    low = ConfigScope(name="low", weight=1, flags={"choice": False})
    high = ConfigScope(name="high", weight=5, flags={"choice": True})
    later_tie = ConfigScope(name="later-tie", weight=5, flags={"choice": False})

    runtime = Configuration([low, high])
    assert runtime.flag("choice") is True
    runtime.push_scope(later_tie)
    assert runtime.flag("choice") is False


if __name__ == "__main__":
    verify_generated_configuration()
    verify_runtime_precedence()
    print("Python conformance passed")
