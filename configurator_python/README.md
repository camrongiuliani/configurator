# Configurator for Python

`configurator-python` is the Python runtime for configuration generated from
Configurator YAML files. It resolves values from a stack of configuration
scopes and uses the same fallback values as the Dart runtime.

The YAML compiler will generate `ConfigScope` data for this package. The
runtime itself deliberately has no third-party dependencies and does not parse
YAML.

## Requirements

- Python 3.10 or newer

The runtime has no third-party dependencies:

```shell
pip install configurator-python
```

Install an optional extra when you want generated Pydantic snapshots or
FastAPI integration:

```shell
pip install "configurator-python[pydantic]"
pip install "configurator-python[fastapi]"
```

## Example

```python
from configurator import ConfigScope, Configuration

base = ConfigScope(
    name="base",
    colors={"brandPrimary": "#3366ff"},
    flags={"newCheckout": False},
)
experiment = ConfigScope(
    name="experiment",
    weight=100,
    flags={"newCheckout": True},
)

config = Configuration([base, experiment])

assert config.color("brandPrimary") == "#3366ff"
assert config.flag("newCheckout") is True
```

Keys are passed through unchanged. Generated Python accessors may use
`snake_case`, but their calls into the runtime retain the original camel-case
key, such as `brandPrimary` above.

Higher-weight scopes take precedence. When two scopes have the same weight,
the scope added later wins.

## FastAPI

Generated configuration modules can be loaded once at application startup and
provided to FastAPI routes as a dependency. Given an `app.config.yaml` whose
`id` is `app_scope`, Configurator generates `app_config.py` with
`GENERATED_APP_SCOPE` and `AppScopeConfig`:

```python
from fastapi import Depends, FastAPI

from configurator import Configuration
from app_config import AppScopeConfig, GENERATED_APP_SCOPE


runtime = Configuration([GENERATED_APP_SCOPE])
app_config = AppScopeConfig(runtime)


def get_config() -> AppScopeConfig:
    return app_config


app = FastAPI()


@app.get("/features")
def features(config: AppScopeConfig = Depends(get_config)) -> dict[str, bool]:
    return {"checkoutEnabled": config.flags.checkout_enabled}
```

Keeping one application-level `Configuration` preserves weighted scope
resolution and avoids rebuilding the configuration for every request. If
scopes change at runtime, the generated accessors continue to resolve values
from the current scope stack.

### Generated Pydantic snapshots

The Configurator runtime uses standard Python type annotations and deliberately
has no runtime dependencies. Those annotations provide editor and static type
checking, but Python does not enforce them at runtime.

The generated module also includes nested Pydantic models for every group and
a root model such as `AppScopeConfigModel`. Calling `snapshot()` (or its
`to_model()` alias) resolves every field through the current weighted scope
stack, validates the result, and returns a point-in-time model:

```python
from configurator import ConfigScope, Configuration

from app_config import (
    AppScopeConfig,
    AppScopeConfigModel,
    GENERATED_APP_SCOPE,
)

runtime = Configuration([GENERATED_APP_SCOPE])
config = AppScopeConfig(runtime)

runtime.push_scope(
    ConfigScope(
        name="production",
        weight=100,
        flags={"checkoutEnabled": True},
    )
)

snapshot: AppScopeConfigModel = config.snapshot()
assert snapshot.flags.checkout_enabled is True
```

Generated models are strict, frozen, and reject extra fields. They provide
runtime validation, serialization, JSON Schema, and FastAPI response-model
support without moving scope mutation or precedence behavior into Pydantic.
Create a new snapshot after changing scopes; an existing snapshot remains
immutable and does not change with the runtime.

Generated modules remain importable when Pydantic is not installed, and all
ordinary accessors continue to work. Calling `snapshot()` or constructing a
generated model without the `pydantic` extra raises an error with the required
installation command.

The generated model can be used directly as a FastAPI response model:

```python
from fastapi import Depends

from app_config import AppScopeConfig, AppScopeConfigModel


@app.get("/internal/config", response_model=AppScopeConfigModel)
def read_config(
    config: AppScopeConfig = Depends(get_config),
) -> AppScopeConfigModel:
    return config.snapshot()
```

Only expose configuration values that are safe for clients. Environment
variables and secrets should remain outside the shared YAML; use a dedicated
settings layer such as
[Pydantic Settings](https://docs.pydantic.dev/latest/concepts/pydantic_settings/)
for those values. See FastAPI's
[request-body documentation](https://fastapi.tiangolo.com/tutorial/body/) and
the [Pydantic model documentation](https://docs.pydantic.dev/latest/concepts/models/)
for validation and schema behavior.

## Changes and access events

Subscriptions return an idempotent function that removes the listener:

```python
stop_changes = config.subscribe(lambda current: print(current.current_scope_name))
stop_access = config.subscribe_access(
    lambda event: print(event.type.value, event.key, event.scope.name)
)

config.push_scope(ConfigScope(name="local"))
config.color("brandPrimary")

stop_changes()
stop_access()
```

Access events are emitted only when a key is found in a scope. Missing lookups
return their Dart-compatible fallback without producing an event.

## Default values

| Lookup | Missing value |
| --- | --- |
| `flag` | `False` |
| `color`, `image`, `route` | `""` |
| `image_list` | `[]` |
| `size` | `14.0` |
| `padding`, `margin` | `0.0` |
| `misc` | `None` |
| `text_style`, `translations` | `{}` |

`translations(key)` (also available as `current_translations(key)`) mirrors
the Dart runtime: it selects the highest-precedence scope containing `key` and
returns that scope's complete translation map.

## Tests

The tests run without installing the package:

```shell
python3 -m unittest discover -s tests -v
```

Install the test extra to also exercise real Pydantic validation and the
FastAPI response-model integration:

```shell
pip install -e ".[test]"
python3 -m unittest discover -s tests -v
```

## Release status

This package is currently blocked from PyPI with the
`Private :: Do Not Upload` classifier pending confirmation of rights to the
upstream Configurator work. Do not remove that gate until the repository
license review has been resolved.
