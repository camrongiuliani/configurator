import 'dart:convert';

import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/models/getter.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class I18nWriter extends Writer {
  final String name;
  final List<YamlI18n> strings;

  I18nWriter(String name, this.strings) : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    List<Getter> getters = [];

    Map<String, dynamic> map = {};

    for (var f in strings) {
      map[f.locale] ??= {};
      map[f.locale][f.name] ??= f.value;
    }

    I18nParser.parse(
      strings: strings,
      onGetter: (getter) {
        if (!getters.map((e) => e.key).contains(getter.key)) {
          getters.add(getter);
        }
      },
    );
    //translations

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
          ..._getValueGetters(getters),
        ]);
    });

    lb.body.add(scope);

    return lb.build();
  }

  Method _buildTranslationGetter(void Function(Getter) onGetter) {
    return Method((builder) {
      builder
        ..name = 'translations'
        ..type = MethodType.getter
        ..returns = refer('Map<String, Map<String, String>>')
        ..lambda = true
        ..body = Code(
          () {
            Map<String, dynamic> map = {};

            for (var f in strings) {
              map[f.locale] ??= {};
              map[f.locale][f.name] ??= f.value;
            }

            Map<String, dynamic> parsed = I18nParser.parse(
              strings: strings,
              onGetter: onGetter,
            );

            return jsonEncode(parsed);
          }(),
        );
    });
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

  List<Method> _getValueGetters(List<Getter> getters) {
    return getters.map((e) {

      bool isListType = e.value is List;

      String? type = isListType ? 'List<dynamic>' : 'String';

      String anchor = e.key;

      return Method((builder) {
        builder
          ..name = anchor
          ..type = MethodType.getter
          ..returns = refer(type)
          ..lambda = true
          ..body = Code(() {
            if (isListType) {
              if (e.value is List<String>) {
                return e.value.toString();
              } else if (e.value is List<Map>) {
                return e.value.map((e) => e.map((key, value) {
                  return MapEntry('"$key"', value);
                })).toList().toString();
              } else {
                throw Exception('Unsupported list type in strings : ${e.value.runtimeType}');
              }
            } else {
              return '_localize("$anchor")';
            }
          }());
      });
    }).toList();
  }

  List<Method> _getGetters([bool useConfig = false]) {
    return strings.map((e) {
      MethodBuilder initBuilder(builder) {
        return builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer('String')
          ..lambda = true;
      }

      return Method((builder) {
        initBuilder(builder).body = Code(() {
          if (useConfig) {
            return '_config.i18n( ${name}ConfigKeys.i18n.${e.name} )';
          }

          return 'map[ ${name}ConfigKeys.i18n.${e.name} ] ?? ""';
        }());
      });
    }).toList();
  }

  Method _getTranslationsMap() {
    return Method((builder) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer('Map<String, dynamic>')
        ..lambda = true
        ..body = Code(() {
          Map<String, dynamic> map = {};

          for (var f in strings) {
            map[f.locale] ??= {};
            map[f.locale][f.name] ??= f.value;
          }

          return jsonEncode(map);
        }());
    });
  }

  Class _buildAccessor() {
    return Class((builder) {
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
        ..name = '_I18nAccessor'
        ..fields.addAll([
          Field((b) {
            b
              ..name = '_config'
              ..type = refer('Configuration')
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getGetters(true),
        ]);
    });
  }
}
