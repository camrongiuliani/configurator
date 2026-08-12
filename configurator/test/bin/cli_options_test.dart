import 'package:test/test.dart';

import '../../bin/cli_options.dart';

void main() {
  group('ConfiguratorCliOptions', () {
    test('rejects unknown options', () {
      expect(
        () => ConfiguratorCliOptions.parse(const ['--typo']),
        throwsA(
          isA<ConfiguratorCliException>().having(
            (error) => error.message,
            'message',
            contains('Unknown option "--typo"'),
          ),
        ),
      );
    });

    test('turns invalid targets into friendly CLI failures', () {
      expect(
        () => ConfiguratorCliOptions.parse(const ['--target=ruby']),
        throwsA(
          isA<ConfiguratorCliException>().having(
            (error) => error.message,
            'message',
            contains('Unsupported configuration target: ruby'),
          ),
        ),
      );
    });

    test('validates filters', () {
      expect(
        () => ConfiguratorCliOptions.parse(const ['--id-filter=app,']),
        throwsA(isA<ConfiguratorCliException>()),
      );
      expect(
        () => ConfiguratorCliOptions.parse(
          const ['--id-filter=app', '--id-filter=other'],
        ),
        throwsA(isA<ConfiguratorCliException>()),
      );
    });

    test('recognizes the executable version switch', () {
      final options = ConfiguratorCliOptions.parse(const ['--version']);

      expect(options.version, isTrue);
      expect(options.help, isFalse);
    });
  });
}
