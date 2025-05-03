import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates code for accessing image configuration values.
///
/// This writer creates a class with getters for accessing image paths defined
/// in the configuration. The generated code supports both single image paths
/// and lists of image paths.
///
/// Example usage:
/// ```dart
/// final writer = ImageWriter('Assets', imageSettings);
/// final code = writer.write();
/// ```
class ImageWriter extends Writer {
  /// The canonicalized and capitalized name of the image accessor
  final String name;

  /// The list of image settings to generate accessors for
  final List<YamlSetting> _images;

  /// Creates a new [ImageWriter] with the given name and image settings.
  ///
  /// Parameters:
  /// * [name] - The name of the image accessor
  /// * [_images] - The list of image settings to generate accessors for
  ImageWriter(String name, this._images)
      : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add(config);

    return lb.build();
  }

  /// Generates getter methods for each image in the configuration.
  ///
  /// The getters return either a [String] for single images or a [List<String>]
  /// for lists of images, depending on the type of the image value.
  ///
  /// Returns:
  /// * A list of [Method] objects representing the image getters
  List<Method> _getGetters() {
    return _images.map((e) {
      return Method((builder) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer(e.value is List ? 'List<String>' : 'String')
          ..lambda = true
          ..body = Code(() {
            if (e.value is List) {
              return '_config.imageList("${e.name}")';
            }
            return '_config.image("${e.name}")';
          }());
      });
    }).toList();
  }

  /// Builds the image accessor class.
  ///
  /// The generated class:
  /// 1. Has a constructor that takes a [Configuration] instance
  /// 2. Contains a private field for the configuration
  /// 3. Includes getter methods for each image
  ///
  /// Returns:
  /// * A [Class] object representing the image accessor
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
        ..name = '_ImageAccessor'
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