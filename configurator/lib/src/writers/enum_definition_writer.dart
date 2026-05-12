import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/writer.dart';

class EnumDefinitionWriter extends Writer {
  final List<YamlEnumDefinition> definitions;

  EnumDefinitionWriter(this.definitions);

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    for (var def in definitions) {
      lb.body.add(Enum((builder) {
        builder
          ..name = def.name
          ..values.addAll(def.values.map((v) => EnumValue((b) => b..name = v)))
          ..methods.add(Method((b) {
            b
              ..name = 'fromName'
              ..static = true
              ..returns = refer(def.name)
              ..requiredParameters.add(Parameter((p) => p
                ..name = 'name'
                ..type = refer('String')))
              ..optionalParameters.add(Parameter((p) => p
                ..name = 'fallback'
                ..type = refer('${def.name}?')))
              ..body = Code('''
                return ${def.name}.values.firstWhere((e) => e.name == name, orElse: () => fallback ?? ${def.name}.values.first);
              ''');
          }));
      }));
    }

    return lb.build();
  }
}
