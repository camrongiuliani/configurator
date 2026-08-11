import 'package:configurator/configurator.dart';

/// An expected command-line failure that can be shown without a stack trace.
class ConfiguratorCliException implements Exception {
  const ConfiguratorCliException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Parsed and validated Configurator command-line options.
class ConfiguratorCliOptions {
  const ConfiguratorCliOptions({
    required this.help,
    required this.recursive,
    required this.pureDart,
    required this.watch,
    required this.filters,
    required this.targets,
  });

  final bool help;
  final bool recursive;
  final bool pureDart;
  final bool watch;
  final List<String> filters;
  final Set<ConfigTarget> targets;

  static ConfiguratorCliOptions parse(List<String> arguments) {
    const switches = {
      '-h',
      '--help',
      '--recursive',
      '--pure-dart',
      '-w',
      '--watch',
    };

    for (final argument in arguments) {
      final knownValueOption = argument.startsWith('--targets=') ||
          argument.startsWith('--target=') ||
          argument.startsWith('--id-filter=');

      if (!switches.contains(argument) && !knownValueOption) {
        throw ConfiguratorCliException(
          'Unknown option "$argument". Run with --help for supported options.',
        );
      }
    }

    final filterArguments = arguments
        .where((argument) => argument.startsWith('--id-filter='))
        .toList();
    if (filterArguments.length > 1) {
      throw const ConfiguratorCliException(
        '--id-filter may only be specified once.',
      );
    }

    final filters = filterArguments.isEmpty
        ? const <String>[]
        : filterArguments.single
            .substring('--id-filter='.length)
            .split(',')
            .map((filter) => filter.trim())
            .toList();
    if (filters.any((filter) => filter.isEmpty)) {
      throw const ConfiguratorCliException(
        '--id-filter must contain one or more non-empty basenames.',
      );
    }

    late final Set<ConfigTarget> targets;
    try {
      targets = ConfigTarget.fromArguments(arguments);
    } on FormatException catch (error) {
      throw ConfiguratorCliException(error.message.toString());
    }

    return ConfiguratorCliOptions(
      help: arguments.contains('-h') || arguments.contains('--help'),
      recursive: arguments.contains('--recursive'),
      pureDart: arguments.contains('--pure-dart'),
      watch: arguments.contains('-w') || arguments.contains('--watch'),
      filters: List.unmodifiable(filters),
      targets: Set.unmodifiable(targets),
    );
  }
}
