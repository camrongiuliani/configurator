import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class EnumAccessorWriter extends Writer {
  final String name;
  final List<YamlEnumSetting> _enums;

  EnumAccessorWriter(String name, List<YamlEnumSetting> enums)
      : name = name.canonicalize.capitalized,
        _enums = enums;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add(config);

    return lb.build();
  }

  List<Method> _getGetters() {
    return _enums.map((e) {
      return Method((builder) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer(e.type)
          ..lambda = true
          ..body = Code(() {
            return '${e.type}.fromName(_config.enumValue("${e.name}"))';
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
        ..name = '_EnumAccessor'
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
        ]);
    });
  }
}
