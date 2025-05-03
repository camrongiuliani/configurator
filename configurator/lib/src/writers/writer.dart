import 'package:code_builder/code_builder.dart';

/// An abstract base class for code generation writers.
///
/// This class defines the interface for all writers in the configurator package.
/// Writers are responsible for generating Dart code from configuration data.
///
/// Example usage:
/// ```dart
/// class MyWriter extends Writer {
///   @override
///   Spec write() {
///     return Class((b) => b
///       ..name = 'MyClass'
///       ..methods.add(Method((b) => b
///         ..name = 'myMethod'
///         ..body = Code('return 42;'))));
///   }
/// }
/// ```
abstract class Writer {
  /// Generates a code specification that can be used to build Dart code.
  ///
  /// Returns:
  /// * A [Spec] object representing the generated code
  Spec write();
}