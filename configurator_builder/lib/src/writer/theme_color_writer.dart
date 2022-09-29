import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class ThemeColorWriter extends Writer {

  final ProcessedTheme _theme;

  ThemeColorWriter( this._theme );

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_ThemeColors'
        ..methods.addAll([
          _getColorValuesMap(),
          ..._getColorGetters(),
        ]);
    });
  }

  List<Method> _getColorGetters() {
    return _theme.colors.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.key.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( 'map[ ConfigKeys.theme.color.${e.key.canonicalize} ] ?? \'\'' );
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

          for ( var f in _theme.colors ) {
            map['ConfigKeys.theme.color.${f.key.canonicalize}'] = '\'${f.color}\'';
          }

          return map.toString();
        }() );
    });
  }


}