// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:dart_style/dart_style.dart';
import 'package:slang/builder/utils/path_utils.dart';

import 'atomic_file_batch.dart';
import 'cli_options.dart';
import 'config_file.dart';
import 'definition_resolver.dart';
import 'file_utils.dart';
import 'part_resolver.dart';

/// To run this:
/// -> flutter pub run configurator
Future<void> main(List<String> args) async {
  try {
    await runConfigurator(args);
  } on ConfiguratorCliException catch (error) {
    stderr.writeln('Configurator: ${error.message}');
    exitCode = 64;
  } on DefinitionResolutionException catch (error) {
    stderr.writeln('Configurator: ${error.message}');
    exitCode = 65;
  } on PartResolutionException catch (error) {
    stderr.writeln('Configurator: ${error.message}');
    exitCode = 65;
  } on InvalidYamlException catch (error) {
    stderr.writeln('Configurator: $error');
    exitCode = 65;
  } on StateError catch (error) {
    stderr.writeln('Configurator: ${error.message}');
    exitCode = 65;
  }
}

/// Runs Configurator and exposes expected failures to programmatic callers.
Future<void> runConfigurator(List<String> args) async {
  final options = ConfiguratorCliOptions.parse(args);

  if (options.help) {
    print(_usage);
    return;
  }

  if (options.recursive) {
    await _runRecursive(
      pureDart: options.pureDart,
      targets: options.targets,
    );
    return;
  }

  print('\n*****Configurator Starting!*****');

  // Parts must remain discoverable even when only a root basename is selected.
  // Filtering is applied after the complete catalog has been validated and
  // composed in [generateConfigurations].
  final files = findConfigurations(const []);
  if (files.isEmpty) {
    throw const ConfiguratorCliException(
      'No *.config.yaml files were found.',
    );
  }
  final definitions = findDefinitions(options.filters);

  await configure(
    files: files,
    definitionFiles: definitions,
    filters: options.filters,
    watch: options.watch,
    pureDart: options.pureDart,
    targets: options.targets,
  );
}

const String _usage = '''
Configurator

Generates native configuration code from *.config.yaml files.

Options:
  --targets=dart,python,typescript  Output languages (default: dart)
  --target=<language>              Repeatable single-target form
  --id-filter=id1,id2              Generate only matching file basenames
  -w, --watch                      Regenerate when YAML files change
  --recursive                      Generate in nested package roots
  --pure-dart                      Omit Flutter theme generation for Dart
  -h, --help                       Show this help
''';

List<FileSystemEntity> findConfigurations(List<String> filters) {
  return FileUtils.getFilesBreadthFirst(
    rootDirectory: Directory.current,
    ignoreTopLevelDirectories: {
      '.fvm',
      '.flutter.git',
      '.dart_tool',
      '.idea',
      '.gitignore',
      'build',
      'ios',
      'android',
      'web',
    },
  ).where((file) {
    bool isConfig = file.path.endsWith('.config.yaml');
    bool matchesFilter =
        filters.isEmpty || filters.contains(file.path.getFileNameNoExtension());

    return isConfig && matchesFilter;
  }).toList();
}

List<FileSystemEntity> findDefinitions(List<String> filters) {
  return FileUtils.getFilesBreadthFirst(
    rootDirectory: Directory.current,
    extension: '.defs.yaml',
    ignoreTopLevelDirectories: {
      '.fvm',
      '.flutter.git',
      '.dart_tool',
      '.idea',
      '.gitignore',
      'build',
      'ios',
      'android',
      'web',
    },
  ).where((file) => file.path.endsWith('.defs.yaml')).toList();
}

/// Compatibility entry point that validates definitions without writing files.
///
/// Definition application now occurs in memory inside
/// [generateConfigurations]. [configFiles] is retained in the signature for
/// callers of the former bin-level helper.
Future<void> applyDefinitions({
  required List<FileSystemEntity> configFiles,
  required List<FileSystemEntity> defFiles,
}) async {
  // Retained for callers of the old bin-level helper. Resolution now happens
  // in memory during generation; this method only validates the catalog and
  // deliberately leaves every configuration source untouched.
  DefinitionCatalog.fromFiles(defFiles);
}

