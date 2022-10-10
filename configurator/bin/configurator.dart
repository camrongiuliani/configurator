import 'dart:async';
import 'dart:io';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/processed_config.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:dart_style/dart_style.dart';
import 'package:slang/builder/utils/path_utils.dart';
import 'config_file.dart';
import 'file_utils.dart';
import 'graph.dart';

/// To run this:
/// -> flutter pub run configurator
Future<void> main(List<String> arguments) async {
  final bool watch = arguments.contains( '-w' ) || arguments.contains( '--watch' );

  List<String> filters = arguments.join('///').contains('--id-filter=')
      ? arguments.where((a) => a.startsWith( '--id-filter=' )).first.split( '=' ).last.split( ',' )
      : [];

  print( '\n*****Configurator Starting!*****' );

  final stopwatch = Stopwatch();

  if (!watch) {
    stopwatch.start();
  }

  List<FileSystemEntity> files = FileUtils.getFilesBreadthFirst(
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

    bool isConfig = file.path.endsWith( '.config.yaml' );
    bool matchesFilter = filters.isEmpty || filters.contains( file.path.getFileNameNoExtension() );

    return isConfig && matchesFilter;
  }).toList();

  print( '\n---Parsing Configs---' );
  print( files.map((e) => e.path).join('\n') );

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

      configs.removeWhere((e) {
        bool part = parts.contains(e);

        if ( part ) {
          print( '--removing ${e.config.name}, was part of ${c.config.name}' );
        }

        return part;
      });

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
          print('Merged ${a.config.name} --> ${t.config.name}');
          t.config = t.config + a.config;
          handled.add( a.config.name );
        }
      }
    }
  }

  buildPartGraph( List.from( configs ) );
  
  var baseGraph = graph.from( null );
  
  graph.delete( null );

  print( '\n---Built Configuration Graph---' );
  print( graph.toDebugString() );

  List<String> track = [];

  print( '\n---Merging Configurations---' );
  for ( var node in baseGraph ) {
    mergeConfigs( graph.from( node ), track );
  }

  print( '\n---Generating Dart Classes---' );
  for ( var file in configs.where(( c ) => ! track.contains( c.config.name )) ) {

    String outputFilePath = '${file.directory}${Platform.pathSeparator}${file.name}.config.dart';

    var result = ProcessedConfig( file.config.name.camelCase.capitalized, file.config );

    FileUtils.writeFile(
      path: outputFilePath,
      content: DartFormatter().format( await result.write() ),
    );

    print( outputFilePath );
  }

  print( '\n*****Configurator Has Configured!*****' );

}

Future<void> watchConfiguration({
  required List<FileSystemEntity> files,
}) async {

  StreamController sc = StreamController<FileSystemEvent>();

  List<String> watchDirs = [];

  for ( var file in files ) {
    if ( ! watchDirs.contains( file.parent.path ) ) {
      file.parent.watch( events: FileSystemEvent.all ).listen( sc.sink.add );
      print( 'Watching: ${file.parent.path}' );
      watchDirs.add( file.parent.path );
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

      final newFiles = Directory.current
          .listSync(recursive: true)
          .where((item) {
            return item is File && item.path.endsWith( '.config.yaml' );
          })
          .toList();

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