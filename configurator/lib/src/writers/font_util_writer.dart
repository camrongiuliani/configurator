import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

class FontUtilWriter extends Writer {

  FontUtilWriter();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..name = '_FontUtil'
        ..methods.addAll([
          _buildFontWeightParser(),
        ]);
    });
  }

  Method _buildFontWeightParser() {
    return Method( ( builder ) {
      builder
        ..name = 'parseFontWeight'
        ..static = true
        ..returns = refer( 'FontWeight' )
        ..requiredParameters.addAll([
          Parameter( ( builder ) {
            builder
              ..name = 'value'
              ..type = refer( 'int' );
          }),
        ])
        ..body = Block( ( builder ) {
          builder.statements.addAll( const [
            Code(
              '''
                if (value <= 150) {
                  return FontWeight.w100;
                } else if (value <= 250) {
                  return FontWeight.w200;
                } else if (value <= 350) {
                  return FontWeight.w300;
                } else if (value <= 450) {
                  return FontWeight.w400;
                } else if (value <= 550) {
                  return FontWeight.w500;
                } else if (value <= 650) {
                  return FontWeight.w600;
                } else if (value <= 750) {
                  return FontWeight.w700;
                } else if (value <= 850) {
                  return FontWeight.w800;
                } else if (value <= 950) {
                  return FontWeight.w900;
                }
            
                return FontWeight.w400;
              '''
            ),
          ]);
        });
    });
  }

}