Future<void> configure({
  required List<FileSystemEntity> files,
  List<FileSystemEntity> definitionFiles = const [],
  List<String> filters = const [],
  bool watch = false,
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
}) async {
  final stopwatch = Stopwatch();

  if (!watch) {
    stopwatch.start();
  }

  print('\n---Parsing Configs---');
  print(files.map((e) => e.path).join('\n'));

  if (watch) {
    await watchConfiguration(
      files: files,
      definitionFiles: definitionFiles,
      filters: filters,
      pureDart: pureDart,
      targets: targets,
    );
  } else {
    await generateConfigurations(
      files: files,
      definitionFiles: definitionFiles,
      filters: filters,
      stopwatch: stopwatch,
      pureDart: pureDart,
      targets: targets,
    );
  }
}

Future<void> generateConfigurations({
  required List<FileSystemEntity> files,
  List<FileSystemEntity> definitionFiles = const [],
  List<String> filters = const [],
  bool verbose = false,
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
  Stopwatch? stopwatch,
}) async {
  final definitions = DefinitionCatalog.fromFiles(definitionFiles);
  final parsedConfigs = <ConfigFile>[];
  for (final entity in files) {
    final file = File(entity.path);
    final source = file.readAsStringSync();
    final resolvedSource = definitions.resolveSource(
      path: file.path,
      source: source,
    );

    try {
      parsedConfigs.add(
        ConfigFile(
          file.path.getFileNameNoExtension(),
          file.parent.path,
          YamlParser.fromYamlString(resolvedSource),
        ),
      );
    } on InvalidYamlException catch (error) {
      throw InvalidYamlException('${file.path}: ${error.message}');
    } on Object catch (error) {
      throw InvalidYamlException('${file.path}: $error');
    }
  }

  final selected = filters.isEmpty
      ? const <ConfigFile>[]
      : parsedConfigs.where((config) => filters.contains(config.name)).toList();
  final selectedIds = selected.map((config) => config.config.name).toSet();
  final referencedBySelection = {
    for (final config in selected)
      ...config.config.partFiles.where(selectedIds.contains),
  };
  final selectedRootIds = selectedIds.difference(referencedBySelection);
  final configs = resolveConfigurationParts(
    parsedConfigs,
    rootIds: filters.isEmpty ? null : selectedRootIds,
  );
  if (configs.isEmpty) {
    final suffix = filters.isEmpty ? '' : ' matching ${filters.join(', ')}';
    throw ConfiguratorCliException(
      'No root *.config.yaml files were found$suffix.',
    );
  }

  print('\n---Resolved Configuration Parts---');
  for (final config in configs) {
    print(
      '${config.config.name}: '
      '${config.config.partFiles.isEmpty ? '(none)' : config.config.partFiles.join(', ')}',
    );
  }

  print(
    '\n---Generating ${targets.map((target) => target.name).join(', ')} Configurations---',
  );
  final outputs = <AtomicFileOutput>[];
  for (final file in configs) {
    final generatedName = file.config.name.camelCase.capitalized;

    for (final target in ConfigTarget.values.where(targets.contains)) {
      final outputFilePath = [
        file.directory,
        target.outputFileName(file.name),
      ].join(Platform.pathSeparator);

      final builtContent = switch (target) {
        ConfigTarget.dart => await _generateDartConfiguration(
            name: generatedName,
            config: file.config,
            pureDart: pureDart,
          ),
        ConfigTarget.python => const PythonConfigGenerator().generate(
            name: generatedName,
            configuration: file.config,
          ),
        ConfigTarget.typescript => const TypeScriptConfigGenerator().generate(
            name: generatedName,
            configuration: file.config,
          ),
      };

      outputs.add(
        AtomicFileOutput(
          path: outputFilePath,
          content: builtContent,
        ),
      );
    }
  }

  try {
    const AtomicFileBatchWriter().write(outputs);
  } on FileSystemException catch (error) {
    throw ConfiguratorCliException(
      'Unable to write generated output batch: $error',
    );
  }
  for (final output in outputs) {
    print(output.path);
  }

  print('\n*****Configurator Has Configured!*****');
}

