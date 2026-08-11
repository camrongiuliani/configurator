import 'package:configurator/configurator.dart';

/// Types of configuration keys that can be accessed and logged.
///
/// This enum represents the different types of configuration values that can be
/// tracked when accessed through the configuration system.
enum KeyType {
  /// Boolean flag values
  flag,

  /// String values, typically used for translations
  string,

  /// Route identifiers
  route,

  /// Image asset identifiers
  image,

  /// Color values
  color,

  /// Size values (typically in logical pixels)
  size,

  /// Miscellaneous configuration values
  misc,

  /// Text style configurations
  textStyle,
}

/// A log entry representing access to a configuration value.
///
/// This class is used to track and log when configuration values are accessed,
/// including the type of value, the scope it was accessed from, and the actual
/// value retrieved.
///
/// Type parameters:
/// * [K] - The type of the configuration key
/// * [V] - The type of the configuration value
class ConfigKeyLog<K, V> {
  /// The type of configuration value that was accessed
  final KeyType type;

  /// The configuration scope from which the value was retrieved
  final ConfigScope scope;

  /// The key used to access the configuration value
  final K key;

  /// The value that was retrieved from the configuration
  final V value;

  /// Creates a new configuration access log entry.
  ///
  /// Parameters:
  /// * [type] - The type of configuration value accessed
  /// * [scope] - The configuration scope the value was retrieved from
  /// * [key] - The key used to access the value
  /// * [value] - The value that was retrieved
  ConfigKeyLog(this.type, this.scope, this.key, this.value);
}
