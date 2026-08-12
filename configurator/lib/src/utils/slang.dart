import 'package:configurator/src/models/yaml_i18n_string.dart';
import 'package:configurator/src/utils/i18n_generator.dart';
import 'package:slang/builder/builder/raw_config_builder.dart';
import 'package:slang/builder/builder/translation_model_builder.dart';
import 'package:slang/builder/model/raw_config.dart';
import 'package:slang/builder/model/translation_map.dart';
import 'package:slang/builder/builder/build_model_config_builder.dart';
import 'package:slang/builder/builder/generate_config_builder.dart';
import 'package:slang/builder/model/i18n_data.dart';

/// A utility class for generating internationalization (i18n) code using the slang package.
///
/// This class provides functionality to generate Dart code for internationalization
/// from YAML configuration and i18n nodes. It uses the slang package to build
/// translation models and generate the final code.
///
/// Example usage:
/// ```dart
/// final translations = SlangUtil.generateTranslations(
///   rawConfig: config,
///   i18nNodes: nodes,
///   verbose: true,
/// );
/// ```
class SlangUtil {
  /// Generates translation code from the given configuration and i18n nodes.
  ///
  /// This method takes a raw configuration map and a list of i18n nodes, and
  /// generates Dart code for internationalization using the slang package.
  ///
  /// Parameters:
  /// * [rawConfig] - The raw configuration map containing i18n settings
  /// * [i18nNodes] - List of YAML i18n nodes containing translations
  /// * [verbose] - Whether to enable verbose logging
  /// * [stopwatch] - Optional stopwatch for timing the generation
  /// * [statsMode] - Whether to run in statistics mode
  ///
  /// Returns:
  /// * A string containing the generated Dart code for translations
  static String generateTranslations({
    required Map<String, dynamic> rawConfig,
    required List<YamlI18n> i18nNodes,
    required bool verbose,
    Stopwatch? stopwatch,
    bool statsMode = false,
  }) {
    RawConfig config = RawConfigBuilder.fromMap(rawConfig);

    final translationMap = _buildTranslationMap(
      rawConfig: config,
      i18nNodes: i18nNodes,
      verbose: verbose,
    );

    final List<I18nData> translationList =
        translationMap.getEntries().map((localeEntry) {
      final locale = localeEntry.key;
      final namespaces = localeEntry.value;
      return TranslationModelBuilder.build(
        buildConfig: config.toBuildModelConfig(),
        map: config.namespaces ? namespaces : namespaces.values.first,
        localeDebug: locale.languageTag,
      ).toI18nData(base: config.baseLocale == locale, locale: locale);
    }).toList();

    final generateConfig = GenerateConfigBuilder.build(
      baseName: 'i18n.dart',
      config: config,
      interfaces: [],
    );

    final map = {
      for (final t in translationList)
        t.locale: generateSlangTranslations(generateConfig, t),
    };

    List<String> resultLines = [];

    if (map.isNotEmpty) {
      for (var entry in map.values) {
        resultLines.add(entry);
      }
    }

    if (resultLines.isNotEmpty) {
      return resultLines.join('\n\n');
    } else {
      return '';
    }
  }

  static TranslationMap _buildTranslationMap({
    required RawConfig rawConfig,
    required List<YamlI18n> i18nNodes,
    required bool verbose,
  }) {
    final translationMap = TranslationMap();

    Map<String, Map<String, dynamic>> conv = {};

    for (final node in i18nNodes) {
      conv[node.locale] ??= {};

      conv[node.locale]![node.name] = node.value;
    }

    if (!conv.containsKey('en_us')) {
      conv['en_us'] = {};
    }

    var base = conv['en_us']!;

    translationMap.addTranslations(
      locale: rawConfig.baseLocale,
      namespace: 'en',
      translations: base,
    );

    conv.remove('en_us');

    // for (final node in conv.entries) {
    //
    //   String fileNameNoExtension = 'strings_${node.key}';
    //   final Map<String, dynamic> translations = node.value;
    //
    //   final match = RegexUtils.fileWithLocaleRegex.firstMatch(fileNameNoExtension);
    //
    //   if (match != null) {
    //     final namespace = match.group(1)!;
    //     final locale = I18nLocale(
    //       language: match.group(2)!,
    //       script: match.group(3),
    //       country: match.group(4),
    //     );
    //
    //     translationMap.addTranslations(
    //       locale: locale,
    //       namespace: namespace,
    //       translations: translations,
    //     );
    //   }
    // }
    //
    // if (translationMap
    //     .getEntries()
    //     .every((locale) => locale.key != rawConfig.baseLocale)) {
    //   throw 'Translation file for base locale "${rawConfig.baseLocale.languageTag}" not found.';
    // }

    return translationMap;
  }
}
