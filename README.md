# Configurator

<img src="https://raw.githubusercontent.com/camrongiuliani/configurator/1fc199ce30803e86226cb7fb975f352372a6280e/configurator/badge.svg">

A powerful, flexible configuration management package for Flutter applications that enables dynamic theming, internationalization, and feature management through YAML configuration files.

## Purpose

Configurator solves several common challenges in Flutter application development:

1. **Dynamic Theming**: Manage colors, text styles, and other UI elements through configuration rather than hard-coded values
2. **Internationalization**: Handle multi-language support with structured string management
3. **Feature Flags**: Control feature availability through configuration
4. **Route Management**: Define and manage application routes in configuration
5. **Asset Management**: Organize and access images and other assets through configuration
6. **Hierarchical Configuration**: Support multiple configuration layers with different priorities
7. **Configuration Precedence**: Override values based on scope weights
8. **Type-Safe Configuration**: Generate type-safe Dart code from YAML definitions

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
  - YAML to Dart code generation

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  configurator: ^latest_version
  configurator_flutter: ^latest_version  # For Flutter-specific features
```

## Usage

### Configuration Structure

Configurator uses a combination of YAML files to define your configuration:

1. **Main Configuration File** (`*.config.yaml`):
   - Defines the scope ID and parts
   - Contains the main configuration values
   - Can include other configuration files as parts

2. **Definitions File** (`*.defs.yaml`):
   - Contains shared definitions and constants
   - Can be referenced by multiple configuration files
   - Useful for maintaining consistent values across configurations
   - Definitions are resolved at compile time
   - Values can be referenced using the `*` anchor syntax
   - Supports inheritance and composition

3. **Part Files** (`*.config.yaml`):
   - Modular configuration components
   - Can be included in multiple main configurations
   - Merged into the main configuration at compile time
   - Follow the same structure as main configuration files
   - Can reference definitions from the main config's def_source
   - Identified by their config ID in the parts list of other config files

Example YAML structure:
```yaml
# main.config.yaml
id: app_scope
def_source: app_defs
parts:
  - theme_config
  - features_config
  - routes_config

configuration:
  flags:
    isDarkMode: false
  colors:
    primary: *primaryColor  # Reference from definitions
    secondary: *accentColor

# app.defs.yaml
id: app_defs
definitions:
  colors:
    primaryColor: "#0077E6"
    accentColor: "#8DBF22"
  sizes:
    space:
      none: 0.0
      xs: 2.0
      base: 8.0

# theme.config.yaml
id: theme_config
configuration:
  colors:
    background: *backgroundColor
    text: *textColor
  styles:
    heading:
      fontSize: *headingSize
      fontWeight: bold
    body:
      fontSize: *bodySize
      lineHeight: 1.5

# features.config.yaml
id: features_config
configuration:
  flags:
    enableNewUI: true
    showAnalytics: false
  settings:
    maxItems: 100
    refreshInterval: 300

# routes.config.yaml
id: routes_config
configuration:
  paths:
    home: "/"
    profile: "/profile"
    settings: "/settings"
```

### Parts and Definitions in Action

1. **Using Parts for Modular Configuration**:
```yaml
# app.config.yaml
id: app_scope
def_source: app_defs
parts:
  - theme_config
  - features_config
  - routes_config

# The final configuration will include:
# - All values from app.config.yaml
# - All values from theme.config.yaml (referenced by theme_config)
# - All values from features.config.yaml (referenced by features_config)
# - All values from routes.config.yaml (referenced by routes_config)
```

2. **Definitions for Shared Values**:
```yaml
# app.defs.yaml
id: app_defs
definitions:
  colors:
    primaryColor: "#0077E6"
    accentColor: "#8DBF22"
    backgroundColor: "#FFFFFF"
    textColor: "#333333"
  sizes:
    headingSize: 24.0
    bodySize: 16.0
    space:
      none: 0.0
      xs: 2.0
      base: 8.0

# These values can be referenced in any config or part:
configuration:
  colors:
    primary: *primaryColor
    background: *backgroundColor
  styles:
    heading:
      fontSize: *headingSize
```

3. **Part Inheritance and Overrides**:
```yaml
# base_theme.config.yaml
id: base_theme_config
configuration:
  colors:
    primary: *primaryColor
    secondary: *accentColor
  styles:
    default:
      fontSize: *bodySize

# dark_theme.config.yaml
id: dark_theme_config
configuration:
  colors:
    primary: *darkPrimaryColor  # Overrides base theme's primary
    background: *darkBackground
  styles:
    default:
      color: *lightTextColor    # Adds new property

# app.config.yaml
id: app_scope
def_source: app_defs
parts:
  - base_theme_config
  - dark_theme_config    # Values here override base_theme_config
```

4. **Definitions with Inheritance**:
```yaml
# base.defs.yaml
id: base_defs
definitions:
  colors:
    primary: "#0077E6"
    secondary: "#8DBF22"

# extended.defs.yaml
id: extended_defs
definitions:
  colors:
    primary: "#FF0000"    # Overrides base primary
    accent: "#00FF00"     # New color
  sizes:
    large: 24.0
    medium: 16.0

# app.config.yaml
id: app_scope
def_source: extended_defs  # Uses extended definitions
parts:
  - theme_config
```

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

