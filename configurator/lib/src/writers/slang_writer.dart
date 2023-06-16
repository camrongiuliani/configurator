import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/writer.dart';

class SlangWriter extends Writer {
  final List<YamlI18n> strings;

  SlangWriter(this.strings);

  @override
  Spec write() {
    return Code(
      SlangUtil.generateTranslations(
        rawConfig: {
          // 'translation_class_visibility': 'public'
        },
        i18nNodes: strings,
        verbose: true,
      ),
    );
  }
}
