# Configurator

<img src="https://raw.githubusercontent.com/camrongiuliani/configurator/1fc199ce30803e86226cb7fb975f352372a6280e/configurator/badge.svg">

A configuration compiler and runtime family for Dart, Flutter, Python, and TypeScript, with YAML as the shared source of truth.

## Purpose

Configurator solves several common challenges in Flutter application development:

1. **Dynamic Theming**: Manage colors, text styles, and other UI elements through configuration rather than hard-coded values
2. **Internationalization**: Handle multi-language support with structured string management
3. **Feature Flags**: Control feature availability through configuration
4. **Route Management**: Define and manage application routes in configuration
5. **Asset Management**: Organize and access images and other assets through configuration
6. **Hierarchical Configuration**: Support multiple configuration layers with different priorities
7. **Configuration Precedence**: Override values based on scope weights
8. **Type-Safe Configuration**: Generate type-safe Dart, Python, and TypeScript code from YAML definitions

## Features

- 🎨 **Theme Management**
  - Colors
  - Text styles (with Google Fonts support)
  - Sizes, margins, and padding
  - Custom theme extensions

- 🌍 **Internationalization**
  - Multi-language support
  - String interpolation
  - Rich text support
  - Structured translation organization

- 🚦 **Feature Management**
  - Boolean flags
  - Feature toggles
  - Configuration scopes with weights
  - Value overriding based on precedence

- 🗺️ **Route Management**
  - Route definitions
  - Hierarchical routing
  - Route parameters

- 🖼️ **Asset Management**
  - Image paths
  - Asset collections
  - Dynamic asset loading

- 🔄 **Real-time Updates**
  - Configuration change notifications
  - Hot-reload support
  - Listenable configurations

- ⚖️ **Scope Management**
  - Weight-based precedence
  - Value overriding
  - Hierarchical configuration
  - Scope inheritance

- 🔒 **Type Safety**
  - Generated type-safe accessors
  - Compile-time configuration validation
  - IDE autocompletion support
  - YAML to Dart, Python, and TypeScript code generation

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  configurator: ^1.0.20
  configurator_flutter: ^1.0.20  # For Flutter-specific features
```

## Usage

### Configuration Structure

Configurator reads three kinds of YAML document:

1. A root `*.config.yaml` declares a scope ID and its values.
2. An optional `*.defs.yaml` provides reusable YAML anchors. A configuration
   selects one definitions document with `def_source`.
3. Another `*.config.yaml` can be referenced by ID in `parts` and composed
   into a root configuration.

Definitions are resolved in memory; generation never rewrites the YAML source.
Each part is a separate YAML document, so a part that uses anchors must declare
its own `def_source` (it may select the same definitions ID as the root).

```yaml
# shared.defs.yaml
id: shared
definitions:
  colors:
    brandPrimary: "3366FF"
  flags:
    searchDefault: false
  sizes:
    bodySize: 16
  routes:
    homePath: /
```

```yaml
# base.config.yaml
id: base
def_source: shared
configuration:
  flags:
    searchEnabled: *searchDefault
  colors:
    primary: *brandPrimary
  sizes:
    body: *bodySize
  routes:
    - id: 1
      path: *homePath
  strings:
    en:
      welcome: Welcome
```

```yaml
# app.config.yaml
id: app_scope
def_source: shared
parts:
  - base
configuration:
  flags:
    checkoutEnabled: true
  colors:
    accent: "8DBF22"
```

Parts are applied in their declared order. For a duplicate semantic key, a
later part overrides an earlier part; part values also override values already
present on the root. Missing parts, duplicate IDs, repeated part declarations,
and cycles are reported before any generated output is replaced.

### Multi-language generation

One configuration file can generate native Dart, Python, and TypeScript modules
after parts, definitions, namespaces, and routes have been resolved once:

```bash
dart run configurator --targets=dart,python,typescript
```

For `app.config.yaml`, the generator writes sibling outputs by default:

```text
app.config.dart
app_config.py
app.config.ts
```

Dart remains the default target for backwards compatibility. Targets may also
be supplied individually with repeatable flags such as `--target=python` and
`--target=typescript`. Generated Python modules use the runtime in
`configurator_python`; generated TypeScript modules use the runtime in
`configurator_typescript`.

The YAML remains language-neutral. Native property names follow each language's
conventions while retaining the same canonical configuration keys underneath.

The generated modules export both the resolved scope and typed accessors. For an
`app.config.yaml` whose `id` is `app_scope`:

```python
from configurator import Configuration
from app_config import GENERATED_APP_SCOPE, AppScopeConfig

