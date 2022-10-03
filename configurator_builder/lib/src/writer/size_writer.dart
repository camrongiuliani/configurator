import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class SizeWriter extends Writer {

  final String name;
  final List<YamlSetting<String, double>> _sizes;

  SizeWriter( String name, List<YamlSetting> _sizes )
      : name = name.canonicalize.capitalized.capitalized,
        _sizes = _sizes.convert<String, double>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope =  Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Sizes'
        ..methods.addAll([
          _getSizeValuesMap(),
          ..._getSizeGetters(),
        ]);
    });

    lb.body.add( scope );

    Class config = _buildAccessor();

    lb.body.add( config );

    return lb.build();
  }

  List<Method> _getSizeGetters([ bool useConfig = false ]) {
    return _sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'double' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.size( ${name}ConfigKeys.sizes.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.sizes.${e.name} ] ?? 0.0';
          }() );
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

          for ( var f in _sizes ) {
            map['${name}ConfigKeys.sizes.${f.name.canonicalize}'] = f.value;
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
        ..name = '_SizeAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = '_config'
              ..type = refer( 'Configuration' )
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getSizeGetters( true ),
        ]);
    });
  }
}