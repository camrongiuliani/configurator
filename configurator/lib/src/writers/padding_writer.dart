import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class PaddingWriter extends Writer {

  final String name;
  final List<YamlSetting<String, double>> _sizes;

  PaddingWriter( String name, List<YamlSetting> sizes )
      : name = name.canonicalize.capitalized.capitalized,
        _sizes = sizes.convert<String, double>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope =  Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Padding'
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
    return _sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'double' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.padding( ${name}ConfigKeys.padding.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.padding.${e.name} ] ?? 0.0';
          }() );
      });
    }).toList();
  }

  Method _getValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, double>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, double> map = {};

          for ( var f in _sizes ) {
            map['${name}ConfigKeys.padding.${f.name.canonicalize}'] = f.value;
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
        ..name = '_PaddingAccessor'
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