app = AppScopeConfig(Configuration([GENERATED_APP_SCOPE]))
enabled = app.flags.checkout_enabled
```

```ts
import { Configuration } from "configurator-typescript";
import { AppScopeConfig, generatedAppScope } from "./app.config.js";

const app = new AppScopeConfig(new Configuration([generatedAppScope]));
const enabled = app.flags.checkoutEnabled;
```

The initial runtime packages live in `configurator_python` and
`configurator_typescript`. See [the multi-target contract](docs/multi_target_contract.md)
for the portable behavior and current translation boundary.

They are workspace packages for now. From a consuming project, link them with:

```bash
python -m pip install -e /path/to/configurator/configurator_python
cd /path/to/configurator/configurator_typescript
npm ci
npm run compile
cd /path/to/your/consumer
npm install /path/to/configurator/configurator_typescript
```

Publish-ready GitHub Actions workflows now cover PyPI, npm, pub.dev, and the
native CLI. They can build and validate artifacts on this fork, but registry
uploads and GitHub Releases are hard-gated to `camrongiuliani/configurator`.
Publishing must still wait until rights to the upstream work are confirmed and
the no-license notices and package-specific safeguards are resolved. The
[release checklist](docs/releasing.md) covers the one-time registry setup,
exact tag patterns, protected environments, and consumer verification.

### Codex and Claude skills

The repository also includes a shared `use-configurator` Agent Skill packaged
for both Codex and Claude Code. It can create or update Configurator YAML,
preserve definitions and ordered parts, run the real generator for Dart,
Python, and TypeScript, and verify the resulting modules without hand-editing
generated code.

Both repository-local marketplace catalogs point at the same skills-only
plugin under `plugins/configurator`. See the
[agent plugin guide](docs/agent-plugins.md) for local installation, validation,
upstream marketplace installation, and the remaining public-submission license
gate.

### Standalone executable

Maintainers can also compile the generator into a native executable. From the
repository root:

```bash
cd configurator
dart pub get --enforce-lockfile
dart compile exe \
  -DCONFIGURATOR_VERSION=local \
  bin/configurator.dart \
  -o ../configurator-cli
../configurator-cli --version
```

Run the executable from the directory containing the `*.config.yaml` files:

```bash
/path/to/configurator-cli --targets=dart,python,typescript
```

The executable includes the Dart runtime, so the person running it does not
need Dart installed. Generated Python and TypeScript modules still use their
corresponding Configurator runtime packages. Native downloads are specific to
an operating system and CPU architecture and are currently unsigned. See the
[CLI release pipeline](docs/releasing.md#native-cli-release-pipeline) for the
automated builds, checksums, and current distribution gate.

### Generated Code

The package generates type-safe Dart code from your YAML files. For example, given the above YAML:

```dart
// Generated app.config.dart
class _FlagKeys {
  const _FlagKeys();
  final isDarkMode = 'isDarkMode';
}

class _ColorKeys {
  const _ColorKeys();
  final primary = 'primary';
  final secondary = 'secondary';
}

class AppConfig {
  final Configuration _config;

  AppConfig(this._config);

