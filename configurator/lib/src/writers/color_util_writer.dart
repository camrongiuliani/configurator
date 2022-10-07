import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

class ColorUtilWriter extends Writer {

  ColorUtilWriter();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..name = '_ColorUtil'
        ..methods.addAll([
          _buildHexColorConverter(),
          _buildRGBColorConverter(),
          _buildColorToStringConverter(),
          _buildColorValueParser(),
        ]);
    });
  }

  Method _buildHexColorConverter() {
    return Method( ( builder ) {
      builder
        ..name = '_colorFromHex'
        ..static = true
        ..returns = refer( 'Color' )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'input'
              ..type = refer( 'String' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll( const [
          Code( 'String c = input.toUpperCase().replaceAll("#", "");' ),

          Code( 'if ( ! [ 6, 8 ].contains( c.length ) ) {' ),
          Code( 'return Colors.transparent;' ),
          Code( '}' ),

          Code( 'if ( c.length == 6 ) {' ),
          Code( 'c = \'FF\$c\';' ),
          Code( '}' ),

          Code( 'int? iVal = int.tryParse( c, radix: 16 );' ),

          Code( 'if ( iVal != null ) {' ),
          Code( 'return Color( iVal );' ),
          Code( '}' ),

          Code( 'return Colors.transparent;' ),
          ]);
        });
    });
  }

  Method _buildRGBColorConverter() {
    return Method( ( builder ) {
      builder
        ..name = '_colorFromRGBString'
        ..static = true
        ..returns = refer( 'Color' )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'color'
              ..type = refer( 'String' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll( const [
            Code( 'try {' ),
            Code( 'bool hasAlpha = color.toLowerCase().startsWith( \'rgba\' );' ),
            Code( 'String numParts = color.replaceAll("rgb(", "").replaceAll("rgba(", "").replaceAll(")", "");' ),
            Code( 'List<String> rgbSplit = numParts.split(",").map((e) => e.trim()).toList();' ),

            Code( 'int r = int.parse( rgbSplit[0] );' ),
            Code( 'int g = int.parse( rgbSplit[1] );' ),
            Code( 'int b = int.parse( rgbSplit[2] );' ),

            Code( 'double a = hasAlpha ? double.parse( rgbSplit[3] ) : 1.0;' ),

            Code( 'return Color.fromRGBO( r, g, b, a );' ),

            Code( '} catch ( e ) {' ),
            Code( 'print( e );' ),
            Code( 'return Colors.transparent;' ),
            Code( '}' ),
          ]);
        });
    });
  }

  Method _buildColorToStringConverter() {
    return Method( ( builder ) {
      builder
        ..name = 'colorToString'
        ..static = true
        ..returns = refer( 'String' )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'color'
              ..type = refer( 'Color' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll( const [
            Code( 'var r = color.red;' ),
            Code( 'var g = color.green;' ),
            Code( 'var b = color.blue;' ),
            Code( 'var o = color.opacity;' ),
            Code( 'return \'rgba(\$r,\$g,\$b,\$o)\';' ),
          ]);
        });
    });
  }

  Method _buildColorValueParser() {
    return Method( ( builder ) {
      builder
        ..name = 'parseColorValue'
        ..static = true
        ..returns = refer( 'Color' )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'input'
              ..type = refer( 'dynamic' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll( const [
            Code( 'if ( input is Color ) {' ),
            Code( 'return input;' ),
            Code( '}' ),

            Code( 'if ( input is int ) {' ),
            Code( 'try {' ),
            Code( 'return Color( input );' ),
            Code( '} catch ( e ) {' ),
            Code( 'print( e );' ),
            Code( 'return Colors.transparent;' ),
            Code( '}' ),
            Code( '}' ),


            Code( 'if ( input is String ) {' ),
            Code( 'if ( input.toLowerCase().startsWith( \'rgb\' ) ) {' ),
            Code( 'return _colorFromRGBString( input );' ),
            Code( '}' ),
            Code( 'return _colorFromHex( input );' ),
            Code( '}' ),

            Code( 'return Colors.transparent;' ),
          ]);
        });
    });
  }

}