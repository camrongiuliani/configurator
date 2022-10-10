

import 'dart:io';

import 'package:test/test.dart';

import '../bin/configurator.dart';
import '../bin/graph.dart';

const String baseFile = './test/assets/parts/base.config.yaml';
const String partFile1 = './test/assets/parts/part1.config.yaml';
const String partFile2 = './test/assets/parts/part2.config.yaml';
const String partFile3 = './test/assets/parts/part3.config.yaml';
const String partFile4 = './test/assets/parts/part4.config.yaml';

extension ConvExt on String {
  get yaml2dart => replaceAll('.yaml', '.dart');
}

void main() {

  group( 'flutter pub run tests', () {

    test('Graph Add Edge Test', () {
      final graph = Graph<int?>();

      graph.addEdge(1, 2);
      expect(graph.from(1), {2});
      expect(graph.to(2), {1});

      graph.addEdge(2, 3);
      expect(graph.from(2), {3});
      expect(graph.to(3), {2});

      graph.addEdge(1, 3);
      expect(graph.from(1), {2, 3});
      expect(graph.to(2), {1});
      expect(graph.to(3), {1, 2});

      graph.addEdge(1, 3); // Exist edge
      expect(graph.from(1), {2, 3});
      expect(graph.to(2), {1});
      expect(graph.to(3), {1, 2});
    });

    test( 'DartScriptGen.execute Builds Correctly', () async {

      var base = File( baseFile.yaml2dart );
      var part1 = File( partFile1.yaml2dart );
      var part2 = File( partFile2.yaml2dart );
      var part3 = File( partFile3.yaml2dart );
      var part4 = File( partFile4.yaml2dart );

      void deleteFiles() {
        for ( var file in [ base, part1, part2, part3, part4 ] ) {
          if ( file.existsSync() ) {
            file.deleteSync();
          }
        }
      }

      deleteFiles();

      await DartScriptGen.execute([
        '--id-filter=base,part1,part2,part3,part4',
      ]);

      expect( base.existsSync(), isTrue );
      expect( part1.existsSync(), isFalse );
      expect( part2.existsSync(), isFalse );
      expect( part3.existsSync(), isFalse );
      expect( part4.existsSync(), isFalse );

      deleteFiles();

    });

  });

}