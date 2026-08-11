import 'package:configurator/src/generators/config_target.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigTarget', () {
    test('defaults to Dart when no target arguments are supplied', () {
      expect(
        ConfigTarget.fromArguments(const []),
        equals({ConfigTarget.dart}),
      );
    });

    test('parses multiple targets and aliases without duplicates', () {
      expect(
        ConfigTarget.fromArguments(const [
          '--targets=dart,py',
          '--target=ts',
          '--target=python',
        ]),
        equals({
          ConfigTarget.dart,
          ConfigTarget.python,
          ConfigTarget.typescript,
        }),
      );
    });

    test('rejects unsupported and empty target names', () {
      expect(
        () => ConfigTarget.fromArguments(const ['--target=ruby']),
        throwsFormatException,
      );
      expect(
        () => ConfigTarget.fromArguments(const ['--targets=python,']),
        throwsFormatException,
      );
    });

    test('builds language-specific output filenames', () {
      expect(ConfigTarget.dart.outputFileName('app'), 'app.config.dart');
      expect(ConfigTarget.python.outputFileName('app'), 'app_config.py');
      expect(
        ConfigTarget.typescript.outputFileName('app'),
        'app.config.ts',
      );
    });
  });
}
