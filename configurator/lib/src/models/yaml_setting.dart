/// A generic model class representing a key-value setting loaded from YAML.
///
/// This class is used to represent various types of settings in the configuration,
/// such as flags, colors, sizes, etc. It provides type-safe access to setting
/// values and supports equality comparison.
///
/// Type parameters:
/// * [K] - The type of the setting name/key
/// * [V] - The type of the setting value
///
/// Example usage:
/// ```dart
/// final colorSetting = YamlSetting<String, String>('primary', '#FF0000');
/// final flagSetting = YamlSetting<String, bool>('feature_enabled', true);
/// ```
class YamlSetting<K, V> {
  /// The name/key of this setting
  final K name;

  /// The value of this setting
  final V value;

  /// Creates a new YamlSetting instance.
  ///
  /// Parameters:
  /// * [name] - The name/key of the setting
  /// * [value] - The value of the setting
  YamlSetting(this.name, this.value);

  /// Compares two YamlSetting instances for equality.
  ///
  /// Two instances are considered equal if they have the same name and value.
  ///
  /// Parameters:
  /// * [other] - The object to compare with
  /// Returns:
  /// * `true` if the objects are equal, `false` otherwise
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlSetting &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  /// Returns a hash code for this YamlSetting instance.
  ///
  /// The hash code is computed from the name and value.
  ///
  /// Returns:
  /// * A hash code value for this object
  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}