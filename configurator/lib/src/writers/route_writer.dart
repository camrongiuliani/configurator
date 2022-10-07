import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class RouteWriter extends Writer {

  final String name;
  final List<YamlRoute> _routes;

  RouteWriter( String name, this._routes )
      : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Routes'
        ..methods.addAll([
          _getValuesMap(),
          ..._getGetters(),
        ]);
    });

    lb.body.add( scope );

    Class config = _buildAccessor();

    lb.body.add( config );

    return lb.build();
  }

  List<Method> _getGetters([ bool useConfig = false ]) {
    return _routes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.path.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.route( ${name}ConfigKeys.routes.${e.path.canonicalize} )';
            }

            return 'map[ ${name}ConfigKeys.routes.${e.path.canonicalize} ] ?? \'/\'';
          }() );
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
            map['${name}ConfigKeys.routes.${f.path.canonicalize}'] = '\'${f.path}\'';
          }

          return map.toString();
        }() );
    });
  }

  Class _buildAccessor() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) {
          b
            ..constant = true
            ..requiredParameters.addAll([
              Parameter( ( b ) {
                b
                  ..name = '_config'
                  ..toThis = true;
              }),
            ]);
        }) )
        ..name = '_RouteAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = '_config'
              ..type = refer( 'Configuration' )
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getGetters( true ),
        ]);
    });
  }
}