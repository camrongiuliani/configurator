import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class WeightWriter extends Writer {

  final String name;
  final int weight;

  WeightWriter( String name, this.weight )
      : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Weight'
        ..methods.addAll([
          _getWeightMap(),
          _getWeightGetter(),
        ]);
    });

    lb.body.add( scope );

    // Class config = _buildAccessor();
    //
    // lb.body.add( config );

    return lb.build();

  }

  Method _getWeightGetter([ bool useConfig = false ]) {
    return Method( ( builder ) {
      builder
        ..name = 'weight'
        ..type = MethodType.getter
        ..returns = refer( 'int' )
        ..lambda = true
        ..body = Code( () {
          if ( useConfig ) {
            return '_config.weight( ${name}ConfigKeys.weight )';
          }

          return 'map[ ${name}ConfigKeys.weight ] ?? 0';
        }() );
    });
  }

  Method _getWeightMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, int>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, String> map = {};

          map['${name}ConfigKeys.weight.weight'] = '$weight';

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
        ..name = '_WeightAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = '_config'
              ..type = refer( 'Configuration' )
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          _getWeightGetter( true ),
        ]);
    });
  }

}