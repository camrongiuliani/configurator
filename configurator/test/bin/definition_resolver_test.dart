import 'dart:io';

import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

import '../../bin/configurator.dart' show applyDefinitions;
import '../../bin/definition_resolver.dart';

void main() {
  test('resolves every portable definition shape without rewriting YAML',
      () async {
    final directory = Directory.systemTemp.createTempSync('configurator-defs-');
    addTearDown(() => directory.deleteSync(recursive: true));

    final definitions = File('${directory.path}/shared.defs.yaml')
      ..writeAsStringSync('''
id: shared
definitions:
  colors:
    primaryColor: "112233"
  images:
    logoImage: assets/logo.png
  flags:
    featureEnabled: true
  sizes:
    itemSize: 12.5
  paddings:
    pagePadding: 16
  margins:
    cardMargin: 8
  misc:
    requestTimeout: 30
  routes:
    homePath: /home
  strings:
    welcomeText: Welcome
  i18n:
    farewellText: Au revoir
  textStyles:
    headingStyle:
      color: "445566"
      size: 20
      weight: 700
      height: 1
      typeface:
        family: Inter
        style: normal
''');
    final config = File('${directory.path}/app.config.yaml')
      ..writeAsStringSync('''
id: app
def_source: shared
configuration:
  colors:
    primary: *primaryColor
  images:
    logo: *logoImage
  flags:
    enabled: *featureEnabled
  sizes:
    item: *itemSize
  paddings:
    page: *pagePadding
  margins:
    card: *cardMargin
  misc:
    timeout: *requestTimeout
  routes:
    - id: 1
      path: *homePath
  strings:
    en:
      welcome: *welcomeText
  i18n:
    fr:
      farewell: *farewellText
  textStyles:
    heading: *headingStyle
''');

    final originalConfig = config.readAsStringSync();
    final originalDefinitions = definitions.readAsStringSync();
    await applyDefinitions(configFiles: [config], defFiles: [definitions]);
    expect(config.readAsStringSync(), originalConfig);
    expect(definitions.readAsStringSync(), originalDefinitions);

    final catalog = DefinitionCatalog.fromFiles([definitions]);
    final resolved = catalog.resolveSource(
      path: config.path,
      source: originalConfig,
    );
    final parsed = YamlParser.fromYamlString(resolved);

    expect(parsed.colors.single.value, '112233');
    expect(parsed.images.single.value, 'assets/logo.png');
    expect(parsed.flags.single.value, isTrue);
    expect(parsed.sizes.single.value, 12.5);
    expect(parsed.padding.single.value, 16);
    expect(parsed.margins.single.value, 8);
    expect(parsed.misc.single.value, 30);
    expect(parsed.routes.single.path, '/home');
    expect(parsed.strings.single.value, 'Welcome');
    expect(parsed.i18n.single.value, 'Au revoir');
    expect(parsed.textStyles.single.color, '445566');
    expect(parsed.textStyles.single.size, 20);
    expect(parsed.textStyles.single.typeface['family'], 'Inter');
    expect(config.readAsStringSync(), originalConfig);
    expect(definitions.readAsStringSync(), originalDefinitions);
  });

  test('reports missing and duplicate definition ids', () {
    final directory = Directory.systemTemp.createTempSync('configurator-defs-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final first = File('${directory.path}/first.defs.yaml')
      ..writeAsStringSync('id: shared\ndefinitions: {}\n');
    final second = File('${directory.path}/second.defs.yaml')
      ..writeAsStringSync('id: shared\ndefinitions: {}\n');

    expect(
      () => DefinitionCatalog.fromFiles([first, second]),
      throwsA(
        isA<DefinitionResolutionException>().having(
          (error) => error.message,
          'message',
          contains('Duplicate definitions id "shared"'),
        ),
      ),
    );

    final catalog = DefinitionCatalog.fromFiles(const []);
    expect(
      () => catalog.resolveSource(
        path: 'app.config.yaml',
        source: 'id: app\ndef_source: absent\nconfiguration: {}\n',
      ),
      throwsA(
        isA<DefinitionResolutionException>().having(
          (error) => error.message,
          'message',
          contains('missing definitions id "absent"'),
        ),
      ),
    );
  });
}