  // Type-safe accessors
  bool get isDarkMode => _config.flags.isDarkMode;
  String get primaryColor => _config.colors.primary;
  String get secondaryColor => _config.colors.secondary;
}
```

### Real-World Usage

Here's how you might use the configuration in a typical Flutter application:

1. **Basic Configuration Access**:
```dart
// Access configuration values
final config = Config.of(context);
final isEnabled = config.flags.someFeature;
final primaryColor = config.colors.primary;
final title = config.strings.someScreen.title;
```

2. **Internationalization**:
```dart
// Access translations - automatically uses device language
Text(config.strings.welcome);  // Shows "Welcome" in English, "Bienvenue" in French, etc.
Text(config.strings.someScreen.title);  // Automatically uses correct translation
```

3. **Theme Management**:
```dart
// Use colors and styles
Container(
  color: config.colors.background,
  child: Text(
    'Hello',
    style: TextStyle(
      color: config.colors.text,
      fontSize: config.sizes.text,
    ),
  ),
);
```

4. **Conditional UI**:
```dart
// Show different UI based on configuration
Widget build(BuildContext context) {
  final config = Config.of(context);
  
  return switch (config.flags.someFeatureEnabled) {
    true => FeatureEnabledView(),
    false => FeatureDisabledView(),
  };
}
```

5. **Form Configuration**:
```dart
// Configure form fields based on settings
Form(
  child: Column(
    children: [
      if (config.flags.showFieldA) FieldA(),
      if (config.flags.showFieldB) FieldB(),
      // ... other fields
    ],
  ),
);
```

6. **Route Management**:
```dart
// Define and use routes from configuration
final route = config.routes.someRoute;
Navigator.pushNamed(context, route);
```

7. **Custom Widget Configuration**:
```dart
// Create a configurable widget
class CustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Configurator(
      config: Configuration(
        scopes: [
          const GeneratedWidgetConfig(),
        ],
      ),
      builder: (context, config) {
        return Container(
          color: config.colors.primary,
          child: Text(config.strings.widgetTitle),
        );
      },
    );
  }
}
```

8. **Theme Extension**:
```dart
// Extend theme with configuration
class AppTheme {
  static ThemeData of(BuildContext context) {
    return ThemeData.from(
      config: Configuration(
        scopes: [
          const GeneratedAppScope(),
        ],
      ),
    );
  }
}
```

9. **Configuration with Multiple Scopes**:
```dart
// Combine multiple configuration scopes
final config = Configuration(
  scopes: [
    const BaseConfig(),      // Lowest weight
    const OverrideConfig(),  // Higher weight
    const CustomConfig(),    // Highest weight
  ],
);
```

10. **Dynamic Configuration Updates**:
```dart
// Listen for configuration changes
class ConfigurableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Configurator(
      config: Configuration(
        scopes: [const GeneratedConfig()],
      ),
      builder: (context, config) {
        return ValueListenableBuilder(
          valueListenable: config,
          builder: (context, value, child) {
            return Text(config.strings.someValue);
          },
        );
      },
    );
  }
}
```

11. **Configuration with Default Values**:
```dart
// Access configuration with fallback values
final value = config.flags.someFlag ?? false;
final color = config.colors.someColor ?? Colors.black;
final text = config.strings.someText ?? 'Default Text';
```

12. **Pushing Configuration Scopes**:
```dart
// Push a new configuration scope
class OverrideButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = Config.of(context);
    
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: config.colors.primary,  // Uses current primary color
      ),
      onPressed: () {
        // Push a new scope with higher weight
        final overrideScope = ConfigScope.fromYaml('''
          name: override_scope
          weight: 100
          configuration:
            colors:
              primary: '#FF0000'  # Overrides the base primary color
            flags:
              showFeature: true   # Overrides the base flag
            strings:
              welcome: 'Custom Welcome'  # Overrides the base string
        ''');
        
        // The new scope will override values from lower-weight scopes
        Config.of(context).pushScope(overrideScope);
      },
      child: Text('Apply Override'),
    );
  }
}

// Example of how values are overridden:
// Base configuration (weight: 0):
//   colors.primary: '#0000FF'  // Blue
//   flags.showFeature: false
//   strings.welcome: 'Welcome'
//
// After pushing override scope (weight: 100):
//   colors.primary: '#FF0000'  // Red (overrides blue)
//   flags.showFeature: true    // Overridden
//   strings.welcome: 'Custom Welcome'  // Overridden
//
// The button's color behavior:
// 1. Initially, the button uses the base primary color (blue)
// 2. After pushing the override scope, the button automatically updates to use the new primary color (red)
// 3. This happens because the button is wrapped in a Configurator widget that rebuilds when configuration changes
// 4. The new color takes effect immediately because the override scope has a higher weight (100) than the base scope (0)
```

### Best Practices

1. **Scope Organization**: Use weights to control which values take precedence
2. **Value Overriding**: Place override configurations in higher-weight scopes
3. **Scope Hierarchy**: Use multiple scopes to create a clear hierarchy of configuration values
4. **Version Control**: Keep your YAML files in version control
5. **Validation**: Validate configuration files during build time
6. **Documentation**: Document your scope structure and weight assignments
7. **Testing**: Write tests for your configuration logic, including scope precedence tests
8. **Type Safety**: Always use the generated type-safe accessors instead of string keys
9. **Definitions**: Use a definitions file for shared values and constants
10. **Parts**: Break down large configurations into smaller, reusable parts
11. **Context Usage**: Access configuration through `Config.of(context)` in widgets
12. **Feature Flags**: Use flags to control feature availability and UI variations
13. **Internationalization**: Structure translations hierarchically for better organization
14. **Theme Consistency**: Use shared definitions for colors and styles

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
