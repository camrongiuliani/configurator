# configurator

Core weighted configuration runtime and YAML compiler for the Configurator
project. One `*.config.yaml` source can generate type-safe Dart, Python, and
TypeScript configuration modules.

## Install

```yaml
dependencies:
  configurator: ^1.0.20
```

For Flutter-specific colors, text styles, themes, and widgets, also use
`configurator_flutter`.

## Generate configuration

Dart remains the default output:

```sh
dart run configurator
```

Select one or more native targets explicitly:

```sh
dart run configurator --targets=dart,python,typescript
```

For `app.config.yaml`, this writes `app.config.dart`, `app_config.py`, and
`app.config.ts` beside the YAML file. Parts, definitions, namespaces, and
translations are resolved once before target-specific code is emitted.

## Runtime

```dart
import 'package:configurator/configurator.dart';

final config = Configuration(
  scopes: [
    ProxyScope(
      name: 'base',
      flags: {'checkoutEnabled': true},
      colors: {'brandPrimary': '#3366ff'},
    ),
  ],
);

final enabled = config.flag('checkoutEnabled');
final color = config.color('brandPrimary');
```

Higher scope weights win. A later scope wins when weights are equal.

See the
[repository documentation](https://github.com/camrongiuliani/configurator)
for the YAML contract, parts and definitions, generated accessors, and the
Python and TypeScript runtimes.

## Release status

The package is currently unlicensed pending confirmation of rights to the
upstream work, and its pubspec blocks publishing. Do not remove that gate until
the repository license review has been resolved.
