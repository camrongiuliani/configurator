import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';

class ColorWriter extends Writer {

  final String name;
  final List<YamlSetting<String, String>> _colors;

  ColorWriter( String name, List<YamlSetting> _colors )
      : name = name.canonicalize.capitalized,
        _colors = _colors.convert<String, String>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Colors'
        ..methods.addAll([
          _getColorValuesMap(),
          ..._getColorGetters(),
        ]);
    });

    lb.body.add( scope );

    Class config = _buildAccessor();

    lb.body.add( config );

    return lb.build();

  }

  List<Method> _getColorGetters([ bool useConfig = false ]) {
    return _colors.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( useConfig ? 'Color' : 'String' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return 'config.colorValue( ${name}ConfigKeys.colors.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.colors.${e.name.canonicalize} ] ?? \'\'';
          }() );
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

  Class _buildAccessor() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) {
          b
            ..constant = true
            ..requiredParameters.addAll([
              Parameter( ( b ) {
                b
                  ..name = 'config'
                  ..toThis = true;
              }),
            ]);
        }) )
        ..name = '_ColorAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = 'config'
              ..type = refer( 'Configuration' )
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getColorGetters( true ),
        ]);
    });
  }

}