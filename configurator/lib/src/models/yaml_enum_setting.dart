/// A model class representing an enum setting in a configuration.
///
/// This class links a configuration key to a specific enum type and value.
class YamlEnumSetting {
  /// The key for this setting
  final String name;

  /// The name of the enum type
  final String type;

  /// The current value of this setting (as a string)
  final String value;

  /// Creates a new YamlEnumSetting instance.
  YamlEnumSetting(this.name, this.type, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlEnumSetting &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ type.hashCode ^ value.hashCode;
}
