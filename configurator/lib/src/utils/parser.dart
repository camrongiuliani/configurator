import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:yaml/yaml.dart';

class InvalidYamlException implements Exception {

  final dynamic message;

  InvalidYamlException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "InvalidYamlException";
    return "InvalidYamlException: $message";
  }
}

class YamlParser {

  static YamlConfiguration? tryParse( String? yamlString ) {
    try {
      return fromYamlString( yamlString );
    } catch ( e ) {
      print( e );
    }
    return null;
  }

  static YamlConfiguration fromYamlString( String? yamlString ) {

    // Convert to YamlDocument (with validation)
    final YamlDocument document = _validate( yamlString )!;

    // Get the root node
    final YamlNode rootNode = document.contents;

    final YamlNode configNode = rootNode.value['configuration'];
    final String id = rootNode.value['id'];

    return YamlConfiguration(
      name: id,
      flags: _processSettings( configNode, 'flags' ),
      colors: _processSettings( configNode, 'colors' ),
      images: _processSettings( configNode, 'images' ),
      sizes: _processSettings( configNode, 'sizes' ),
      routes: _processRoutes( configNode, 'routes' ),
      strings: _processTranslations( configNode, 'strings' ),
    );
  }

  static List<YamlSetting> _processSettings( YamlNode configNode, String type ) {
    List<YamlSetting> settings = [];

    try {

      final settingsNode = configNode.value[ type ];

      if ( settingsNode is! YamlMap ) {
        return settings;
      }

      var str = jsonEncode( settingsNode );

      Map<String, dynamic> map = json.decode( str );

      for ( var setting in map.entries ) {
        if ( setting.value is Map ) {
          List<YamlSetting> ns = _getSettingNamespaces( setting.value, [], setting.key );

          if ( ns.isNotEmpty ) {
            settings.addAll( ns );
          }
        } else {
          settings.add( YamlSetting( setting.key, setting.value ) );
        }
      }

    } catch ( e ) {
      print( e );
    }

    return settings;

  }

  static List<YamlRoute> _processRoutes( YamlNode configNode, String type ) {
    List<YamlRoute> routes = [];

    try {

      final settingsNode = configNode.value[ type ];

      if ( settingsNode is! YamlList ) {
        return routes;
      }

      var str = jsonEncode( settingsNode );

      List<dynamic> list = json.decode( str );

      for ( var route in list ) {

        var processed = YamlRoute.fromJson( route );

        routes.add( processed );

        for ( var c in _getChildren( processed, [] ) ) {
          routes.add( c );
        }}

    } catch ( e ) {
      print( e );
    }

    return routes;

  }

  static List<YamlSetting> _getSettingNamespaces( Map<String, dynamic> setting, List<YamlSetting> result, String path ) {
    for ( var es in setting.entries ) {

      if ( es.value is Map ) {
        return _getSettingNamespaces( es.value, result, '${path.capitalized}_${es.key.capitalized}'.canonicalize );
      } else {
        result.add( YamlSetting( '${path.capitalized}_${es.key.capitalized}'.canonicalize, es.value ) );
      }
    }

    return result;
  }

  static List<YamlRoute> _getChildren( YamlRoute route, List<YamlRoute> result ) {
    for ( YamlRoute c in route.children ) {
      result.add( c );

      if ( c.children.isNotEmpty ) {
        return _getChildren( c, result );
      }
    }

    return result;
  }

  static List<YamlI18n> _processTranslations( YamlNode configNode, String type ) {
    List<YamlI18n> translations = [];

    try {

      final YamlNode translationsNode = configNode.value[ type ];

      if ( translationsNode is! YamlMap ) {
        return translations;
      }

      var str = jsonEncode( translationsNode );

      Map<String, dynamic> translationsMap = json.decode( str );

      for ( var t in translationsMap.entries ) {
        var values = t.value.entries.map( ( v ) => YamlI18n( v.key, t.key, v.value) );
        translations.addAll( List.from(values) );
      }

    } catch ( e ) {
      print( e );
    }

    return translations;

  }

  static void _validateContents( YamlDocument document ) {
    final YamlNode rootNode = document.contents;

    if ( rootNode.value == null ) {
      throw InvalidYamlException('rootNode value was null.');
    }

    if ( rootNode.value == null || rootNode.value is! YamlMap ) {
      throw InvalidYamlException('rootNode.value was ${rootNode.value?.runtimeType}, expected YamlMap');
    }

    if ( ! ( rootNode.value as YamlMap ).containsKey( 'configuration' ) ) {
      throw InvalidYamlException('No "configuration" key exists');
    } else if ( ( rootNode.value as YamlMap )['configuration'] is! YamlMap ) {
      throw InvalidYamlException('configuration.value was ${( rootNode.value as YamlMap )['configuration']?.runtimeType}, expected YamlMap');
    }

    if ( ! ( rootNode.value as YamlMap ).containsKey( 'id' ) ) {
      throw InvalidYamlException('No "id" key exists');
    } else if ( ( rootNode.value as YamlMap )['id'] is! String ) {
      throw InvalidYamlException('Invalid ID specified. Must be non-empty value of type String');
    }

  }

  static YamlDocument? _validate( String? yamlString ) {
    // First step validation (not empty or null)
    _inputValidate( yamlString );

    // Ensure the input can be decoded with convert.dart
    dynamic decoded = _decodeValidate( yamlString );

    // Ensure decoded value is not empty map
    _notEmptyMapValidate( decoded );

    // Ensure package:yaml is able to convert to YamlDocument
    YamlDocument document = _loadYamlValidate( yamlString! );

    // Ensure the contents of the document include the required fields.
    _validateContents( document );

    return document;
  }

  static YamlDocument _loadYamlValidate( String yamlString ) {
    try {
      return loadYamlDocument( yamlString );
    } on Exception catch( e ) {
      throw InvalidYamlException('Unable to loadYamlDocument: ${e.toString()}');
    }
  }

  static void _inputValidate( String? yamlString ) {
    if ( yamlString == null ) {
      throw InvalidYamlException('input was null');
    }

    if ( yamlString.isEmpty ) {
      throw InvalidYamlException('input was empty');
    }
  }

  static dynamic _decodeValidate( String? yamlString ) {
    try {
      return jsonDecode( jsonEncode( loadYamlNode(yamlString!) ) );
    } on Exception catch( e ) {
      throw InvalidYamlException( 'Unable to decode input into JSON: ${e.toString()}' );
    }
  }

  static void _notEmptyMapValidate( dynamic x ) {
    if ( x is! Map || x.isEmpty ) {
      throw InvalidYamlException( 'Input was not decoded into a map. Was: ${x?.runtimeType}' );
    } else if ( x.isEmpty ) {
      throw InvalidYamlException( 'Input was an empty map.' );
    }
  }

}