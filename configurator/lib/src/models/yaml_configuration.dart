import 'dart:math';

import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/yaml_enum_definition.dart';
import 'package:configurator/src/models/yaml_enum_setting.dart';

/// A model class representing a complete YAML configuration.
///
/// This class encapsulates all the configuration values that can be defined in a
/// YAML file, including flags, colors, images, text styles, routes, and more.
/// It provides methods to convert between YAML/JSON and Dart objects.
///
/// Example YAML structure:
/// ```yaml
/// name: "app_config"
/// weight: 0
/// partFiles: ["base_config.yaml"]
/// flags:
///   feature_enabled: true
/// colors:
///   primary: "#FF0000"
/// images:
///   logo: "assets/logo.png"
/// textStyles:
///   heading1:
///     color: "#000000"
///     size: 24
/// routes:
///   1: "/home"
/// strings:
///   welcome: "Welcome to the app"
/// ```
class YamlConfiguration {
  /// The name of this configuration
  final String name;

  /// List of YAML files that are part of this configuration
  final List<String> partFiles;

  /// The weight of this configuration (used for precedence)
  final int weight;

  /// List of boolean flag settings
  final List<YamlSetting> flags;

  /// List of color settings
  final List<YamlSetting> colors;

  /// List of image asset settings
  final List<YamlSetting> images;

  /// List of miscellaneous settings
  final List<YamlSetting> misc;

  /// List of size settings
  final List<YamlSetting> sizes;

  /// List of padding settings
  final List<YamlSetting> padding;

  /// List of margin settings
  final List<YamlSetting> margins;

  /// List of text style configurations
  final List<YamlTextStyle> textStyles;

  /// List of route configurations
  final List<YamlRoute> routes;

  /// List of string translations
  final List<YamlI18n> strings;

  /// List of internationalization strings
  final List<YamlI18n> i18n;

  /// List of enum definitions
  final List<YamlEnumDefinition> enumDefinitions;

  /// List of enum settings
  final List<YamlEnumSetting> enums;

  /// Creates a new YamlConfiguration instance.
  ///
  /// Parameters:
  /// * [name] - The name of this configuration
  /// * [weight] - The weight of this configuration (defaults to 0)
  /// * [partFiles] - List of YAML files that are part of this configuration
  /// * [flags] - List of boolean flag settings
  /// * [colors] - List of color settings
  /// * [images] - List of image asset settings
  /// * [misc] - List of miscellaneous settings
  /// * [textStyles] - List of text style configurations
  /// * [sizes] - List of size settings
  /// * [routes] - List of route configurations
  /// * [strings] - List of string translations
  /// * [padding] - List of padding settings
  /// * [margins] - List of margin settings
  /// * [i18n] - List of internationalization strings
  /// * [enumDefinitions] - List of enum definitions
  /// * [enums] - List of enum settings
  YamlConfiguration({
    required this.name,
    this.weight = 0,
    this.partFiles = const [],
    List<YamlSetting>? flags,
    List<YamlSetting>? colors,
    List<YamlSetting>? images,
    List<YamlSetting>? misc,
    List<YamlSetting>? sizes,
    List<YamlSetting>? padding,
    List<YamlSetting>? margins,
    List<YamlTextStyle>? textStyles,
    List<YamlRoute>? routes,
    List<YamlI18n>? strings,
    List<YamlI18n>? i18n,
    List<YamlEnumDefinition>? enumDefinitions,
    List<YamlEnumSetting>? enums,
  })  : this.flags = flags ?? [],
        this.colors = colors ?? [],
        this.images = images ?? [],
        this.misc = misc ?? [],
        this.sizes = sizes ?? [],
        this.padding = padding ?? [],
        this.margins = margins ?? [],
        this.textStyles = textStyles ?? [],
        this.routes = routes ?? [],
        this.strings = strings ?? [],
        this.i18n = i18n ?? [],
        this.enumDefinitions = enumDefinitions ?? [],
        this.enums = enums ?? [];

  /// Converts this YamlConfiguration instance to a JSON map.
  ///
  /// Returns:
  /// * A map containing all the configuration values
  Map<dynamic, dynamic> toJson() {
    return {
      'partFiles': partFiles,
      'weight': weight,
      'flags': { for (var e in flags) e.name: e.value},
      'images': { for (var e in images) e.name: e.value},
      'misc': { for (var e in misc) e.name: e.value},
      'textStyles': { for (var e in textStyles) e.key: e.toJson()},
      'sizes': { for (var e in sizes) e.name: e.value},
      'colors': { for (var e in colors) e.name: e.value},
      'routes': { for (var e in routes) e.id : e.path },
      'strings': { for (var e in strings) e.name : e.value },
      'padding': { for (var e in padding) e.name : e.value },
      'margins': { for (var e in margins) e.name : e.value },
      'enums': { for (var e in enums) e.name : { 'type': e.type, 'value': e.value } },
    };
  }

  operator +( YamlConfiguration t ) {
    misc.removeWhere(( e ) => t.misc.contains( e ));
    misc.addAll( t.misc );

    textStyles.removeWhere(( e ) => t.textStyles.contains( e ));
    textStyles.addAll( t.textStyles );

    padding.removeWhere(( e ) => t.padding.contains( e ));
    padding.addAll( t.padding );

    margins.removeWhere(( e ) => t.margins.contains( e ));
    margins.addAll( t.margins );

    colors.removeWhere(( e ) => t.colors.contains( e ));
    colors.addAll( t.colors );

    sizes.removeWhere(( e ) => t.sizes.contains( e ));
    sizes.addAll( t.sizes );

    images.removeWhere(( e ) => t.images.contains( e ));
    images.addAll( t.images );

    flags.removeWhere(( e ) => t.flags.contains( e ));
    flags.addAll( t.flags );

    routes.removeWhere(( e ) => t.routes.contains( e ));
    routes.addAll( t.routes );

    strings.removeWhere(( e ) => t.strings.contains( e ));
    strings.addAll( t.strings );

    i18n.removeWhere(( e ) => t.i18n.contains( e ));
    i18n.addAll( t.i18n );

    enums.removeWhere(( e ) => t.enums.contains( e ));
    enums.addAll( t.enums );

    enumDefinitions.removeWhere(( e ) => t.enumDefinitions.contains( e ));
    enumDefinitions.addAll( t.enumDefinitions );

    return this;
  }
}