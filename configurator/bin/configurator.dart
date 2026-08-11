// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:dart_style/dart_style.dart';
import 'package:slang/builder/utils/path_utils.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';
import 'config_file.dart';
import 'file_utils.dart';
import 'graph.dart';

/// To run this:
/// -> flutter pub run configurator
Future<void> main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    print(_usage);
    return;
  }

  final bool recursive = args.contains('--recursive');
  final bool pureDart = args.contains('--pure-dart');
  final Set<ConfigTarget> targets = ConfigTarget.fromArguments(args);

  if (recursive) {
    await _runRecursive(
      pureDart: pureDart,
      targets: targets,
    );
    return;
  }

  final bool watch = args.contains('-w') || args.contains('--watch');

  List<String> filters = args.join('///').contains('--id-filter=')
      ? args
          .where((a) => a.startsWith('--id-filter='))
          .first
          .split('=')
          .last
          .split(',')
      : [];

  print('\n*****Configurator Starting!*****');

  List<FileSystemEntity> files = findConfigurations(filters);
  List<FileSystemEntity> definitions = findDefinitions(filters);

  await applyDefinitions(
    configFiles: files,
    defFiles: definitions,
  );

  await configure(
    files: files,
    filters: filters,
    watch: watch,
    pureDart: pureDart,
    targets: targets,
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

Future<void> applyDefinitions({
  required List<FileSystemEntity> configFiles,
  required List<FileSystemEntity> defFiles,
}) async {
  final List<File> configs = configFiles.map((e) => File(e.path)).toList();
  final List<File> defs = defFiles.map((e) => File(e.path)).toList();

  for (var def in defs) {
    final YamlDocument document = loadYamlDocument(def.readAsStringSync());
    final YamlNode rootDefsNode = document.contents;

    final String? id = rootDefsNode.value['id'];

    if (id == null) {
      continue;
    }

    for (var config in configs) {
      var configSource = config.readAsLinesSync();

      if (configSource.contains('def_source: $id')) {
        print('Writings definitions ($id) to ${config.path}');

        final YamlNode definitions = rootDefsNode.value['definitions'];
        final YamlMap? colors = definitions.value['colors'];
        final YamlMap? sizes = definitions.value['sizes'];
        final YamlMap? flags = definitions.value['flags'];

        final Map colorsMap = Map.fromEntries(colors?.entries ?? {});
        final Map sizesMap = Map.fromEntries(sizes?.entries ?? {});
        final Map flagsMap = Map.fromEntries(flags?.entries ?? {});

        writeDefsToFile(config, colorsMap, 'colors', true);
        writeDefsToFile(config, sizesMap, 'sizes');
        writeDefsToFile(config, flagsMap, 'flags');
      }
    }
  }
}

void writeDefsToFile(
  File file,
  Map defs,
  String node, [
  bool quoteWrap = false,
]) {
  if (defs.isEmpty) {
    return;
  }

  var contents = file.readAsStringSync();

  List<String> lines = contents.split('\n');

  var configurationNodeIdx = lines.indexWhere((l) {
    return l.trim().startsWith('configuration');
  });

  var lookupNodeIdx = lines.indexWhere((l) {
    return l.contains('$node:') && !l.trim().startsWith('#');
  });

  if (lookupNodeIdx < 0 || lookupNodeIdx > configurationNodeIdx) {
    return;
  }

  var nodeStartIdx = lookupNodeIdx + 1;
  var nodeEndIdx = nodeStartIdx;

  var searchIdx = nodeStartIdx + 1;

  while (searchIdx < lines.length && lines[searchIdx].startsWith('    ')) {
    nodeEndIdx++;
    searchIdx++;
  }

  List<String> newDefs = [];

  String? getCurrentLineIfExists(String key) {
    var line = lines
        .sublist(nodeStartIdx, nodeEndIdx + 1)
        .firstWhereOrNull((l) => l.startsWith('$key:'));

    if (line == null) {
      return null;
    }

    var lineIdx = lines.indexOf(line);

    if (lineIdx == -1) {
      return null;
    }

    var outOfBounds = lineIdx < nodeStartIdx || lineIdx > nodeEndIdx;

    return outOfBounds ? null : line;
  }

  void updateLineIfNotEqual({
    required String oldLine,
    required String newLine,
  }) {
    var lineIdx = lines.indexOf(oldLine);

    if (lineIdx > -1) {
      var oldLine = lines[lineIdx];

      if (oldLine != newLine) {
        lines[lineIdx] = newLine;
        print('Updated ${node.capitalized} Def -> $newLine');
      } else {
        print('Did not update def, no change: $newLine');
      }
    }
  }

  List<String> expandDefMap(
    Map map,
    List<String> result,
    List<String> keys,
    int depth,
    bool quoteWrap,
  ) {
    List<String> result = [];

    for (var entry in map.entries) {
      List<String> nestedKeys = List.from(keys);
      nestedKeys.add(entry.key);

      if (entry.value is Map) {
        var padding = List.filled(2 * depth, ' ').join();

        var oldLine = getCurrentLineIfExists('$padding${entry.key}');

        if (oldLine != null) {
          continue;
        }

        result.add('$padding${entry.key}:');

        result.addAll(
          expandDefMap(
            entry.value,
            result,
            nestedKeys,
            depth + 1,
            quoteWrap,
          ),
        );
      } else {
        var padding = List.filled(2 * depth, ' ').join();
        var value = quoteWrap ? '"${entry.value}"' : entry.value;

        var oldLine = getCurrentLineIfExists('$padding${entry.key}');

        var keyPart = '&${nestedKeys.join('.').canonicalize}';
        var newLine = '$padding${entry.key}: $keyPart $value';

        if (oldLine == null) {
          result.add(newLine);
        } else {
          updateLineIfNotEqual(
            oldLine: oldLine,
            newLine: newLine,
          );
        }
      }
    }

    return result;
  }

  for (var entry in defs.entries) {
    var line = getCurrentLineIfExists('    ${entry.key}');

    if (line == null || entry.value is Map) {
      if (entry.value is Map) {
        var oldLine = getCurrentLineIfExists('    ${entry.key}');
        var newLine = '    ${entry.key}:';

        if (oldLine == null) {
          newDefs.add(newLine);
        } else {
          updateLineIfNotEqual(
            oldLine: oldLine,
            newLine: newLine,
          );
        }

        newDefs.addAll(
          expandDefMap(
            entry.value,
            [],
            [node, entry.key],
            3,
            quoteWrap,
          ),
        );
      } else {
        var value = quoteWrap ? '"${entry.value}"' : entry.value;
        newDefs.add('    ${entry.key}: &${entry.key} $value');
      }
    } else {
      var value = quoteWrap ? '"${entry.value}"' : entry.value;
      updateLineIfNotEqual(
        oldLine: line,
        newLine: '    ${entry.key}: &${entry.key} $value',
      );
    }
  }

  if (newDefs.isNotEmpty) {
    lines.insertAll(nodeStartIdx, newDefs);
    for (var def in newDefs) {
      print('Insert ${node.capitalized} Def -> $def');
    }
  }

  var newDoc = lines.join('\n');

  try {
    var parsed = YamlEditor(newDoc).toString();
    file.writeAsStringSync(parsed, flush: true);
  } catch (e) {
    file.writeAsStringSync(newDoc, flush: true);
  }
}

Future<void> configure({
  required List<FileSystemEntity> files,
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
      filters: filters,
      pureDart: pureDart,
      targets: targets,
    );
  } else {
    await generateConfigurations(
      files: files,
      stopwatch: stopwatch,
      pureDart: pureDart,
      targets: targets,
    );
  }
}

