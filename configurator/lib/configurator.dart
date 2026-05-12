/// A configuration management library for Dart applications.
///
/// This library provides tools for managing hierarchical configuration scopes,
/// allowing for flexible configuration management with different levels of precedence.
/// It supports various types of configuration values including text styles, routes,
/// internationalization strings, and more.
///
/// The main components are:
/// * [Configuration] - The core configuration management class
/// * [ConfigScope] - Represents a single configuration scope
/// * [YamlConfiguration] - Tools for loading configuration from YAML files
library configurator;

/// Text style configuration models and utilities.
export 'src/models/yaml_text_style.dart';

/// Core scope management functionality.
export 'src/scopes/scope.dart';

/// Proxy scope implementation for delegation.
export 'src/scopes/proxy.dart';

/// Main configuration management class.
export 'src/configuration.dart';

/// Configuration parsing utilities.
export 'src/utils/parser.dart';

/// String localization utilities.
export 'src/utils/slang.dart';

/// YAML configuration models and utilities.
export 'src/models/yaml_configuration.dart';

/// Configuration setting models.
export 'src/models/yaml_setting.dart';

/// Route configuration models.
export 'src/models/yaml_route.dart';

/// Internationalization string models.
export 'src/models/yaml_i18n_string.dart';

/// Enum configuration models.
export 'src/models/yaml_enum_definition.dart';
export 'src/models/yaml_enum_setting.dart';
