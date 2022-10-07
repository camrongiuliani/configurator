import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class FlagWriter extends Writer {

  final String name;
  final List<YamlSetting<String, bool>> _flags;

  FlagWriter( String name, List<YamlSetting> flags )
      : name = name.canonicalize.capitalized,
        _flags = flags.convert<String, bool>();

  @override
  Spec write() {

    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Flags'
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
    return _flags.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer( 'bool' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.flag( ${name}ConfigKeys.flags.${e.name} ) == true';
            }

            return 'map[ ${name}ConfigKeys.flags.${e.name} ] == true';
          }() );
      });
    }).toList();
  }

  Method _getValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, bool>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, bool> map = {};

          for ( var f in _flags ) {
            map['${name}ConfigKeys.flags.${f.name}'] = f.value;
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
        ..name = '_FlagAccessor'
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