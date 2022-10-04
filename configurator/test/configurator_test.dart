
import 'dart:async';
import 'dart:io';

import 'package:configurator/configurator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

Matcher invalidYamlMatcher = throwsA( const TypeMatcher<InvalidYamlException>() );

const String testYaml1 = './test/assets/test_1.yaml';
const String testYaml1de = './test/assets/test_1_de.yaml';
const String badIdYaml = './test/assets/bad_id.yaml';
const String missingIdYaml = './test/assets/bad_id.yaml';
const String badConfigYaml = './test/assets/bad_config.yaml';

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

  group( 'Configuration Tests', () {

    test( 'Configuration Get Value Test (Single Scope)', () {
      var m = File( testYaml1 ).readAsStringSync();
      var scope = ConfigScope.fromYaml( m );
      Configuration config = Configuration( scopes: [ scope ] );

      for ( var rootEntry in scope.toJson().entries ) {
        for ( var v in rootEntry.value.entries ) {
          if ( rootEntry.key == 'flags' ) {
            expect( config.flag( v.key ), equals( v.value ) );
          }
          if ( rootEntry.key == 'colors' ) {
            expect( config.color( v.key ), equals( v.value ) );
          }
          if ( rootEntry.key == 'routes' ) {
            expect( config.route( v.key ), equals( v.value ) );
          }
          if ( rootEntry.key == 'images' ) {
            expect( config.image( v.key ), equals( v.value ) );
          }
          if ( rootEntry.key == 'sizes' ) {
            expect( config.size( v.key ), equals( v.value ) );
          }
        }
      }
    });

    test( 'Configuration Scope Override/Fallthrough Test ', () {
      var m = File( testYaml1 ).readAsStringSync();
      var scope = ConfigScope.fromYaml( m );

      var scopeO = ProxyScope(
        name: 'overrides',
        colors: {
          'primary': "FFFFFF"
        },
      );

      Configuration config = Configuration( scopes: [ scope, scopeO ] );

      expect( config.color( 'secondary' ), equals( scope.colors['secondary'] ));
      expect( config.color( 'primary' ), equals( scopeO.colors['primary'] ));

      var scopeO2 = ProxyScope(
        name: 'overrides',
        colors: {
          'secondary': "FFFFFF"
        },
      );

      config.pushScope( scopeO2 );

      expect( config.color( 'secondary' ), equals( scopeO2.colors['secondary'] ));
      expect( config.color( 'primary' ), equals( scopeO.colors['primary'] ));

    });
  });

  group( 'Configuration Scope Checks', () {

    test( 'Configuration Add Scope Completes', () {
      expect( () {
        var s1 = ProxyScope(name: 'test');
        var s2 = ProxyScope(name: 'test2');
        var c = Configuration( scopes: [ s1 ] );
        assert( c.scopes.length == 1 );
        c.pushScope( s2 );
        assert( c.scopes.length == 2 );
      }, isNot( throwsA(AssertionError) ) );
    });

    test( 'ChangeNotifier Test Push/Pop Firing', () async {
      var s1 = ProxyScope(name: 'test');
      var s2 = ProxyScope(name: 'test2');
      var c = Configuration( scopes: [ s1 ] );

      Completer<int> completer = Completer();

      c.changeNotifier.watch().first.then((value) {

        expect( value.scopes.length, equals( 2 ) );

        c.changeNotifier.watch().first.then((value) {
          completer.complete( value.scopes.length );
        });
        c.popScope();
      });

      c.pushScope( s2 );

      await expectLater( completer.future, completion( equals( 1 ) ) );
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

      expect( scope.toJson(), equals( config.toJson() ) );
    });

    test( 'Scope.toJson equals Config.themeMap', () {
      var m = File( testYaml1 ).readAsStringSync();

      var scope = ConfigScope.fromYaml( m );
      var scopeJson = scope.toJson();
      scopeJson.remove( 'routes' ); // TODO: Handle routes

      Configuration config = Configuration( scopes: [ scope ] );

      expect( scopeJson, equals( config.themeMap ) );
    });
  });

  group( 'Yaml Load Tests', () {

    test( 'tryParse Does Not Throw', () {
      expect( () {
        YamlParser.tryParse( null );
      }, returnsNormally );
    });

    test( 'Split Yaml Reduce Test', () {
      expect( () {
        var m1 = File( testYaml1 ).readAsStringSync();
        var m2 = File( testYaml1de ).readAsStringSync();

        List<YamlConfiguration> configs = [m1, m2].map((e) => YamlParser.fromYamlString( e ) ).toList();

        return configs.reduce((value, element) => value + element );
      }, isNotNull );
    });

    test( 'Yaml Route Test', () {
      var m1 = File( testYaml1 ).readAsStringSync();

      var scope = ConfigScope.fromYaml( m1 );

      Configuration config = Configuration( scopes: [ scope ] );

      expect( config.route( 1 ), equals( '/master' ) );
      expect( config.route( 2 ), equals( '/master/detail' ) );
      expect( config.route( 3 ), equals( '/master/detail/info' ) );
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

      // Bad ID key throws
      expect( () {
        var m = File( badIdYaml ).readAsStringSync();
        YamlParser.fromYamlString( m );
      }, invalidYamlMatcher );

      // Empty ID throws
      expect( () {
        var m = File( missingIdYaml ).readAsStringSync();
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

      // Bad Configuration key throws
      expect( () {
        var m = File( badConfigYaml ).readAsStringSync().replaceAll('configuration:', 'dd:');
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
