import 'dart:io';
import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

const String testYaml1 = './test/assets/test_1.yaml';

main() {
  group( 'Translation Tests', () {

    test('description', () async {
      var m = File( testYaml1 ).readAsStringSync();

      YamlConfiguration yc = YamlParser.fromYamlString( m );

      var x = SlangUtil.generateTranslations(
        rawConfig: {},
        i18nNodes: yc.strings,
        verbose: true,
      );
    });
  });
}