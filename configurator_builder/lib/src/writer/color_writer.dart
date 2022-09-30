import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';

class ColorWriter extends Writer {

  final String name;
  final List<YamlSetting<String, String>> _colors;

  ColorWriter( String name, List<YamlSetting> _colors )
      : name = name.canonicalize,
        _colors = _colors.convert<String, String>();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Colors'
        ..methods.addAll([
          _getColorValuesMap(),
          ..._getColorGetters(),
        ]);
    });
  }

  List<Method> _getColorGetters() {
    return _colors.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( 'map[ ${name}ConfigKeys.colors.${e.name.canonicalize} ] ?? \'\'' );
      });
    }).toList();
  }

  Method _getColorValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, String>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, String> map = {};

          for ( var f in _colors ) {
            map['${name}ConfigKeys.colors.${f.name.canonicalize}'] = '\'${f.value}\'';
          }

          return map.toString();
        }() );
    });
  }


}