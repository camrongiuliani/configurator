import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class ThemeWriter extends Writer {

  final String name;
  final YamlConfiguration _yamlConfiguration;

  ThemeWriter( String elementName, this._yamlConfiguration ) : name = 'Generated${elementName}ThemeExtension';

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( _buildConstructor() )
        ..name = name
        ..extend = refer( 'ConfigTheme<$name>' )
        ..methods.addAll([
          ..._buildColorFields(),
          ..._buildSizeFields(),
          _buildCopyWith(),
          _buildLerp(),
        ]);
    });
  }

  Constructor _buildConstructor() {
    return Constructor( ( cBuilder ) {
      cBuilder
        .optionalParameters.add( Parameter( ( builder ) {
          builder
            ..name = 'themeMap'
            ..required = true
            ..toSuper = true
            ..named = true;
        }) );
    });
  }

  List<Method> _buildColorFields() {
    return _yamlConfiguration.colors.map((e) {
      return Method( ( builder ) {
        builder
          ..type = MethodType.getter
          ..returns = refer('Color')
          ..name = '${( e.name as String )}Color'.canonicalize
          ..lambda = true
          ..body = Code( 'ColorParser.parse( themeMap[\'colors\']?[\'${( e.name as String ).canonicalize}\'] )' );
      });
    }).toList();
  }

  List<Method> _buildSizeFields() {
    return _yamlConfiguration.sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..type = MethodType.getter
          ..returns = refer('double')
          ..name = '${( e.name as String )}Size'.canonicalize
          ..lambda = true
          ..body = Code( 'themeMap[\'sizes\']?[\'${( e.name as String ).canonicalize}\']' );
      });
    }).toList();
  }

  Method _buildCopyWith() {
    return Method( ( builder ) {
      builder
        ..name = 'copyWith'
        ..returns = refer( name )
        ..annotations.add( refer( 'override' ) )
        ..optionalParameters.add( Parameter( ( builder ) {
          builder
            ..name = 'themeMap'
            ..type = refer( 'Map<String, Map<String, dynamic>>?' )
            ..named = true;
        }) )
        ..body = Block( ( builder ) {
          builder.statements.addAll([
            const Code( 'this.themeMap.addAll( themeMap ?? {} );' ),
            Code( 'return $name( themeMap: this.themeMap );' ),
          ]);
        });
    });
  }

  Method _buildLerp() {
    return Method( ( builder ) {
      builder
        ..name = 'lerp'
        ..returns = refer( name )
        ..annotations.add( refer( 'override' ) )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'other'
              ..type = refer( 'ThemeExtension<$name>?' );
          }),

          Parameter( ( builder ) {
            builder
              ..name = 't'
              ..type = refer( 'double' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll([
            Code( 'if ( other is! $name) {' ),
            const Code( 'return this;' ),
            const Code( '}' ),

            ..._yamlConfiguration.colors.map((e) {
              return Code( 'themeMap[\'colors\']![\'${( e.name as String ).canonicalize}Color\'] = ColorParser.colorToString( Color.lerp( ${( e.name as String ).canonicalize}Color, other.${( e.name as String ).canonicalize}Color, t )! );' );
            }),

            ..._yamlConfiguration.sizes.map((e) {
              return Code( 'themeMap[\'sizes\']![\'${( e.name as String ).canonicalize}Size\'] = lerpDouble( ${( e.name as String ).canonicalize}Size, other.${( e.name as String ).canonicalize}Size, t);' );
            }),

            Code( 'return $name( themeMap: themeMap );' ),
          ]);
        });
    });
  }
}