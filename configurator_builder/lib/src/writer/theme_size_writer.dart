import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class ThemeSizeWriter extends Writer {

  final ProcessedTheme _theme;

  ThemeSizeWriter( this._theme );

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_ThemeSizes'
        ..methods.addAll([
          _getSizeValuesMap(),
          ..._getSizeGetters(),
        ]);
    });
  }

  List<Method> _getSizeGetters() {
    return _theme.sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.key.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'double' )
          ..lambda = true
          ..body = Code( 'map[ ConfigKeys.theme.size.${e.key.canonicalize} ] ?? 0.0' );
      });
    }).toList();
  }

  Method _getSizeValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, double>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, double> map = {};

          for ( var f in _theme.sizes ) {
            map['ConfigKeys.theme.size.${f.key.canonicalize}'] = f.size;
          }

          return map.toString();
        }() );
    });
  }


}