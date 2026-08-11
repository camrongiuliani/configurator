import 'dart:io';

import 'package:test/test.dart';

import '../../bin/atomic_file_batch.dart';

void main() {
  test('restores every old output when a batch commit fails', () {
    final directory =
        Directory.systemTemp.createTempSync('configurator-write-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final first = File('${directory.path}/app_config.py')
      ..writeAsStringSync('old python');
    final second = File('${directory.path}/app.config.ts')
      ..writeAsStringSync('old typescript');
    final outputs = [
      AtomicFileOutput(path: first.path, content: 'new python'),
      AtomicFileOutput(path: second.path, content: 'new typescript'),
    ];

    expect(
      () => const AtomicFileBatchWriter().write(
        outputs,
        beforeCommit: (_, index) {
          if (index == 1) {
            throw const FileSystemException('simulated failure');
          }
        },
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(first.readAsStringSync(), 'old python');
    expect(second.readAsStringSync(), 'old typescript');
    expect(
      directory
          .listSync()
          .where((entry) => entry.path.contains('.configurator-')),
      isEmpty,
    );

    const AtomicFileBatchWriter().write(outputs);
    expect(first.readAsStringSync(), 'new python');
    expect(second.readAsStringSync(), 'new typescript');
  });
}
