import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class RouteWriter extends Writer {

  final String name;
  final List<YamlSetting<int, String>> _routes;

  RouteWriter( String name, List<YamlSetting> _routes )
      : name = name.canonicalize.capitalized,
        _routes = _routes.convert<int, String>();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Routes'
        ..methods.addAll([
          _getValuesMap(),
          ..._getGetters(),
        ]);
    });
  }

  List<Method> _getGetters() {
    return _routes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.value.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( 'map[ ${name}ConfigKeys.routes.${e.value.canonicalize} ] ?? \'/\'');
      });
    }).toList();
  }

  Method _getValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<int, String>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, String> map = {};

          for ( var f in _routes ) {
            map['${name}ConfigKeys.routes.${f.value.canonicalize}'] = '\'${f.value}\'';
          }

          return map.toString();
        }() );
    });
  }
}