Future<String> _generateDartConfiguration({
  required String name,
  required YamlConfiguration config,
  required bool pureDart,
}) async {
  final result = ProcessedConfig(name, config);
  final generated = await result.write(pureDart) as String;

  try {
    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(generated);
  } catch (error) {
    print(error);
    return generated;
  }
}

Future<void> watchConfiguration({
  required List<FileSystemEntity> files,
  List<FileSystemEntity> definitionFiles = const [],
  List<String> filters = const [],
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
}) async {
  StreamController sc = StreamController<FileSystemEvent>();

  List<String> watchDirs = [];

  for (var file in [...files, ...definitionFiles]) {
    if (!watchDirs.contains(file.parent.path)) {
      file.parent.watch(events: FileSystemEvent.all).listen(sc.sink.add);
      print('Watching: ${file.parent.path}');
      watchDirs.add(file.parent.path);
    }
  }

  await generateConfigurations(
    files: files,
    definitionFiles: definitionFiles,
    filters: filters,
    pureDart: pureDart,
    targets: targets,
  );

  print('\n\nLast Updated: $currentTime.');

  stdout.write('\r -> Watching for Changes... \r');
  await for (final event in sc.stream) {
    if (event.path.endsWith('.config.yaml') ||
        event.path.endsWith('.defs.yaml')) {
      stdout.write('\r -> Generating For ${event.path}\r');

      final newFiles =
          Directory.current.listSync(recursive: true).where((item) {
        return item is File && item.path.endsWith('.config.yaml');
      }).toList();

      await generateConfigurations(
        files: newFiles,
        definitionFiles: findDefinitions(filters),
        filters: filters,
        pureDart: pureDart,
        targets: targets,
      );

      stdout.write('\r -> Last Updated: $currentTime.\r');
    }
  }
}

// returns current time in HH:mm:ss
String get currentTime {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
}

extension on String {
  String getFileNameNoExtension() {
    return PathUtils.getFileNameNoExtension(this);
  }
}

Future<void> _runRecursive({
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
}) async {
  final sep = Platform.pathSeparator;

  final projectDir = Directory.current;
  final List<Directory> roots = [];

  final List<FileSystemEntity> entities = projectDir.listSync(
    recursive: true,
    followLinks: false,
  );

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('pubspec.yaml')) {
      roots.add(entity.parent);
    }
  }

  final List<Future<int>> tasks = [];

  for (final root in roots) {
    final configFiles = Directory(
      root.path,
    ).listSync(recursive: true).where((e) => e.path.endsWith('.config.yaml'));

    if (configFiles.isNotEmpty) {
      final pubspecContent =
          File('${root.path}${sep}pubspec.yaml').readAsStringSync();

      if (pubspecContent.contains('configurator:')) {
        print('Processing: ${root.path}');
        tasks.add(
          _runConfiguratorInIsolate(
            root.path,
            pureDart,
            targets,
          ),
        );
      }
    }
  }

  // 3. Wait for all processes to finish
  final exitCodes = await Future.wait(tasks);

  if (exitCodes.any((code) => code != 0)) {
    print('One or more configurations failed.');
    exit(1);
  }
  print('All configurations completed successfully.');
}

/// Helper to wrap the Isolate communication in a Future
Future<int> _runConfiguratorInIsolate(
  String path,
  bool pureDart,
  Set<ConfigTarget> targets,
) async {
  final p = ReceivePort();
  await Isolate.spawn(_configTask, [
    p.sendPort,
    path,
    pureDart,
    targets.map((target) => target.name).join(','),
  ]);
  return await p.first as int;
}

Future<void> _configTask(List<dynamic> args) async {
  final SendPort sendPort = args[0];
  final String path = args[1];
  final bool pureDart = args[2];
  final String targets = args[3];

  const String command = 'flutter';
  final List<String> arguments = [
    'pub',
    'run',
    'configurator',
    if (pureDart) '--pure-dart',
    '--targets=$targets',
  ];

  final result = await Process.run(
    command,
    arguments,
    workingDirectory: path,
    runInShell: true,
  );

  if (result.stdout.toString().isNotEmpty) print(result.stdout);

  if (result.stderr.toString().isNotEmpty) print(result.stderr);

  Isolate.exit(sendPort, result.exitCode);
}
