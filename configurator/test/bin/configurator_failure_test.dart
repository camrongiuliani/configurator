import 'dart:io';

import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

import '../../bin/cli_options.dart';
import '../../bin/configurator.dart';

void main() {
  test('reports a filter that matches no configurations', () async {
    await expectLater(
      runConfigurator(const ['--id-filter=definitely_absent_918273']),
      throwsA(
        isA<ConfiguratorCliException>().having(
          (error) => error.message,
          'message',
          contains('No root *.config.yaml files were found matching'),
        ),
      ),
    );
  });

  test('includes the source path in invalid YAML failures', () async {
    final directory = Directory.systemTemp.createTempSync('configurator-yaml-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final config = File('${directory.path}/broken.config.yaml')
      ..writeAsStringSync('id: broken\nconfiguration: [not-a-map]\n');

    await expectLater(
      generateConfigurations(
        files: [config],
        targets: const {ConfigTarget.python},
      ),
      throwsA(
        isA<InvalidYamlException>().having(
          (error) => error.message.toString(),
          'message',
          contains(config.path),
        ),
      ),
    );
  });

  test('a root filter still loads and composes its unlisted parts', () async {
    final directory =
        Directory.systemTemp.createTempSync('configurator-filter-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final root = File('${directory.path}/root.config.yaml')
      ..writeAsStringSync('''
id: root
parts:
  - shared
configuration:
  flags:
    rootOnly: true
''');
    final part = File('${directory.path}/shared.config.yaml')
      ..writeAsStringSync('''
id: shared
configuration:
  flags:
    fromPart: true
''');
    final output = File('${directory.path}/root_config.py');

    await generateConfigurations(
      files: [root, part],
      filters: const ['root'],
      targets: const {ConfigTarget.python},
    );

    expect(output.existsSync(), isTrue);
    expect(output.readAsStringSync(), contains('"fromPart": True'));
    expect(File('${directory.path}/shared_config.py').existsSync(), isFalse);
  });
}
