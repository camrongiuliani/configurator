import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class TextStyleWriter extends Writer {
  final String name;
  final List<YamlTextStyle> _textStyles;

  TextStyleWriter(String name, this._textStyles)
      : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add(config);

    return lb.build();
  }

  Method _buildTypefaceGetter() {
    return Method((builder) {
      builder
        ..name = 'typefaces'
        ..type = MethodType.getter
        ..returns = refer('Map<String, String>')
        ..lambda = false
        ..body = Code(() {
          List<String> lines = [];

          for (var e in _textStyles) {
            lines.add('..._config.textStyle("${e.key}")["typeface"],');
          }

          return '''                
            return {
              ${lines.join('\n')}
            };
          ''';
        }());
    });
  }

  List<Method> _getGetters() {
    return _textStyles.map((e) {
      return Method((builder) {
        builder
          ..name = e.key.canonicalize
          ..type = MethodType.getter
          ..returns = refer('TextStyle')
          ..lambda = false
          ..body = Code(() {
            return 'return TextStyleParser.parse(_config, ${name}ConfigKeys.textStyles.${e.key});';
          }());
      });
    }).toList();
  }

  Class _buildAccessor() {
    return Class((builder) {
      builder
        ..constructors.add(Constructor((b) {
          b
            ..constant = true
            ..requiredParameters.addAll([
              Parameter((b) {
                b
                  ..name = '_config'
                  ..toThis = true;
              }),
            ]);
        }))
        ..name = '_TextStyleAccessor'
        ..fields.addAll([
          Field((b) {
            b
              ..name = '_config'
              ..type = refer('Configuration')
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getGetters(),
          _buildTypefaceGetter(),
        ]);
    });
  }
}
