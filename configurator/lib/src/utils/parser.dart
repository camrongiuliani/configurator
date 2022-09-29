import 'dart:convert';
import 'package:configurator/src/models/yaml_configuration.dart';
import 'package:configurator/src/models/yaml_setting.dart';
import 'package:yaml/yaml.dart';

class YamlParser {

  static YamlConfiguration fromYamlString( String yamlString ) {
    // Convert to YamlDocument
    final YamlDocument document = loadYamlDocument( yamlString );

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
      routes: _processSettings( configNode, 'routes' ),
    );
  }

  static List<YamlSetting> _processSettings( YamlNode configNode, String type ) {
    List<YamlSetting> settings = [];

    try {

      final YamlNode settingsNode = configNode.value[ type ];

      if ( settingsNode is! YamlMap ) {
        return settings;
      }

      var str = jsonEncode( settingsNode );

      Map<String, dynamic> map = json.decode( str );

      for ( var setting in map.entries ) {
        settings.add( YamlSetting( setting.key, setting.value ) );
      }

    } catch ( e ) {
      print( e );
    }

    return settings;

  }

}