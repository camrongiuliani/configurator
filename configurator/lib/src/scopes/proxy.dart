import 'package:configurator/configurator.dart';

/// A concrete implementation of [ConfigScope] that acts as a proxy for configuration values.
///
/// This class provides a mutable implementation of [ConfigScope] that can be used
/// to create and modify configuration scopes. It's particularly useful when you
/// need to create a scope programmatically or modify an existing scope's values.
///
/// Example usage:
/// ```dart
/// final scope = ProxyScope(
///   name: 'custom',
///   weight: 1,
///   colors: {'primary': '#FF0000'},
///   flags: {'featureEnabled': true},
/// );
/// ```
class ProxyScope extends ConfigScope {

  @override
  final String name;

  @override
  final int weight;

  @override
  final List<String> partFiles;

  @override
  final Map<String, bool> flags;

  @override
  final Map<String, dynamic> images;

  @override
  final Map<int, String> routes;

  @override
  Map<String, String> colors;

  @override
  Map<String, double> sizes;

  @override
  Map<String, double> padding;

  @override
  Map<String, double> margins;

  @override
  Map<String, dynamic> misc;

  @override
  Map<String, dynamic> textStyles;

  @override
  Map<String, Map<String, String>> translations;

  /// Creates a new proxy scope with the given configuration values.
  ///
  /// All parameters are optional and will default to empty collections or zero
  /// values if not provided.
  ///
  /// Parameters:
  /// * [name] - The name of the scope (required)
  /// * [partFiles] - List of YAML files that are part of this scope
  /// * [weight] - The weight of this scope (used for precedence)
  /// * [flags] - Map of boolean flag settings
  /// * [images] - Map of image asset settings
  /// * [routes] - Map of route configurations
  /// * [colors] - Map of color settings
  /// * [sizes] - Map of size settings
  /// * [padding] - Map of padding settings
  /// * [margins] - Map of margin settings
  /// * [misc] - Map of miscellaneous settings
  /// * [textStyles] - Map of text style configurations
  /// * [translations] - Map of string translations
  ProxyScope({
    required this.name,
    this.partFiles = const [],
    this.weight = 0,
    this.flags = const {},
    this.images = const {},
    this.routes = const {},
    this.colors = const {},
    this.sizes = const {},
    this.padding = const {},
    this.margins = const {},
    this.misc = const {},
    this.textStyles = const {},
    this.translations = const {},
  });

}