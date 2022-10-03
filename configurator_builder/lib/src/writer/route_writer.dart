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
          ..name = e.value.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.route( ${name}ConfigKeys.routes.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.routes.${e.name} ] ?? \'/\'';
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
            map['${name}ConfigKeys.routes.${f.value.canonicalize}'] = '\'${f.value}\'';
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