Future<void> generateConfigurations({
  required List<FileSystemEntity> files,
  bool verbose = false,
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
  Stopwatch? stopwatch,
}) async {
  // Read yaml paths from annotation
  final List<String> yamlInput = files.map((e) => e.path).toList();

  // Ingest yaml as File(s)
  final List<File> yamlFiles = yamlInput.map((e) => File(e)).toList();

  // Convert to ConfigFiles (dir & config)
  List<ConfigFile> configs = yamlFiles.map((e) {
    return ConfigFile(
      e.path.getFileNameNoExtension(),
      e.parent.path,
      YamlParser.fromYamlString(e.readAsStringSync()),
    );
  }).toList();

  Graph<ConfigFile?> graph = Graph<ConfigFile?>(
    name: (c) => c?.config.name ?? 'null',
    keepAlive: (f) => f != null,
  );

  void buildPartGraph(List<ConfigFile> input, [ConfigFile? from]) {
    for (var c in input) {
      var parts = configs
          .where((e) => c.config.partFiles.contains(e.config.name))
          .toList();

      graph.addEdge(from, c);

      buildPartGraph(parts, c);
    }
  }

  void mergeConfigs(Set<ConfigFile?> set, List<String> handled) {
    for (var a in set) {
      if (a == null || handled.contains(a.config.name)) {
        continue;
      }

      Set<ConfigFile?> parts = graph.from(a);

      mergeConfigs(parts, handled);

      var to = graph.to(a);

      for (var t in to) {
        if (t != null) {
          t.config = t.config + a.config;
          handled.add(a.config.name);
          print('Merged ${a.config.name} --> ${t.config.name}');
        }
      }
    }
  }

  buildPartGraph(List.from(configs));

  var baseGraph = graph.from(null);

  graph.delete(null);

  print('\n---Built Configuration Graph---');
  print(graph.toDebugString());

  List<String> track = [];

  print('\n---Merging Configurations---');
  for (var node in baseGraph) {
    mergeConfigs(graph.from(node), track);
  }

  print(
    '\n---Generating ${targets.map((target) => target.name).join(', ')} Configurations---',
  );
  for (var file in configs.where((c) => !track.contains(c.config.name))) {
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

      FileUtils.writeFile(
        path: outputFilePath,
        content: builtContent,
      );

      print(outputFilePath);
    }
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
  List<String> filters = const [],
  bool pureDart = false,
  Set<ConfigTarget> targets = const {ConfigTarget.dart},
}) async {
  StreamController sc = StreamController<FileSystemEvent>();

  List<String> watchDirs = [];

  for (var file in files) {
    if (!watchDirs.contains(file.parent.path)) {
      file.parent.watch(events: FileSystemEvent.all).listen(sc.sink.add);
      print('Watching: ${file.parent.path}');
      watchDirs.add(file.parent.path);
    }
  }

  await generateConfigurations(
    files: files,
    pureDart: pureDart,
    targets: targets,
  );

  print('\n\nLast Updated: $currentTime.');

  stdout.write('\r -> Watching for Changes... \r');
  await for (final event in sc.stream) {
    if (event.path.endsWith('.config.yaml')) {
      stdout.write('\r -> Generating For ${event.path}\r');

      final newFiles =
          Directory.current.listSync(recursive: true).where((item) {
        return item is File &&
            item.path.endsWith('.config.yaml') &&
            (filters.isEmpty ||
                filters.contains(item.path.getFileNameNoExtension()));
      }).toList();

      await generateConfigurations(
        files: newFiles,
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
