"""Optional Pydantic support for generated configuration snapshots.

This module is safe to import when Pydantic is not installed. Generated
configuration modules subclass :data:`PydanticBaseModel`, then call
``require_pydantic`` immediately before constructing a snapshot. That keeps
the core Configurator runtime dependency-free while still producing real
Pydantic models when the optional extra is installed.
"""

from __future__ import annotations

from typing import Any


class PydanticUnavailableError(RuntimeError):
    """Raised when a generated snapshot is used without Pydantic 2."""


_INSTALL_MESSAGE = (
    "Pydantic snapshots require Pydantic 2. Install the optional dependency "
    "with `pip install 'configurator-python[pydantic]'`."
)

try:
    from pydantic import BaseModel as _BaseModel
    from pydantic import ConfigDict as _ConfigDict

    if not hasattr(_BaseModel, "model_validate"):
        raise ImportError("Configurator Pydantic snapshots require Pydantic 2")
except (ImportError, ModuleNotFoundError) as error:
    PYDANTIC_AVAILABLE = False
    _PYDANTIC_IMPORT_ERROR: BaseException | None = error

    class PydanticBaseModel:
        """Placeholder that delays the optional-dependency error until use."""

        def __init__(self, **_values: Any) -> None:
            require_pydantic()

    def PydanticConfigDict(**values: Any) -> dict[str, Any]:
        """Return inert model configuration when Pydantic is unavailable."""

        return values

else:
    PYDANTIC_AVAILABLE = True
    _PYDANTIC_IMPORT_ERROR = None
    PydanticBaseModel = _BaseModel
    PydanticConfigDict = _ConfigDict


def require_pydantic() -> None:
    """Raise an actionable error unless compatible Pydantic is installed."""

    if not PYDANTIC_AVAILABLE:
        raise PydanticUnavailableError(_INSTALL_MESSAGE) from _PYDANTIC_IMPORT_ERROR


__all__ = [
    "PYDANTIC_AVAILABLE",
    "PydanticBaseModel",
    "PydanticConfigDict",
    "PydanticUnavailableError",
    "require_pydantic",
]
