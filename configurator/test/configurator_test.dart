
import 'dart:io';

import 'package:configurator/configurator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

Matcher invalidYamlMatcher = throwsA( const TypeMatcher<InvalidYamlException>() );

const String testYaml1 = './test/assets/test_1.yaml';

void main() {

  group( 'Configuration Creation Checks', () {

    test( 'Configuration Can Create Without Scope', () {
      expect( () async {
        return Configuration();
      }(), completes );
    });

    test( 'Configuration Created Without Scopes Contains Default', () {
      expect( () {
        return Configuration().scopes[0] is ProxyScope;
      }(), equals( true ) );
    });

    test( 'Configuration Can Create With Scopes', () {
      expect( () async {
        return Configuration(
          scopes: [
            ProxyScope(name: 'test'),
          ]
        );
      }(), completes );
    });

    test( 'Configuration Created With Scopes Has No Default', () {
      expect( () {
        var s1 = ProxyScope(name: 'test');
        var c = Configuration( scopes: [ s1 ] );
        return c.scopes.length == 1 && c.scopes[0].name == 'test';
      }(), equals( true ) );
    });
  });

  group( 'Yaml Load Tests', () {

    test( 'Invalid Yaml Throws', () {

      // Empty Yaml Throws
      expect( () {
        YamlParser.fromYamlString( '' );
      }, invalidYamlMatcher );

      // Malformed Yaml Throws
      expect( () {
        YamlParser.fromYamlString( '{dd' );
      }, invalidYamlMatcher );

      // List Throws
      expect( () {
        YamlParser.fromYamlString( '[]' );
      }, invalidYamlMatcher );

      // Empty Map Throws
      expect( () {
        YamlParser.fromYamlString( '{}' );
      }, invalidYamlMatcher );

      // Missing ID key throws
      expect( () {
        var m = File( testYaml1 ).readAsStringSync().replaceAll('id:', 'i:');
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );

      // Empty ID throws
      expect( () {
        var m = File( testYaml1 ).readAsStringSync().replaceAll('id: app_scope', 'id: ');
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );

      // Int ID throws
      expect( () {
        var m = File( testYaml1 ).readAsStringSync().replaceAll('id: app_scope', 'id: 1');
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );

      // Missing Configuration key throws
      expect( () {
        var m = File( testYaml1 ).readAsStringSync().replaceAll('configuration:', 'dd:');
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );

      // Duplicate key throws
      expect( () {
        var m = File( testYaml1 ).readAsStringSync().replaceAll('configuration:', 'id:');
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );
    });

    test( 'Can Load Test Yaml', () {
      var x = File( testYaml1 ).readAsStringSync();
      expect( x, isNotNull );
    });

    test( 'Test Yaml Parcelable', () {
      var x = File( testYaml1 ).readAsStringSync();
      expect( () => loadYamlDocument( x ), returnsNormally );
    });

    test( 'Test Yaml Parcelable and Valid', () {
      var x = File( testYaml1 ).readAsStringSync();
      var doc = loadYamlDocument( x );

      expect( doc.contents, isNotNull );
      expect( doc.contents.value, isNotNull );
      expect( doc.contents.value, isA<YamlMap>() );
      expect( doc.contents.value['configuration'], isNotNull );
      expect( doc.contents.value['configuration'], isA<YamlMap>() );
      expect( doc.contents.value['id'], isNotNull );
      expect( doc.contents.value['id'], isA<String>() );
    });

  });
}
