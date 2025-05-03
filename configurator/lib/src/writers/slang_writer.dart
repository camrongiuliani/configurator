import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates internationalization (i18n) code using the slang package.
///
/// This writer takes a list of [YamlI18n] objects and generates Dart code for
/// internationalization using the slang package. The generated code includes
/// translation classes and methods for accessing translated strings.
///
/// Example usage:
/// ```dart
/// final writer = SlangWriter(i18nStrings);
/// final code = writer.write();
/// ```
class SlangWriter extends Writer {
  /// The list of internationalized strings to generate code for
  final List<YamlI18n> strings;

  /// Creates a new [SlangWriter] with the given internationalized strings.
  ///
  /// Parameters:
  /// * [strings] - The list of [YamlI18n] objects to generate code for
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
