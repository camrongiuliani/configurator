import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:test/test.dart';

void main() {
  group('Enum Parsing Tests', () {
    test('Parse Enum Definitions', () {
      const yaml = '''
id: test_config
enums:
  AppTheme: [light, dark, system]
configuration:
  enums:
    theme:
      type: AppTheme
      value: system
''';
      final config = YamlParser.fromYamlString(yaml);
      expect(config.enumDefinitions.length, equals(1));
      expect(config.enumDefinitions[0].name, equals('AppTheme'));
      expect(config.enumDefinitions[0].values, equals(['light', 'dark', 'system']));
    });

    test('Parse Enum Settings', () {
      const yaml = '''
id: test_config
configuration:
  enums:
    theme:
      type: AppTheme
      value: system
''';
      final config = YamlParser.fromYamlString(yaml);
      expect(config.enums.length, equals(1));
      expect(config.enums[0].name, equals('theme'));
      expect(config.enums[0].type, equals('AppTheme'));
      expect(config.enums[0].value, equals('system'));
    });

    test('Parse Nested Enum Settings', () {
      const yaml = '''
id: test_config
configuration:
  enums:
    ui:
      theme:
        type: AppTheme
        value: system
''';
      final config = YamlParser.fromYamlString(yaml);
      expect(config.enums.length, equals(1));
      expect(config.enums[0].name, equals('uiTheme'));
      expect(config.enums[0].type, equals('AppTheme'));
      expect(config.enums[0].value, equals('system'));
    });
  });

  group('Enum Runtime Tests', () {
    test('ConfigScope should store enum values', () {
      const yaml = '''
id: test_config
configuration:
  enums:
    theme:
      type: AppTheme
      value: dark
''';
      final scope = ConfigScope.fromYaml(yaml);
      expect(scope.enums['theme'], equals('dark'));
    });

    test('Configuration should retrieve enum values', () {
      final scope = ProxyScope(
        name: 'test',
        enums: {'theme': 'light'},
      );
      final config = Configuration(scopes: [scope]);
      expect(config.enumValue('theme'), equals('light'));
    });

    test('Configuration should respect scope precedence for enums', () {
      final scope1 = ProxyScope(
        name: 'base',
        weight: 0,
        enums: {'theme': 'light'},
      );
      final scope2 = ProxyScope(
        name: 'override',
        weight: 1,
        enums: {'theme': 'dark'},
      );
      final config = Configuration(scopes: [scope1, scope2]);
      expect(config.enumValue('theme'), equals('dark'));
    });

    test('Empty Enums if Wrong Structure', () {
      const yaml = '''
id: test_config
configuration:
  enums:
    theme: dark
''';
      final config = YamlParser.fromYamlString(yaml);
      expect(config.enums, isEmpty);
    });
  });

  group('Enum Generation Tests', () {
    test('Generate Enum Definition and Accessor', () async {
      final yamlConfig = YamlConfiguration(
        name: 'Test',
        enumDefinitions: [
          YamlEnumDefinition('AppTheme', ['light', 'dark', 'system']),
        ],
        enums: [
          YamlEnumSetting('theme', 'AppTheme', 'system'),
        ],
      );

      final processed = ProcessedConfig('Test', yamlConfig);
      final output = await processed.write(true);

      expect(output, contains('enum AppTheme'));
      expect(output, contains('light,'));
      expect(output, contains('dark,'));
      expect(output, contains('system;'));
      expect(output, contains('static AppTheme fromName(String name'));
      expect(output, contains('class _EnumAccessor'));
      expect(output, contains('AppTheme get theme => AppTheme.fromName(_config.enumValue(\"theme\"));'));
    });
  });
}
