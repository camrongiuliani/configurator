# configurator_flutter

Flutter adapters for the core `configurator` runtime, including configuration
providers, rebuild-aware widgets, theme helpers, color parsing, text-style
parsing, and Flutter-aware localization.

Requires Flutter 3.29 or newer and Dart 3.7 or newer.

## Install

```yaml
dependencies:
  configurator: ^1.0.20
  configurator_flutter: ^1.0.20
```

## Usage

```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

final configuration = Configuration(
  scopes: [
    ProxyScope(
      name: 'base',
      flags: {'checkoutEnabled': true},
    ),
  ],
);

void main() {
  runApp(
    Configurator(
      config: configuration,
      builder: (context, config) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfigurationProvider.of(context).config;
    return Text("Checkout enabled: ${config.flag('checkoutEnabled')}");
  }
}
```

Use `ConfiguredWidget` when a subtree should rebuild in response to
configuration changes. The core runtime and YAML compiler remain in the
`configurator` package.

See the
[repository documentation](https://github.com/camrongiuliani/configurator)
for generation, scope precedence, and multi-language targets.

## Release status

The package is currently unlicensed pending confirmation of rights to the
upstream work, and its pubspec blocks publishing. Do not remove that gate until
the repository license review has been resolved.
