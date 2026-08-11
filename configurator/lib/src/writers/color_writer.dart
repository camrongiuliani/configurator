import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates code for accessing color configuration values.
///
/// This writer creates a class with getters for accessing color values defined
/// in the configuration. The generated code provides type-safe access to colors
/// using the Flutter [Color] class.
///
/// Example usage:
/// ```dart
/// final writer = ColorWriter('Theme', colorSettings);
/// final code = writer.write();
/// ```
class ColorWriter extends Writer {
  /// The canonicalized and capitalized name of the color accessor
  final String name;

  /// The list of color settings to generate accessors for
  final List<YamlSetting<String, String>> _colors;

  /// Whether generated accessors must avoid Flutter-only types.
  final bool pureDart;

  /// Creates a new [ColorWriter] with the given name and color settings.
  ///
  /// Parameters:
  /// * [name] - The name of the color accessor
  /// * [colors] - The list of color settings to generate accessors for
  ColorWriter(
    String name,
    List<YamlSetting> colors, {
    this.pureDart = false,
  })  : name = name.canonicalize.capitalized,
        _colors = colors.convert<String, String>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add(config);

    return lb.build();
  }

  /// Generates getter methods for each color in the configuration.
  ///
  /// Returns:
  /// * A list of [Method] objects representing the color getters
  List<Method> _getColorGetters() {
    return _colors.map((e) {
      return Method((builder) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer(pureDart ? 'String' : 'Color')
          ..lambda = true
          ..body = Code(() {
            return pureDart
                ? '_config.color("${e.name}")'
                : '_config.colorValue("${e.name}")';
          }());
      });
    }).toList();
  }

  /// Builds the color accessor class.
  ///
  /// The generated class:
  /// 1. Has a constructor that takes a [Configuration] instance
  /// 2. Contains a private field for the configuration
  /// 3. Includes getter methods for each color
  ///
  /// Returns:
  /// * A [Class] object representing the color accessor
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
        ..name = '_ColorAccessor'
        ..fields.addAll([
          Field((b) {
            b
              ..name = '_config'
              ..type = refer('Configuration')
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getColorGetters(),
        ]);
    });
  }
}
