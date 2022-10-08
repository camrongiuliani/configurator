import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:dart_style/dart_style.dart';
import 'package:rxdart/rxdart.dart';
import 'package:slang/builder/utils/file_utils.dart';
import 'package:slang/builder/utils/path_utils.dart';
import 'config_file.dart';
import 'graph.dart';

class DartScriptGen {
  static void execute( List<String> arguments ) => main( arguments );
}

/// To run this:
/// -> flutter pub run configurator
void main(List<String> arguments) async {
  final bool watchMode;
  final bool verbose;
  List<String> filters = arguments.where((a) => a.startsWith( '--id-filter=' )).first.split( '=' ).last.split( ',' );

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
  ).where((file) {
    return ( file.path.endsWith( '.config.yaml' ) && filters.isEmpty )
        || filters.contains( file.path.getFileNameNoExtension() );
  }).toList();

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
  List<ConfigFile> configs = yamlFiles.map((e) {
    return ConfigFile(
      e.path.getFileNameNoExtension(),
      e.parent.path,
      YamlParser.fromYamlString( e.readAsStringSync() ),
    );
  }).toList();

  Graph<ConfigFile?> graph = Graph<ConfigFile?>(
    name: ( c ) => c?.config.name ?? 'null',
    keepAlive: ( f ) => f != null,
  );

  void buildPartGraph( List<ConfigFile> input, [ ConfigFile? from ] ) {

    for ( var c in input ) {

      var parts = configs.where((e) => c.config.partFiles.contains( e.config.name )).toList();

      configs.removeWhere((e) => parts.contains(e));

      graph.addEdge( from, c );

      buildPartGraph( parts, c );
    }
  }

  void mergeConfigs( Set<ConfigFile?> set, List<String> handled ) {

    for ( var a in set ) {

      if ( a == null || handled.contains( a.config.name ) ) {
        continue;
      }

      Set<ConfigFile?> parts = graph.from( a );

      mergeConfigs( parts, handled );

      var to = graph.to( a );

      for ( var t in to ) {
        if ( t != null ) {
          print('Merge ${a.config.name} --> ${t.config.name}');
          t.config = t.config + a.config;
          handled.add( a.config.name );
        }
      }
    }
  }

  buildPartGraph( List.from( configs ) );
  
  var baseGraph = graph.from( null );
  
  graph.delete( null );
  
  List<String> track = [];

  for ( var node in baseGraph ) {
    mergeConfigs( graph.from( node ), track );
  }

  for ( var file in configs.where(( c ) => ! track.contains( c.config.name )) ) {

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