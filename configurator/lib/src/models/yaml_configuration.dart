import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';

void _mergeByKey<T, K>(
  List<T> target,
  Iterable<T> later,
  K Function(T value) keyOf,
) {
  final merged = <K, T>{};

  for (final value in [...target, ...later]) {
    final key = keyOf(value);

    // Reinsert matching keys so the later value also keeps later ordering.
    merged.remove(key);
    merged[key] = value;
  }

  target
    ..clear()
    ..addAll(merged.values);
}

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

  /// Returns the single translation collection used by every output target.
  ///
  /// `strings` is the established YAML field used by existing configurations,
  /// while `i18n` is also accepted by the parser. Identical entries may appear
  /// in both fields, but conflicting values are rejected rather than silently
  /// producing language-specific results.
  List<YamlI18n> get resolvedTranslations {
    final translations = <String, YamlI18n>{};

    for (final translation in [...strings, ...i18n]) {
      final identity = '${translation.locale}\u0000${translation.name}';
      final existing = translations[identity];

      if (existing != null &&
          !const DeepCollectionEquality().equals(
            existing.value,
            translation.value,
          )) {
        throw StateError(
          'Conflicting translation for ${translation.locale}.${translation.name}',
        );
      }

      translations[identity] = translation;
    }

    return List.unmodifiable(translations.values);
  }

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
  YamlConfiguration({
    required this.name,
    this.weight = 0,
    List<String> partFiles = const [],
    List<YamlSetting> flags = const [],
    List<YamlSetting> colors = const [],
    List<YamlSetting> images = const [],
    List<YamlSetting> misc = const [],
    List<YamlTextStyle> textStyles = const [],
    List<YamlSetting> sizes = const [],
    List<YamlRoute> routes = const [],
    List<YamlI18n> strings = const [],
    List<YamlSetting> padding = const [],
    List<YamlSetting> margins = const [],
    List<YamlI18n> i18n = const [],
  })  : partFiles = List.of(partFiles),
        flags = List.of(flags),
        colors = List.of(colors),
        images = List.of(images),
        misc = List.of(misc),
        textStyles = List.of(textStyles),
        sizes = List.of(sizes),
        routes = List.of(routes),
        strings = List.of(strings),
        padding = List.of(padding),
        margins = List.of(margins),
        i18n = List.of(i18n);

  /// Converts this YamlConfiguration instance to a JSON map.
  ///
  /// Returns:
  /// * A map containing all the configuration values
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'partFiles': partFiles,
      'weight': weight,
      'flags': {for (var e in flags) e.name: e.value},
      'images': {for (var e in images) e.name: e.value},
      'misc': {for (var e in misc) e.name: e.value},
      'textStyles': {for (var e in textStyles) e.key: e.toJson()},
      'sizes': {for (var e in sizes) e.name: e.value},
      'colors': {for (var e in colors) e.name: e.value},
      'routes': {for (var e in routes) e.id: e.path},
      // Retain the legacy field while exposing the normalized portable shape.
      'strings': {for (var e in strings) e.name: e.value},
      'translations': I18nParser.parse(strings: resolvedTranslations),
      'padding': {for (var e in padding) e.name: e.value},
      'margins': {for (var e in margins) e.name: e.value},
    };
  }

  YamlConfiguration operator +(YamlConfiguration t) {
    _mergeByKey(misc, t.misc, (setting) => setting.name);
    _mergeByKey(textStyles, t.textStyles, (style) => style.key);
    _mergeByKey(padding, t.padding, (setting) => setting.name);
    _mergeByKey(margins, t.margins, (setting) => setting.name);
    _mergeByKey(colors, t.colors, (setting) => setting.name);
    _mergeByKey(sizes, t.sizes, (setting) => setting.name);
    _mergeByKey(images, t.images, (setting) => setting.name);
    _mergeByKey(flags, t.flags, (setting) => setting.name);
    _mergeByKey(routes, t.routes, (route) => route.id);

    final laterStrings = List<YamlI18n>.of(t.strings);
    final laterI18n = List<YamlI18n>.of(t.i18n);
    final laterTranslationKeys = {
      for (final translation in [...laterStrings, ...laterI18n])
        (translation.locale, translation.name),
    };

    // `strings` and `i18n` are aliases. A later part overrides an earlier
    // translation even when the two parts use different field names.
    strings.removeWhere(
      (translation) => laterTranslationKeys.contains(
        (translation.locale, translation.name),
      ),
    );
    i18n.removeWhere(
      (translation) => laterTranslationKeys.contains(
        (translation.locale, translation.name),
      ),
    );
    _mergeByKey(
      strings,
      laterStrings,
      (translation) => (translation.locale, translation.name),
    );
    _mergeByKey(
      i18n,
      laterI18n,
      (translation) => (translation.locale, translation.name),
    );

    return this;
  }
}
