import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

import '../../bin/config_file.dart';
import '../../bin/part_resolver.dart';

void main() {
  ConfigFile config(
    String id, {
    List<String> parts = const [],
    bool? enabled,
    List<YamlI18n> strings = const [],
    List<YamlI18n> i18n = const [],
  }) {
    return ConfigFile(
      id,
      '/configs',
      YamlConfiguration(
        name: id,
        partFiles: parts,
        flags: [if (enabled != null) YamlSetting('enabled', enabled)],
        strings: strings,
        i18n: i18n,
      ),
    );
  }

  group('resolveConfigurationParts', () {
    test('uses declared order and later parts override earlier parts', () {
      final roots = resolveConfigurationParts([
        config('app', parts: ['first', 'second'], enabled: false),
        config('first', enabled: false),
        config('second', enabled: true),
      ]);

      expect(roots, hasLength(1));
      expect(roots.single.config.name, 'app');
      expect(roots.single.config.flags.single.value, isTrue);
    });

    test('composes a shared part independently into every root', () {
      final roots = resolveConfigurationParts([
        config('firstRoot', parts: ['shared']),
        config('secondRoot', parts: ['shared']),
        config('shared', enabled: true),
      ]);

      expect(roots.map((root) => root.config.name), [
        'firstRoot',
        'secondRoot',
      ]);
      expect(
          roots.every((root) => root.config.flags.single.value == true), true);
      expect(
        identical(roots.first.config.flags, roots.last.config.flags),
        isFalse,
      );
    });

    test('merges strings and i18n aliases across a deep part chain', () {
      final roots = resolveConfigurationParts([
        config(
          'root',
          parts: ['base'],
          strings: [
            YamlI18n('greeting', 'en', 'Root hello'),
            YamlI18n('rootOnly', 'en', 'Root only'),
          ],
        ),
        config(
          'base',
          parts: ['override'],
          i18n: [
            YamlI18n('greeting', 'en', 'Base hello'),
            YamlI18n('greeting', 'es', 'Hola'),
          ],
        ),
        config(
          'override',
          strings: [
            YamlI18n('greeting', 'en', 'Override hello'),
            YamlI18n('status', 'en', 'Ready'),
          ],
          i18n: [YamlI18n('status', 'en', 'Ready')],
        ),
      ]);

      expect(
        I18nParser.parse(strings: roots.single.config.resolvedTranslations),
        {
          'greeting': {'en': 'Override hello', 'es': 'Hola'},
          'rootOnly': {'en': 'Root only'},
          'status': {'en': 'Ready'},
        },
      );
    });

    test('rejects missing parts', () {
      expect(
        () => resolveConfigurationParts([
          config('app', parts: ['missing']),
        ]),
        throwsA(
          isA<PartResolutionException>().having(
            (error) => error.message,
            'message',
            contains('references missing part "missing"'),
          ),
        ),
      );
    });

    test('reports the complete cycle', () {
      expect(
        () => resolveConfigurationParts([
          config('a', parts: ['b']),
          config('b', parts: ['c']),
          config('c', parts: ['a']),
        ]),
        throwsA(
          isA<PartResolutionException>().having(
            (error) => error.message,
            'message',
            contains('a -> b -> c -> a'),
          ),
        ),
      );
    });

    test('rejects duplicate ids and repeated part declarations', () {
      expect(
        () => resolveConfigurationParts([config('same'), config('same')]),
        throwsA(
          isA<PartResolutionException>().having(
            (error) => error.message,
            'message',
            contains('Duplicate configuration id "same"'),
          ),
        ),
      );
      expect(
        () => resolveConfigurationParts([
          config('app', parts: ['shared', 'shared']),
          config('shared'),
        ]),
        throwsA(
          isA<PartResolutionException>().having(
            (error) => error.message,
            'message',
            contains('declares part "shared" more than once'),
          ),
        ),
      );
    });
  });
}
