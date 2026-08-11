import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';

/// An abstract class representing a configuration scope.
///
/// A configuration scope is a container for various types of configuration values,
/// including flags, colors, images, text styles, routes, and translations. Scopes
/// can be stacked to create a hierarchical configuration system where values in
/// higher-weight scopes override those in lower-weight scopes.
///
/// Example usage:
/// ```dart
/// final baseScope = ConfigScope.empty(name: 'base');
/// final overrideScope = ConfigScope.fromYaml('''
///   name: override
///   weight: 1
///   colors:
///     primary: "#FF0000"
/// ''');
/// ```
abstract class ConfigScope {
  /// The name of this configuration scope
  abstract final String name;

  const ConfigScope();

  /// List of YAML files that are part of this scope
  final List<String> partFiles = const [];

  /// The weight of this scope (used for precedence)
  final int weight = 0;

  /// Map of boolean flag settings
  final Map<String, bool> flags = const {};

  /// Map of image asset settings
  final Map<String, dynamic> images = const {};

  /// Map of miscellaneous settings
  final Map<String, dynamic> misc = const {};

  /// Map of color settings
  final Map<String, String> colors = const {};

  /// Map of size settings
  final Map<String, double> sizes = const {};

  /// Map of padding settings
  final Map<String, double> padding = const {};

  /// Map of margin settings
  final Map<String, double> margins = const {};

  /// Map of border radius settings
  final Map<String, double> radius = const {};

  /// Map of text style configurations
  final Map<String, dynamic> textStyles = const {};

  /// Map of route configurations
  final Map<int, String?> routes = const {};

  /// Map of string translations
  final Map<String, Map<String, String>> translations = const {};

  /// Creates an empty configuration scope with the given name.
  ///
  /// Parameters:
  /// * [name] - The name of the scope
  /// Returns:
  /// * A new empty configuration scope
  static ConfigScope empty({required String name}) {
    return ProxyScope(name: name);
  }

  /// Creates a configuration scope from a YAML string.
  ///
  /// This method parses the YAML string and creates a configuration scope
  /// containing all the values defined in the YAML.
  ///
  /// Parameters:
  /// * [yamlString] - The YAML string to parse
  /// Returns:
  /// * A new configuration scope containing the parsed values
  static ConfigScope fromYaml(String yamlString) {
    final YamlConfiguration config = YamlParser.fromYamlString(yamlString);

    return ProxyScope(
      name: config.name,
      partFiles: config.partFiles,
      weight: config.weight,
      flags: {for (var e in config.flags) e.name: e.value},
      images: {for (var e in config.images) e.name: e.value},
      misc: {for (var e in config.misc) e.name: e.value},
      textStyles: {for (var e in config.textStyles) e.key: e.toJson()},
      routes: {for (var e in config.routes) e.id: e.path},
      sizes: {for (var e in config.sizes) e.name: e.value},
      padding: {for (var e in config.padding) e.name: e.value},
      margins: {for (var e in config.margins) e.name: e.value},
      colors: {for (var e in config.colors) e.name: e.value},
      translations: Map.from(
        I18nParser.parse(
          strings: config.resolvedTranslations,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'partFiles': partFiles,
      'weight': weight,
      'flags': {for (var e in flags.entries) e.key: e.value},
      'images': {for (var e in images.entries) e.key: e.value},
      'misc': {for (var e in misc.entries) e.key: e.value},
      'textStyles': {
        for (var e in textStyles.entries)
          e.key: e.value is YamlTextStyle
              ? (e.value as YamlTextStyle).toJson()
              : e.value,
      },
      'sizes': {for (var e in sizes.entries) e.key: e.value},
      'padding': {for (var e in padding.entries) e.key: e.value},
      'margins': {for (var e in margins.entries) e.key: e.value},
      'colors': {for (var e in colors.entries) e.key: e.value},
      'translations': {for (var e in translations.entries) e.key: e.value},
      'routes': {for (var e in routes.entries) e.key: e.value},
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigScope &&
          name == other.name &&
          weight == other.weight &&
          const MapEquality().equals(flags, other.flags) &&
          const ListEquality().equals(partFiles, other.partFiles) &&
          const MapEquality().equals(images, other.images) &&
          const MapEquality().equals(misc, other.misc) &&
          const MapEquality().equals(textStyles, other.textStyles) &&
          const MapEquality().equals(routes, other.routes) &&
          const MapEquality().equals(colors, other.colors) &&
          const MapEquality().equals(padding, other.padding) &&
          const MapEquality().equals(margins, other.margins) &&
          const MapEquality().equals(radius, other.radius) &&
          const MapEquality().equals(translations, other.translations) &&
          const MapEquality().equals(sizes, other.sizes);

  @override
  int get hashCode =>
      name.hashCode ^
      weight.hashCode ^
      flags.hashCode ^
      partFiles.hashCode ^
      images.hashCode ^
      misc.hashCode ^
      textStyles.hashCode ^
      padding.hashCode ^
      margins.hashCode ^
      radius.hashCode ^
      routes.hashCode ^
      colors.hashCode ^
      translations.hashCode ^
      sizes.hashCode;
}
