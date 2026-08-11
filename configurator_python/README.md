# Configurator for Python

`configurator-python` is the Python runtime for configuration generated from
Configurator YAML files. It resolves values from a stack of configuration
scopes and uses the same fallback values as the Dart runtime.

The YAML compiler will generate `ConfigScope` data for this package. The
runtime itself deliberately has no third-party dependencies and does not parse
YAML.

## Requirements

- Python 3.10 or newer

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
