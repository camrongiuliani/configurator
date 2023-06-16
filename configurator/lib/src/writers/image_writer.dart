import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class ImageWriter extends Writer {

  final String name;
  final List<YamlSetting> _images;

  ImageWriter( String name, this._images )
      : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Images'
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
    return _images.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer( e.value is List ? 'List<String>' : 'String' )
          ..lambda = true
          ..body = Code( () {
            if ( useConfig ) {
              if ( e.value is List ) {
                return '_config.imageList( ${name}ConfigKeys.images.${e.name} )';
              }
              return '_config.image( ${name}ConfigKeys.images.${e.name} )';
            }

            return 'map[ ${name}ConfigKeys.images.${e.name} ] ?? \'/\'';
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
        ..name = '_ImageAccessor'
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