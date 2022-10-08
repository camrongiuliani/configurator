import 'dart:async';
import 'dart:io';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:dart_style/dart_style.dart';
import 'package:rxdart/rxdart.dart';
import 'package:slang/builder/utils/file_utils.dart';
import 'package:slang/builder/utils/path_utils.dart';
import 'config_file.dart';

/// To run this:
/// -> flutter pub run configurator
void main(List<String> arguments) async {
  final bool watchMode;
  final bool verbose;
  if (arguments.isNotEmpty) {
    watchMode = arguments[0] == 'watch';
    verbose = (arguments.length == 2 &&
            (arguments[1] == '-v' || arguments[1] == '--verbose'));
  } else {
    watchMode = false;
    verbose = true;
  }

  print('Generating Configurations...\n');

  final stopwatch = Stopwatch();

  if (!watchMode) {
    stopwatch.start();
  }

  List<FileSystemEntity> files = FileUtils.getFilesBreadthFirst(
    rootDirectory: Directory.current,
    ignoreTopLevelDirectories: {
      '.fvm',
      '.flutter.git',
      '.dart_tool',
      'build',
      'ios',
      'android',
      'web',
    },
  ).where((file) => file.path.endsWith( '.config.yaml' )).toList();

  if (watchMode) {
    await watchConfiguration(
      files: files,
      verbose: verbose,
    );
  } else {
    await generateConfigurations(
      files: files,
      verbose: verbose,
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
  final List<File> yamlFiles = yamlInput.map((e) => File( e )).toList();

  // Convert to ConfigFiles (dir & config)
  final List<ConfigFile> configs = yamlFiles.map((e) {
    return ConfigFile(
      e.path.getFileNameNoExtension(),
      e.parent.path,
      YamlParser.fromYamlString( e.readAsStringSync() ),
    );
  }).toList();

  List<String> toRemove = [];

  for ( var c in configs ) {
    print( 'Loading -- ${c.config.name}' );
    for ( var p in c.config.partFiles ) {
      print( 'Loading ---- $p' );
    }
  }

  List<ConfigFile> sortConfigs( List<ConfigFile> configs, List<ConfigFile> sorted ) {
    for ( var c in configs ) {
      if ( c.config.partFiles.isEmpty) {
        sorted.add( c );
      } else {
        for ( var part in c.config.partFiles ) {
          sortConfigs(
            configs.where(( e ) => e.config.name == part ).toList(),
            [],
          );
        }
      }
    }

    return sorted;
  }

  List<ConfigFile> sorted = sortConfigs( configs, [] );

  for ( var c in sorted ) {
    print( '-- ${c.config.name}' );
  }

  for ( ConfigFile c in List.from( configs ) ) {

    if ( c.config.partFiles.isNotEmpty ) {
      var parts = configs.where( ( p ) => c.config.partFiles.contains( p.config.name ) );

      if ( parts.isNotEmpty ) {
        for ( var part in parts ) {
          c.config = c.config + part.config;
          toRemove.add( part.config.name );
          print('Merged Part: ${part.config.name} --> ${c.config.name}');
        }
      }
    }
  }

  for (var e in toRemove) {
    configs.removeWhere((element) {
      bool remove = element.name == e;
      if ( remove ) {
        print('Part Gen Skipped: $e');
      }
      return remove;
    });
  }

  for ( var file in configs ) {

    String outputFilePath = '${file.directory}${Platform.pathSeparator}${file.name}.config.dart';

    // FileUtils.createMissingFolders( filePath: outputFilePath );

    var result = ProcessedConfig( file.config.name.camelCase.capitalized, file.config );

    FileUtils.writeFile(
      path: outputFilePath,
      content: DartFormatter().format( await result.write() ),
    );

    print( 'Wrote Config: $outputFilePath' );
  }
}

Future<void> watchConfiguration({
  required List<FileSystemEntity> files,
  bool verbose = false,
}) async {

  StreamController sc = StreamController<FileSystemEvent>();

  List<String> watchDirs = [];

  for ( var file in files ) {
    if ( ! watchDirs.contains( file.parent.path ) ) {
      file.parent.watch( events: FileSystemEvent.all ).listen( sc.sink.add );
      print( 'Watching: ${file.parent.path}' );
    }
  }

  await generateConfigurations(
    files: files,
    verbose: verbose,
  );

  stdout.write('\r -> Last Updated: $currentTime. \r');
  await for (final event in sc.stream) {
    if (event.path.endsWith('.config.yaml')) {

      stdout.write('\r -> Generating For ${event.path}\r');

      final newFiles = Directory.current
          .listSync(recursive: true)
          .where((item) {
            return item is File && item.path.endsWith( '.config.yaml' );
          })
          .toList();

      await generateConfigurations(
        files: newFiles,
        verbose: verbose,
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
  /// converts /some/path/file.json to file.json
  String getFileName() {
    return PathUtils.getFileName(this);
  }

  /// converts /some/path/file.json to file
  String getFileNameNoExtension() {
    return PathUtils.getFileNameNoExtension(this);
  }
}