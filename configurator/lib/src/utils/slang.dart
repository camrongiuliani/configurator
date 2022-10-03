import 'package:configurator/src/models/yaml_i18n_string.dart';
import 'package:slang/builder/builder/raw_config_builder.dart';
import 'package:slang/builder/generator_facade.dart';
import 'package:slang/builder/model/i18n_locale.dart';
import 'package:slang/builder/model/raw_config.dart';
import 'package:slang/builder/model/translation_map.dart';
import 'package:slang/builder/utils/regex_utils.dart';

class SlangUtil {

  static Future<String> generateTranslations({
    required Map<String, dynamic> rawConfig,
    required List<YamlI18n> i18nNodes,
    required bool verbose,
    Stopwatch? stopwatch,
    bool statsMode = false,
  }) async {

    RawConfig config = RawConfigBuilder.fromMap( rawConfig );

    final translationMap = await _buildTranslationMap(
      rawConfig: config,
      i18nNodes: i18nNodes,
      verbose: verbose,
    );

    final result = GeneratorFacade.generate(
      rawConfig: config,
      baseName:'i18n.dart',
      translationMap: translationMap,
    );

    final String output = result.joinAsSingleOutput();

    final parts = output.split( '\n' );

    parts.removeWhere((e) => e.startsWith('import'));
    parts.removeWhere((e) => e.startsWith('export'));

    return parts.join('\n');
  }

  static Future<TranslationMap> _buildTranslationMap({
    required RawConfig rawConfig,
    required List<YamlI18n> i18nNodes,
    required bool verbose,
  }) async {
    final translationMap = TranslationMap();

    Map<String, Map<String, dynamic>> conv = {};

    for (final node in i18nNodes) {
      ( conv[ node.locale ] ??= {}).addAll({
        'name': node.name,
        'value': node.value,
      });
    }

    var base = conv['base']!;

    translationMap.addTranslations(
      locale: rawConfig.baseLocale,
      namespace: 'base',
      translations: base,
    );

    conv.remove( 'base' );

    for (final node in conv.entries) {

      String fileNameNoExtension = 'strings_${node.key}';
      final Map<String, dynamic> translations = node.value;

      final match = RegexUtils.fileWithLocaleRegex.firstMatch(fileNameNoExtension);

      if (match != null) {
        final namespace = match.group(1)!;
        final locale = I18nLocale(
          language: match.group(2)!,
          script: match.group(3),
          country: match.group(4),
        );

        translationMap.addTranslations(
          locale: locale,
          namespace: namespace,
          translations: translations,
        );
      }
    }

    if (translationMap
        .getEntries()
        .every((locale) => locale.key != rawConfig.baseLocale)) {
      if (verbose) {
        print('');
      }
      throw 'Translation file for base locale "${rawConfig.baseLocale.languageTag}" not found.';
    }
    print('k');

    return translationMap;
  }
}