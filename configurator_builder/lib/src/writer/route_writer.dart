import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class RouteWriter extends Writer {

  final List<ProcessedRoute> _routes;

  RouteWriter( this._routes );

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
          ..name = e.path.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( 'map[ ConfigKeys.routes.${e.path.canonicalize} ] ?? \'/\'');
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
            map['ConfigKeys.routes.${f.path.canonicalize}'] = '\'${f.path}\'';
          }

          return map.toString();
        }() );
    });
  }
}