import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates a formatted title header in the generated code.
///
/// This writer creates a visually distinct section header in the generated code,
/// making it easier to identify different sections of the configuration.
///
/// Example usage:
/// ```dart
/// final writer = TitleWriter('Colors');
/// final code = writer.write();
/// ```
class TitleWriter extends Writer {
  /// The title text to display in the header
  final String title;

  /// Creates a new [TitleWriter] with the given title.
  ///
  /// Parameters:
  /// * [title] - The title text to display in the header
  TitleWriter(this.title);

  @override
  Spec write() {
    return Code(writeHeader(title));
  }

  /// Generates a formatted header string with the given title.
  ///
  /// The header consists of:
  /// 1. A blank line
  /// 2. A line of asterisks
  /// 3. The title text
  /// 4. Another line of asterisks
  /// 5. A blank line
  ///
  /// Parameters:
  /// * [header] - The title text to display
  ///
  /// Returns:
  /// * A formatted string containing the header
  String writeHeader(String header) {
    StringBuffer sb = StringBuffer();

    sb.writeAll([
      '\n\n',
      '// ********************************',
      '// $header',
      '// ********************************',
      '\n'
    ], '\n');

    return sb.toString();
  }
}
