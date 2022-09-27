import 'dart:convert';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:yaml/yaml.dart';

class SettingProcessor extends Processor<List<ProcessedSetting>> {

  final YamlNode node;
  final String key;

  SettingProcessor( this.node, this.key );

  @override
  List<ProcessedSetting> process() {
    List<ProcessedSetting> _settings = [];

    try {

      var nodeValue = node.value[ key ];

      if ( nodeValue is! YamlMap ) {
        return _settings;
      }

      var str = jsonEncode( nodeValue );

      Map<String, dynamic> map = json.decode( str );

      for ( var flag in map.entries ) {
        _settings.add( ProcessedSetting( flag.key, flag.value ) );
      }

    } catch( e ) {
      print( e );
    }

    return _settings;

  }
}