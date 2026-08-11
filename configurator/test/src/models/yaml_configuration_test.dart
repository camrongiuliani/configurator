import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

void main() {
  group('YamlConfiguration.resolvedTranslations', () {
    test('combines strings and i18n entries', () {
      final config = YamlConfiguration(
        name: 'translations',
        strings: [YamlI18n('title', 'en_us', 'Title')],
        i18n: [YamlI18n('title', 'de', 'Titel')],
      );

      expect(
        config.resolvedTranslations
            .map((translation) => translation.value)
            .toList(),
        ['Title', 'Titel'],
      );
    });

    test('deduplicates identical entries across both YAML fields', () {
      final config = YamlConfiguration(
        name: 'translations',
        strings: [YamlI18n('title', 'en_us', 'Title')],
        i18n: [YamlI18n('title', 'en_us', 'Title')],
      );

      expect(config.resolvedTranslations, hasLength(1));
    });

    test('deduplicates structurally identical nested rich values', () {
      final config = YamlConfiguration(
        name: 'translations',
        strings: [
          YamlI18n('title', 'en_us', {
            'rich': [
              'Hello',
              {'emphasis': true},
            ],
          }),
        ],
        i18n: [
          YamlI18n('title', 'en_us', {
            'rich': [
              'Hello',
              {'emphasis': true},
            ],
          }),
        ],
      );

      expect(config.resolvedTranslations, hasLength(1));
    });

    test('rejects conflicting entries across both YAML fields', () {
      final config = YamlConfiguration(
        name: 'translations',
        strings: [YamlI18n('title', 'en_us', 'Title')],
        i18n: [YamlI18n('title', 'en_us', 'Different title')],
      );

      expect(() => config.resolvedTranslations, throwsStateError);
    });
  });

  group('YamlConfiguration.operator +', () {
    YamlTextStyle textStyle(String key, int size) => YamlTextStyle(
          key: key,
          color: '#000000',
          size: size,
          weight: 400,
          height: 1,
          typeface: const {'family': 'Inter'},
        );

    test('later settings replace earlier values with the same name', () {
      final base = YamlConfiguration(
        name: 'base',
        flags: [YamlSetting('shared', false), YamlSetting('baseOnly', true)],
        colors: [YamlSetting('shared', '#000000')],
        images: [YamlSetting('shared', 'base.png')],
        misc: [YamlSetting('shared', 'base')],
        sizes: [YamlSetting('shared', 12.0)],
        padding: [YamlSetting('shared', 4.0)],
        margins: [YamlSetting('shared', 8.0)],
      );
      final later = YamlConfiguration(
        name: 'later',
        flags: [YamlSetting('shared', true), YamlSetting('laterOnly', true)],
        colors: [YamlSetting('shared', '#ffffff')],
        images: [YamlSetting('shared', 'later.png')],
        misc: [YamlSetting('shared', 'later')],
        sizes: [YamlSetting('shared', 16.0)],
        padding: [YamlSetting('shared', 10.0)],
        margins: [YamlSetting('shared', 20.0)],
      );

      final merged = base + later;

      expect(
        {for (final setting in merged.flags) setting.name: setting.value},
        {'baseOnly': true, 'shared': true, 'laterOnly': true},
      );
      expect(merged.colors.single.value, '#ffffff');
      expect(merged.images.single.value, 'later.png');
      expect(merged.misc.single.value, 'later');
      expect(merged.sizes.single.value, 16.0);
      expect(merged.padding.single.value, 10.0);
      expect(merged.margins.single.value, 20.0);
      expect(
        merged.flags.where((setting) => setting.name == 'shared'),
        hasLength(1),
      );
    });

    test('later text styles and routes replace matching semantic keys', () {
      final merged = YamlConfiguration(
            name: 'base',
            textStyles: [textStyle('title', 16), textStyle('body', 12)],
            routes: [
              YamlRoute(1, '/base', const []),
              YamlRoute(2, '/body', const [])
            ],
          ) +
          YamlConfiguration(
            name: 'later',
            textStyles: [textStyle('title', 24)],
            routes: [YamlRoute(1, '/later', const [])],
          );

      expect(
        {for (final style in merged.textStyles) style.key: style.size},
        {'body': 12, 'title': 24},
      );
      expect(
        {for (final route in merged.routes) route.id: route.path},
        {2: '/body', 1: '/later'},
      );
      expect(merged.textStyles, hasLength(2));
      expect(merged.routes, hasLength(2));
    });

    test('translation identity is locale plus name across YAML aliases', () {
      final merged = YamlConfiguration(
            name: 'base',
            strings: [
              YamlI18n('title', 'en', 'Base title'),
              YamlI18n('title', 'de', 'Titel'),
              YamlI18n('body', 'en', 'Body'),
            ],
          ) +
          YamlConfiguration(
            name: 'later',
            i18n: [YamlI18n('title', 'en', 'Later title')],
          );

      expect(
        merged.resolvedTranslations
            .map((translation) => (
                  translation.locale,
                  translation.name,
                  translation.value,
                ))
            .toList(),
        [
          ('de', 'title', 'Titel'),
          ('en', 'body', 'Body'),
          ('en', 'title', 'Later title'),
        ],
      );
      expect(
        merged.resolvedTranslations.where((translation) =>
            translation.locale == 'en' && translation.name == 'title'),
        hasLength(1),
      );
    });

    test('deduplicates repeated semantic keys within the later part', () {
      final merged = YamlConfiguration(
            name: 'base',
            flags: [YamlSetting('shared', false)],
          ) +
          YamlConfiguration(
            name: 'later',
            flags: [
              YamlSetting('shared', false),
              YamlSetting('shared', true),
            ],
          );

      expect(merged.flags, hasLength(1));
      expect(merged.flags.single.value, isTrue);
    });
  });
}
