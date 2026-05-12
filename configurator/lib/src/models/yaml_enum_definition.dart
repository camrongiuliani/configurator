/// A model class representing an enum definition in a configuration.
///
/// This class stores the name of the enum and its possible values.
class YamlEnumDefinition {
  /// The name of the enum class
  final String name;

  /// The list of possible values for this enum
  final List<String> values;

  /// Creates a new YamlEnumDefinition instance.
  YamlEnumDefinition(this.name, this.values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlEnumDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          values.toString() == other.values.toString();

  @override
  int get hashCode => name.hashCode ^ values.hashCode;
}
