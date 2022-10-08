

import 'dart:io';

import 'package:test/test.dart';

import '../bin/configurator.dart';
import '../bin/graph.dart';

const String baseFile = './test/assets/parts/base.config.yaml';
const String partFile1 = './test/assets/parts/part1.config.yaml';
const String partFile2 = './test/assets/parts/part2.config.yaml';
const String partFile3 = './test/assets/parts/part3.config.yaml';
const String partFile4 = './test/assets/parts/part4.config.yaml';


void main() {

  group( 'flutter pub run tests', () {

    test('add edge', () {
      final graph = Graph<int?>();

      // graph.addEdge(1, 2);
      graph.addEdge(1, null);

      var a = graph.from(1);

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

    test( 'ext', () {

      var base = File( baseFile ).readAsStringSync();
      var part1 = File( partFile1 ).readAsStringSync();
      var part2 = File( partFile2 ).readAsStringSync();
      var part3 = File( partFile3 ).readAsStringSync();
      var part4 = File( partFile4 ).readAsStringSync();

      DartScriptGen.execute([
        '--id-filter=base,part1,part2,part3,part4',
      ]);

    });

  });

}