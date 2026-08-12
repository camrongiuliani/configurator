from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
import unittest


sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from configurator import ConfigScope, Configuration  # noqa: E402
from configurator.pydantic_support import (  # noqa: E402
    PYDANTIC_AVAILABLE,
    PydanticBaseModel,
    PydanticConfigDict,
    require_pydantic,
)


FASTAPI_AVAILABLE = importlib.util.find_spec("fastapi") is not None


class FeatureFlagsModel(PydanticBaseModel):
    model_config = PydanticConfigDict(
        frozen=True,
        strict=True,
        extra="forbid",
    )

    checkout_enabled: bool


class ServiceConfigModel(PydanticBaseModel):
    model_config = PydanticConfigDict(
        frozen=True,
        strict=True,
        extra="forbid",
    )

    flags: FeatureFlagsModel


class GeneratedConfigShape:
    """Small equivalent of the generated accessor used by this native test."""

    def __init__(self, configuration: Configuration) -> None:
        self.configuration = configuration

    def snapshot(self) -> ServiceConfigModel:
        require_pydantic()
        return ServiceConfigModel(
            flags=FeatureFlagsModel(
                checkout_enabled=self.configuration.flag("checkoutEnabled"),
            )
        )


@unittest.skipUnless(
    PYDANTIC_AVAILABLE and FASTAPI_AVAILABLE,
    "Pydantic 2 and FastAPI test dependencies are not installed",
)
class FastAPIIntegrationTests(unittest.TestCase):
    def test_dependency_returns_frozen_weighted_response_model(self) -> None:
        from fastapi import Depends, FastAPI
        from fastapi.testclient import TestClient

        runtime = Configuration(
            [
                ConfigScope(
                    name="base",
                    flags={"checkoutEnabled": False},
                ),
                ConfigScope(
                    name="server-override",
                    weight=100,
                    flags={"checkoutEnabled": True},
                ),
            ]
        )
        generated_config = GeneratedConfigShape(runtime)

        def get_config() -> GeneratedConfigShape:
            return generated_config

        app = FastAPI()

        @app.get("/internal/config", response_model=ServiceConfigModel)
        def read_config(
            config: GeneratedConfigShape = Depends(get_config),
        ) -> ServiceConfigModel:
            return config.snapshot()

        response = TestClient(app).get("/internal/config")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {"flags": {"checkout_enabled": True}},
        )


if __name__ == "__main__":
    unittest.main()
