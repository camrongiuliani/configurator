import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

/// A writer that generates code for accessing boolean flag configuration values.
///
/// This writer creates a class with getters for accessing boolean flags defined
/// in the configuration. The generated code provides type-safe access to flags
/// using Dart's built-in [bool] type.
///
/// Example usage:
/// ```dart
/// final writer = FlagWriter('Feature', flagSettings);
/// final code = writer.write();
/// ```
class FlagWriter extends Writer {
  /// The canonicalized and capitalized name of the flag accessor
  final String name;

  /// The list of flag settings to generate accessors for
  final List<YamlSetting<String, bool>> _flags;

  /// Creates a new [FlagWriter] with the given name and flag settings.
  ///
  /// Parameters:
  /// * [name] - The name of the flag accessor
  /// * [flags] - The list of flag settings to generate accessors for
  FlagWriter(String name, List<YamlSetting> flags)
      : name = name.canonicalize.capitalized,
        _flags = flags.convert<String, bool>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add(config);

    return lb.build();
  }

  /// Generates getter methods for each flag in the configuration.
  ///
  /// Returns:
  /// * A list of [Method] objects representing the flag getters
  List<Method> _getGetters() {
    return _flags.map((e) {
      return Method((builder) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer('bool')
          ..lambda = true
          ..body = Code(() {
            return '_config.flag("${e.name}")';
          }());
      });
    }).toList();
  }

  /// Builds the flag accessor class.
  ///
  /// The generated class:
  /// 1. Has a constructor that takes a [Configuration] instance
  /// 2. Contains a private field for the configuration
  /// 3. Includes getter methods for each flag
  ///
  /// Returns:
  /// * A [Class] object representing the flag accessor
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
        ..name = '_FlagAccessor'
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
