import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class MiscWriter extends Writer {

  final String name;
  final List<YamlSetting<String, dynamic>> _settings;

  MiscWriter( String name, List<YamlSetting> settings )
      : name = name.canonicalize.capitalized,
        _settings = settings.convert<String, dynamic>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Misc'
        ..methods.addAll([
          ..._getGetters(),
        ]);
    });

    lb.body.add( scope );

    Class config = _buildAccessor();

    lb.body.add( config );

    return lb.build();

  }

  List<Method> _getGetters([ bool useConfig = false ]) {
    return _settings.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'dynamic' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              return '_config.misc( ${name}ConfigKeys.misc.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.misc.${e.name.canonicalize} ]';
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
        ..name = '_MiscAccessor'
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