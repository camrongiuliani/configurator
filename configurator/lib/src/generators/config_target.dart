/// Supported output languages for configuration generation.
enum ConfigTarget {
  dart,
  python,
  typescript;

  /// Parses a target name accepted by the command-line interface.
  static ConfigTarget parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'dart' => ConfigTarget.dart,
      'python' || 'py' => ConfigTarget.python,
      'typescript' || 'ts' => ConfigTarget.typescript,
      _ => throw FormatException('Unsupported configuration target: $value'),
    };
  }

  /// Parses `--targets=a,b` and repeatable `--target=a` arguments.
  ///
  /// Dart remains the default to preserve the existing CLI behavior.
  static Set<ConfigTarget> fromArguments(List<String> arguments) {
    final values = <String>[];

    for (final argument in arguments) {
      if (argument.startsWith('--targets=')) {
        values.addAll(argument.substring('--targets='.length).split(','));
      } else if (argument.startsWith('--target=')) {
        values.add(argument.substring('--target='.length));
      }
    }

    if (values.isEmpty) {
      return {ConfigTarget.dart};
    }

    if (values.any((value) => value.trim().isEmpty)) {
      throw const FormatException('Configuration targets cannot be empty.');
    }

    return values.map(ConfigTarget.parse).toSet();
  }

  /// Returns the generated filename for a YAML basename.
  String outputFileName(String basename) {
    return switch (this) {
      ConfigTarget.dart => '$basename.config.dart',
      ConfigTarget.python => '${basename}_config.py',
      ConfigTarget.typescript => '$basename.config.ts',
    };
  }
}
