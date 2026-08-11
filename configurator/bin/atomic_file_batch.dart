import 'dart:io';

class AtomicFileOutput {
  const AtomicFileOutput({
    required this.path,
    required this.content,
  });

  final String path;
  final String content;
}

/// Writes a generated output set as one recoverable batch.
///
/// Every file is staged before any destination changes. Existing outputs are
/// backed up and restored if a later rename fails, preventing one target from
/// being updated while another remains stale.
class AtomicFileBatchWriter {
  const AtomicFileBatchWriter();

  void write(
    Iterable<AtomicFileOutput> outputIterable, {
    void Function(String path, int index)? beforeCommit,
  }) {
    final outputs = outputIterable.toList(growable: false);
    final destinations = <String>{};
    for (final output in outputs) {
      if (!destinations.add(output.path)) {
        throw FileSystemException(
          'Generated output path appears more than once',
          output.path,
        );
      }
    }

    if (outputs.isEmpty) {
      return;
    }

    final nonce = '${DateTime.now().microsecondsSinceEpoch}-$pid';
    final staged = <String, File>{};
    final backups = <String, File>{};
    final committed = <String>{};

    try {
      for (var index = 0; index < outputs.length; index++) {
        final output = outputs[index];
        final destination = File(output.path);
        destination.parent.createSync(recursive: true);
        final temporary = File(
          '${output.path}.configurator-$nonce-$index.tmp',
        );
        temporary.writeAsStringSync(output.content, flush: true);
        staged[output.path] = temporary;
      }

      for (var index = 0; index < outputs.length; index++) {
        final destination = File(outputs[index].path);
        if (destination.existsSync()) {
          final backup = File(
            '${outputs[index].path}.configurator-$nonce-$index.backup',
          );
          destination.renameSync(backup.path);
          backups[outputs[index].path] = backup;
        }
      }

      for (var index = 0; index < outputs.length; index++) {
        final output = outputs[index];
        beforeCommit?.call(output.path, index);
        staged[output.path]!.renameSync(output.path);
        committed.add(output.path);
      }
    } on Object catch (error, stackTrace) {
      final rollbackFailures = <Object>[];
      for (final path in committed) {
        final destination = File(path);
        try {
          if (destination.existsSync()) {
            destination.deleteSync();
          }
        } on Object catch (rollbackError) {
          rollbackFailures.add(rollbackError);
        }
      }
      for (final entry in backups.entries) {
        try {
          if (entry.value.existsSync()) {
            entry.value.renameSync(entry.key);
          }
        } on Object catch (rollbackError) {
          rollbackFailures.add(rollbackError);
        }
      }
      if (rollbackFailures.isNotEmpty) {
        throw FileSystemException(
          'Generated output commit failed ($error), and rollback retained one '
          'or more backup files: ${rollbackFailures.join('; ')}',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      for (final temporary in staged.values) {
        if (temporary.existsSync()) {
          temporary.deleteSync();
        }
      }
      // A backup that could not be restored is deliberately retained for
      // manual recovery rather than deleted during cleanup.
    }

    // Output replacement is complete at this point. Backup cleanup is best
    // effort so a cleanup failure can never trigger a rollback after an old
    // output has already been deleted.
    for (final backup in backups.values) {
      try {
        if (backup.existsSync()) {
          backup.deleteSync();
        }
      } on FileSystemException {
        // Leave the recoverable backup in place.
      }
    }
  }
}
