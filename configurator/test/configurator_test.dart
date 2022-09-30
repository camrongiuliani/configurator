
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

  group( 'Scope From Yaml Tests', () {
    test( 'Scope From Invalid Yaml Throws', () {
      expect( () => ConfigScope.fromYaml( '' ), invalidYamlMatcher );
    });

    test( 'Scope From Valid Yaml Returns', () {
      var m = File( testYaml1 ).readAsStringSync();
      expect( () => ConfigScope.fromYaml( m ), returnsNormally );
    });

    test( 'Scope From Valid Yaml Matches Parser', () {
      var m = File( testYaml1 ).readAsStringSync();

      var scope = ConfigScope.fromYaml( m );
      var config = YamlParser.fromYamlString( m );

      var scopeMap = {
        'flags': { for (var e in scope.flags.entries) e.key : e.value },
        'images': { for (var e in scope.images.entries) e.key : e.value },
        'routes': { for (var e in scope.routes.entries) e.key : e.value },
        'sizes': { for (var e in scope.sizes.entries) e.key : e.value },
        'colors': { for (var e in scope.colors.entries) e.key : e.value },
      };

      var configMap = {
        'flags': { for (var e in config.flags) e.name : e.value },
        'images': { for (var e in config.images) e.name : e.value },
        'routes': { for (var e in config.routes) e.name : e.value },
        'sizes': { for (var e in config.sizes) e.name : e.value },
        'colors': { for (var e in config.colors) e.name : e.value },
      };

      expect( scopeMap, equals( configMap ) );
    });
  });

  group( 'Yaml Load Tests', () {

    test( 'tryParse Does Not Throw', () {
      expect( () {
        YamlParser.tryParse( null );
      }, returnsNormally );
    });

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
