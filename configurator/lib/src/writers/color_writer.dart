import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class ColorWriter extends Writer {

  final String name;
  final List<YamlSetting<String, String>> _colors;

  ColorWriter( String name, List<YamlSetting> colors )
      : name = name.canonicalize.capitalized,
        _colors = colors.convert<String, String>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Colors'
        ..methods.addAll([
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
              return '_config.colorValue( ${name}ConfigKeys.colors.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.colors.${e.name.canonicalize} ] ?? \'\'';
          }() );
      });
    }).toList();
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
        ..name = '_ColorAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = '_config'
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