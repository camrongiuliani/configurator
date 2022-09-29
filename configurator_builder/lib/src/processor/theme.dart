import 'dart:convert';
import 'package:configurator_builder/src/model/color.dart';
import 'package:configurator_builder/src/model/size.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:yaml/yaml.dart';

class ThemeProcessor extends Processor<ProcessedTheme> {

  final YamlNode node;

  ThemeProcessor( this.node );

  @override
  ProcessedTheme process() {

    var themeNode = node.value[ 'theme' ];

    if ( themeNode is! YamlMap ) {
      return ProcessedTheme( [], [] );
    }

    List<ProcessedSize> _sizes = _processSizes( themeNode.value[ 'sizes' ] );
    List<ProcessedColor> _colors = _processColors( themeNode.value[ 'colors' ] );

    return ProcessedTheme( _colors, _sizes );

  }

  List<ProcessedColor> _processColors( dynamic colors ) {
    List<ProcessedColor> _colors = [];

    try {

      if ( colors is! YamlMap ) {
        return _colors;
      }

      var str = jsonEncode( colors );

      Map<String,dynamic> colorMap = json.decode( str );

      for ( var spec in colorMap.entries ) {
        _colors.add( ProcessedColor( spec.key, spec.value ) );
      }

    } catch ( e ) {
      print( e );
    }

    return _colors;

  }

  List<ProcessedSize> _processSizes( dynamic sizes ) {
    List<ProcessedSize> _sizes = [];

    try {

      if ( sizes is! YamlMap ) {
        return _sizes;
      }

      var str = jsonEncode( sizes );

      Map<String,dynamic> sizeMap = json.decode( str );

      for ( var spec in sizeMap.entries ) {
        _sizes.add( ProcessedSize( spec.key, spec.value ) );
      }

    } catch ( e ) {
      print( e );
    }

    return _sizes;

  }
}