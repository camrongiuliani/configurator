from __future__ import annotations

import sys
from pathlib import Path
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from configurator.pydantic_support import (  # noqa: E402
    PYDANTIC_AVAILABLE,
    PydanticBaseModel,
    PydanticConfigDict,
    PydanticUnavailableError,
    require_pydantic,
)


class ExampleSnapshot(PydanticBaseModel):
    model_config = PydanticConfigDict(
        frozen=True,
        strict=True,
        extra="forbid",
    )

    enabled: bool


class PydanticSupportTests(unittest.TestCase):
    def test_support_module_is_safe_without_optional_dependency(self) -> None:
        if PYDANTIC_AVAILABLE:
            require_pydantic()
            self.assertTrue(ExampleSnapshot(enabled=True).enabled)
            return

        with self.assertRaisesRegex(
            PydanticUnavailableError,
            r"configurator-python\[pydantic\]",
        ):
            require_pydantic()
        with self.assertRaises(PydanticUnavailableError):
            ExampleSnapshot(enabled=True)

    @unittest.skipUnless(PYDANTIC_AVAILABLE, "Pydantic 2 is not installed")
    def test_models_are_frozen_strict_and_forbid_extra_fields(self) -> None:
        model = ExampleSnapshot(enabled=True)

        self.assertEqual(model.model_dump(), {"enabled": True})
        with self.assertRaises(Exception):
            model.enabled = False
        with self.assertRaises(Exception):
            ExampleSnapshot(enabled=1)
        with self.assertRaises(Exception):
            ExampleSnapshot(enabled=True, unknown="value")


if __name__ == "__main__":
    unittest.main()
