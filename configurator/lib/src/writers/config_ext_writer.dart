import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates extension methods for accessing configuration values.
///
/// This writer creates an extension on the [Configuration] class that provides
/// convenient getters for accessing different types of configuration values,
/// such as flags, colors, images, sizes, and more.
///
/// Example usage:
/// ```dart
/// final writer = ConfigExtWriter();
/// final code = writer.write();
/// ```
class ConfigExtWriter extends Writer {
  /// Creates a new [ConfigExtWriter].
  ConfigExtWriter();

  @override
  Spec write() {
    return Extension((b) {
      b
        ..name = 'ConfigAccessor'
        ..on = refer('Configuration')
        ..methods.addAll([
          _buildGetter('_FlagAccessor', 'flags'),
          _buildGetter('_ColorAccessor', 'colors'),
          _buildGetter('_ImageAccessor', 'images'),
          _buildGetter('_SizeAccessor', 'sizes'),
          _buildGetter('_PaddingAccessor', 'paddings'),
          _buildGetter('_MarginAccessor', 'margins'),
          _buildGetter('_MiscAccessor', 'miscellaneous'),
          _buildGetter('_TextStyleAccessor', 'textStyles'),
          _buildGetter('_RouteAccessor', 'routes'),
          // _buildGetter('_I18nDartEn', 'strings', 't'),
          _buildTranslationGetter(),
          // _buildTranslationMap(),
        ]);
    });
  }

  /// Builds a getter method for accessing a specific type of configuration value.
  ///
  /// Parameters:
  /// * [className] - The name of the accessor class
  /// * [fieldName] - The name of the getter method
  /// * [body] - Optional custom body for the getter method
  ///
  /// Returns:
  /// * A [Method] object representing the getter
  Method _buildGetter(String className, String fieldName, [String? body]) {
    return Method((b) {
      b
        ..name = fieldName
        ..returns = refer(className)
        ..body = Code(body ?? '$className(this)')
        ..lambda = true
        ..type = MethodType.getter;
    });
  }

  /// Builds a getter method for accessing internationalized strings.
  ///
  /// Returns:
  /// * A [Method] object representing the strings getter
  Method _buildTranslationGetter() {
    return Method((b) {
      b
        ..name = 'strings'
        ..returns = refer('_I18nDart')
        ..body = const Code('_I18nDart(this)')
        ..lambda = true
        ..type = MethodType.getter;
    });
  }
}