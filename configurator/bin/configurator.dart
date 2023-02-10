import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  final bool applyDefs = args.contains('--apply-defs') && args.contains('-i');

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

  if (applyDefs) {
    var idx = args.indexOf('-i');
    var input = args[idx + 1];

    if (input.isEmpty) {
      throw Exception('Input not specified for definitions');
    }

    if (!input.contains('.defs.yaml')) {
      throw Exception('Invalid file extension for definitions');
    }

    await applyDefinitions(
      files: files,
      inputFile: input,
    );
  }

  configure(
    files: files,
    watch: watch,
  );
}

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

Future<void> applyDefinitions({
  required List<FileSystemEntity> files,
  required String inputFile,
}) async {
  final List<File> configFiles = files.map((e) => File(e.path)).toList();

  final File definitionsFile = File(inputFile);

  final YamlDocument document =
      loadYamlDocument(definitionsFile.readAsStringSync());
  final YamlNode rootNode = document.contents;

  final YamlNode definitions = rootNode.value['definitions'];
  final YamlMap colors = definitions.value['colors'];

  final Map colorsMap = Map.fromEntries(colors.entries);

  for (var file in configFiles) {
    var contents = file.readAsStringSync();

    List<String> lines = contents.split('\n');

    var colorNodeIdx = lines.indexWhere((l) => l.contains('colors:'));

    if (colorNodeIdx < 0) {
      continue;
    }

    var colorStartIdx = colorNodeIdx + 1;
    var colorEndIdx = colorStartIdx;

    var searchIdx = colorStartIdx + 1;

    while (searchIdx < lines.length && lines[searchIdx].startsWith('    ')) {
      colorEndIdx++;
      searchIdx++;
    }

    List<String> newDefs = [];

    for (var entry in colorsMap.entries) {
      var line = lines.sublist(colorStartIdx, colorEndIdx + 1).firstWhereOrNull((l) => l.trim().startsWith('${entry.key}:'));

      if (line == null) {
        newDefs.add('    ${entry.key}: &${entry.key} "${entry.value}"');
      } else {
        var lineIdx = lines.indexOf(line);

        if (lineIdx > -1) {
          var oldLine = lines[lineIdx];
          var newLine = '    ${entry.key}: &${entry.key} "${entry.value}"';

          if (oldLine != newLine) {
            lines[lineIdx] = '    ${entry.key}: &${entry.key} "${entry.value}"';
            print('Update Color Def -> $line -> ${lines[lineIdx]}');
          }
        }
      }
    }

    if (newDefs.isNotEmpty) {
      for (var def in newDefs) {
        lines.insert(colorEndIdx, def);
        colorEndIdx++;
        print('Insert Color Def -> $def');
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
}

Future<void> configure({
  required List<FileSystemEntity> files,
  bool watch = false,
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
    );
  } else {
    await generateConfigurations(
      files: files,
      stopwatch: stopwatch,
    );
  }
}

Future<void> generateConfigurations({
  required List<FileSystemEntity> files,
  bool verbose = false,
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

  print('\n---Generating Dart Classes---');
  for (var file in configs.where((c) => !track.contains(c.config.name))) {
    String outputFilePath =
        '${file.directory}${Platform.pathSeparator}${file.name}.config.dart';

    var result =
        ProcessedConfig(file.config.name.camelCase.capitalized, file.config);

    var builtContent = await () async {
      try {
        return DartFormatter().format(await result.write());
      } catch(e) {
        print(e);
        return await result.write();
      }
    }();

    FileUtils.writeFile(
      path: outputFilePath,
      content: builtContent,
      // content: await result.write(),
    );

    print(outputFilePath);
  }

  print('\n*****Configurator Has Configured!*****');
}

Future<void> watchConfiguration({
  required List<FileSystemEntity> files,
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
  );

  print('\n\nLast Updated: $currentTime.');

  stdout.write('\r -> Watching for Changes... \r');
  await for (final event in sc.stream) {
    if (event.path.endsWith('.config.yaml')) {
      stdout.write('\r -> Generating For ${event.path}\r');

      final newFiles =
          Directory.current.listSync(recursive: true).where((item) {
        return item is File && item.path.endsWith('.config.yaml');
      }).toList();

      await generateConfigurations(
        files: newFiles,
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
