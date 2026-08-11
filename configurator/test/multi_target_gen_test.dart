import 'dart:io';

import 'package:test/test.dart';

import '../bin/script_gen.dart';

void main() {
  test('one YAML file generates Python and TypeScript configurations',
      () async {
    final pythonOutput = File('./test/assets/test_2_config.py');
    final typescriptOutput = File('./test/assets/test_2.config.ts');
    final dartOutput = File('./test/assets/test_2.config.dart');

    void removeOutputs() {
      for (final output in [pythonOutput, typescriptOutput, dartOutput]) {
        if (output.existsSync()) {
          output.deleteSync();
        }
      }
    }

    removeOutputs();
    addTearDown(removeOutputs);

    await DartScriptGen.execute(const [
      '--id-filter=test_2',
      '--targets=python,typescript',
    ]);

    expect(pythonOutput.existsSync(), isTrue);
    expect(typescriptOutput.existsSync(), isTrue);
    expect(dartOutput.existsSync(), isFalse);

    expect(
      pythonOutput.readAsStringSync(),
      allOf(contains('ConfigScope'), contains('Configuration')),
    );
    expect(
      typescriptOutput.readAsStringSync(),
      allOf(contains('defineScope'), contains('Configuration')),
    );
  });
}
