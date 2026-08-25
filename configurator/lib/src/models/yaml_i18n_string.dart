/// A model class representing an internationalized string loaded from YAML.
///
/// This class encapsulates a string value along with its locale and name,
/// allowing for internationalization support in the configuration system.
///
/// Example YAML:
/// ```yaml
/// strings:
///   welcome:
///     en: "Welcome"
///     es: "Bienvenido"
/// ```
class YamlI18n {
  /// The name/key of this internationalized string
  final String name;

  /// The locale code for this string (e.g., 'en', 'es', 'fr')
  final String locale;

  /// The actual string value for this locale
  final dynamic value;

  /// Creates a new YamlI18n instance.
  ///
  /// Parameters:
  /// * [name] - The name/key of the string
  /// * [locale] - The locale code
  /// * [value] - The string value for this locale
  YamlI18n(this.name, this.locale, this.value);

  /// Compares two YamlI18n instances for equality.
  ///
  /// Two instances are considered equal if they have the same name, locale, and value.
  ///
  /// Parameters:
  /// * [other] - The object to compare with
  /// Returns:
  /// * `true` if the objects are equal, `false` otherwise
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlI18n &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          locale == other.locale &&
          value == other.value;

  /// Returns a hash code for this YamlI18n instance.
  ///
  /// The hash code is computed from the name, locale, and value.
  ///
  /// Returns:
  /// * A hash code value for this object
  @override
  int get hashCode => name.hashCode ^ locale.hashCode ^ value.hashCode;
}
