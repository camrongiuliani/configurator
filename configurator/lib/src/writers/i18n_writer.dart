import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/writer.dart';

class I18nWriter extends Writer {
  final List<YamlI18n> strings;

  I18nWriter(this.strings) {
    I18nParser.parse(
      strings: strings,
    );
  }

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class scope = Class((builder) {
      builder
        ..constructors.add(
          Constructor(
            (b) {
              b
                ..constant = true
                ..requiredParameters.addAll([
                  Parameter((b) {
                    b
                      ..name = '_config'
                      ..toThis = true;
                  }),
                ]);
            },
          ),
        )
        ..fields.addAll([
          Field((b) {
            b
              ..name = '_config'
              ..type = refer('Configuration')
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..name = '_i18n'
        ..methods.addAll([
          _getTranslationBuilder(),
          _getLocalizeMethod(),
        ]);
    });

    lb.body.add(scope);

    return lb.build();
  }

  Method _getTranslationBuilder() {
    return Method((builder) {
      builder
        ..name = 'buildTranslations'
        // ..type = MethodType.setter
        ..returns = refer('i18n.Translations')
        ..lambda = false
        ..body = const Code('''
            return i18n.Translations.from(
              "en_us",
              _config.currentTranslations(),
            );
        ''');
    });
  }

  Method _getLocalizeMethod() {
    return Method((builder) {
      builder
        ..name = '_localize'
        ..returns = refer('String')
        ..lambda = false
        ..requiredParameters.addAll([
          Parameter((b) {
            b
              ..name = 'input'
              ..type = refer('String');
          }),
        ])
        ..body = const Code('''
            return i18n.localize(
              input,
              buildTranslations(),
            );
        ''');
    });
  }
}
