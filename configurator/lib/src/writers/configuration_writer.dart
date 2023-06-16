import 'dart:convert';

import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class ConfigWriter extends Writer {
  final String name;
  final int weight;
  final List<YamlI18n> strings;
  final List<YamlRoute> routes;
  final List<YamlTextStyle> textStyles;
  late final List<YamlSetting<String, bool>> flags;
  late final List<YamlSetting<String, String>> colors;
  late final List<YamlSetting<String, dynamic>> misc;
  late final List<YamlSetting> sizes;
  late final List<YamlSetting<String, dynamic>> images;
  late final List<YamlSetting<String, double>> margins;
  late final List<YamlSetting<String, double>> padding;

  ConfigWriter({
    required this.name,
    required this.weight,
    required this.strings,
    required this.textStyles,
    required this.routes,
    required List<YamlSetting> flags,
    required List<YamlSetting> sizes,
    required List<YamlSetting> colors,
    required List<YamlSetting> misc,
    required List<YamlSetting> images,
    required List<YamlSetting> margins,
    required List<YamlSetting> padding,
  }) {
    this.flags = flags.convert<String, bool>();
    this.colors = colors.convert<String, String>();
    this.misc = misc.convert<String, dynamic>();
    this.sizes = sizes.convert<String, double>();
    this.margins = margins.convert<String, double>();
    this.padding = padding.convert<String, double>();
    this.images = images.convert<String, dynamic>();
  }

  @override
  Spec write() {
    return Class((builder) {
      builder
        ..name = 'Generated$name'
        ..extend = refer('ConfigScope')
        ..constructors.add(
          Constructor(
            (b) {
              b.constant = true;
            },
          ),
        )
        ..fields.addAll([
          _nameField(),
          _valueGetter(
            name: 'weight',
            returnType: 'int',
            assignment: Code('$weight'),
          ),
          _valueGetter(
            name: 'flags',
            returnType: 'Map<String, bool>',
            assignment: Code(() {
              Map<String, bool> map = {};

              for (var f in flags) {
                var key = '"${f.name}"';

                if (map.containsKey(key) && map[key] != f.value) {
                  throw Exception('Duplicate Flag Key Detected: $key');
                }
                map[key] = f.value;
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'images',
            returnType: 'Map<String, dynamic>',
            assignment: Code(() {
              Map<String, dynamic> map = {};

              for (var f in images) {
                var key = '"${f.name.canonicalize}"';

                if (map.containsKey(key) && map[key] != f.value) {
                  throw Exception('Duplicate Image Key Detected: $key');
                }

                map[key] = () {
                  if (f.value is String) {
                    return '\'${f.value}\'';
                  } else if (f.value is List) {
                    return f.value.map((v) => '\'$v\'').toList();
                  }
                }();
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'colors',
            returnType: 'Map<String, String>',
            assignment: Code(() {
              Map<String, String> map = {};

              for (var f in colors) {
                var key = '"${f.name.canonicalize}"';

                if (map.containsKey(key) && map[key] != f.value) {
                  throw Exception('Duplicate Color Key Detected: $key');
                }

                map[key] = '\'${f.value}\'';
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'sizes',
            returnType: 'Map<String, double>',
            assignment: Code(() {
              Map<String, double> map = {};

              for (var f in sizes) {
                var key = '"${(f.name as String).canonicalize}"';

                if (map.keys.contains(key)) {
                  throw Exception('Duplicate Size Key Detected: $key');
                }

                map[key] = f.value;
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'padding',
            returnType: 'Map<String, double>',
            assignment: Code(() {
              Map<String, double> map = {};

              for (var f in padding) {
                var key = '"${f.name.canonicalize}"';

                if (map.keys.contains(key)) {
                  throw Exception('Duplicate Padding Key Detected: $key');
                }

                map[key] = f.value;
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'margins',
            returnType: 'Map<String, double>',
            assignment: Code(() {
              Map<String, double> map = {};

              for (var f in margins) {
                var key = '"${f.name.canonicalize}"';

                if (map.keys.contains(key)) {
                  throw Exception('Duplicate Margin Key Detected: $key');
                }

                map[key] = f.value;
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'misc',
            returnType: 'Map<String, dynamic>',
            assignment: Code(() {
              Map<String, dynamic> map = {};

              for (var f in misc) {
                var key = '"${(f.name).canonicalize}"';

                if (map.keys.contains(key)) {
                  throw Exception('Duplicate Misc Key Detected: $key');
                }

                map[key] = () {
                  if (f.value is String) {
                    return '\'${f.value}\'';
                  }
                  return f.value;
                }();
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'textStyles',
            returnType: 'Map<String, dynamic>',
            assignment: Code(() {
              Map<String, dynamic> map = {};

              Map mapSanitize(Map map) {
                return map.map((key, value) {
                  return MapEntry('"$key"', () {
                    if (value is String) {
                      return '"$value"';
                    } else if (value is Map) {
                      return mapSanitize(value);
                    } else {
                      return value;
                    }
                  }());
                });
              }

              for (var f in textStyles) {
                var key = '"${f.key.canonicalize}"';

                if (map.keys.contains(key)) {
                  throw Exception('Duplicate TextStyle Key Detected: $key');
                }

                map[key] = () {
                  return mapSanitize(f.toJson());
                }();
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'routes',
            returnType: 'Map<int, String>',
            assignment: Code(() {
              Map<int, String> map = {};

              for (var f in routes) {
                if (map.keys.contains(f.id)) {
                  throw Exception('Duplicate Route ID Detected: (${f.id} : ${f.path})');
                }
                map[f.id] = '\'${f.path}\'';
              }

              return 'const ${map.toString()}';
            }()),
          ),
          _valueGetter(
            name: 'translations',
            returnType: 'Map<String, Map<String, String>>',
            assignment: Code(() {
              Map<String, dynamic> parsed = I18nParser.parse(
                strings: strings,
              );

              var data = jsonEncode(parsed).replaceAll(r'\\', r'\');

              // while (data.contains(r'\\')) {
              //   data = data.replaceAll(r'\\', r'\');
              // }

              data = data.replaceAll(r'+$', r'+\$');

              return 'const $data';
            }()),
          ),
        ]);
    });
  }

  Field _nameField() {
    return Field((builder) {
      builder
        ..name = 'name'
        ..modifier = FieldModifier.final$
        ..annotations.add(refer('override'))
        ..type = refer('String')
        ..assignment = Code('"__Generated$name"');
    });
  }

  Field _valueGetter({
    required String name,
    required String returnType,
    required Code assignment,
  }) {
    return Field((builder) {
      builder
        ..name = name
        ..annotations.add(refer('override'))
        ..modifier = FieldModifier.final$
        ..type = refer(returnType)
        ..assignment = assignment;
    });
  }
}
