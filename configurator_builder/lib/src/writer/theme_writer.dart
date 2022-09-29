import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/writer/theme_color_writer.dart';
import 'package:configurator_builder/src/writer/theme_size_writer.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class ThemeWriter extends Writer {

  final ProcessedTheme _theme;

  ThemeWriter( this._theme );

  @override
  Spec write() {

    LibraryBuilder lb = LibraryBuilder();

    Class themeClass = Class( ( builder ) {
      builder
        ..constructors.add( _buildConstructor() )
        ..name = 'GeneratedConfigTheme'
        ..extend = refer( 'ThemeExtension<GeneratedConfigTheme>' )
        ..fields.add( _buildThemeField() )
        ..methods.addAll([
          ..._buildColorFields(),
          ..._buildSizeFields(),
          _buildCopyWith(),
          _buildLerp(),
        ]);
    });

    lb..body.addAll([
      ThemeColorWriter( _theme ).write(),
      ThemeSizeWriter( _theme ).write(),
      themeClass,
    ]);

    return lb.build();
  }

  Constructor _buildConstructor() {
    return Constructor( ( cBuilder ) {
      cBuilder
        ..optionalParameters.add( Parameter( ( builder ) {
          builder
            ..name = 'themeMap'
            ..required = true
            ..toThis = true
            ..named = true;
        }) );
    });
  }

  Field _buildThemeField() {
    return Field( ( builder ) {
      builder
        ..name = 'themeMap'
        ..type = refer( 'Map<String, Map<String, dynamic>>' )
        ..modifier = FieldModifier.final$;
    });
  }

  List<Method> _buildColorFields() {
    return _theme.colors.map((e) {
      return Method( ( builder ) {
        builder
          ..type = MethodType.getter
          ..returns = refer('Color')
          ..name = e.key.canonicalize
          ..lambda = true
          ..body = Code( 'ColorUtil.parseColorValue( themeMap[\'colors\']?[\'${e.key.canonicalize}\'] )' );
      });
    }).toList();
  }

  List<Method> _buildSizeFields() {
    return _theme.sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..type = MethodType.getter
          ..returns = refer('double')
          ..name = e.key.canonicalize
          ..lambda = true
          ..body = Code( 'themeMap[\'sizes\']?[\'${e.key.canonicalize}\']' );
      });
    }).toList();
  }

  Method _buildCopyWith() {
    return Method( ( builder ) {
      builder
        ..name = 'copyWith'
        ..returns = refer( 'GeneratedConfigTheme' )
        ..annotations.add( refer( 'override' ) )
        ..optionalParameters.add( Parameter( ( builder ) {
          builder
            ..name = 'themeMap'
            ..type = refer( 'Map<String, Map<String, dynamic>>?' )
            ..named = true;
        }) )
        ..body = Block( ( builder ) {
          builder..statements.addAll([
            Code( 'this.themeMap.addAll( themeMap ?? {} );' ),
            Code( 'return GeneratedConfigTheme( themeMap: this.themeMap );' ),
          ]);
        });
    });
  }

  Method _buildLerp() {
    return Method( ( builder ) {
      builder
        ..name = 'lerp'
        ..returns = refer( 'GeneratedConfigTheme' )
        ..annotations.add( refer( 'override' ) )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'other'
              ..type = refer( 'ThemeExtension<GeneratedConfigTheme>?' );
          }),

          Parameter( ( builder ) {
            builder
              ..name = 't'
              ..type = refer( 'double' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder..statements.addAll([
            Code( 'if ( other is! GeneratedConfigTheme) {' ),
            Code( 'return this;' ),
            Code( '}' ),

            ..._theme.colors.map((e) {
              return Code( 'themeMap[\'colors\']![\'${e.key.canonicalize}\'] = ColorUtil.colorToString( Color.lerp( ${e.key.canonicalize}, other.${e.key.canonicalize}, t )! );' );
            }),

            ..._theme.sizes.map((e) {
              return Code( 'themeMap[\'sizes\']![\'${e.key.canonicalize}\'] = lerpDouble( ${e.key.canonicalize}, other.${e.key.canonicalize}, t);' );
            }),

            Code( 'return GeneratedConfigTheme( themeMap: themeMap );' ),
          ]);
        });
    });
  }
}