import 'package:configurator/configurator.dart';

import 'config_file.dart';

/// A deterministic part-graph validation or composition failure.
class PartResolutionException implements Exception {
  const PartResolutionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validates and composes configuration parts in their declared order.
///
/// Later entries in a `parts` list override earlier entries, matching the
/// existing [YamlConfiguration.operator +] behavior. Shared parts are resolved
/// once and copied into each parent, so one root can never mutate another.
List<ConfigFile> resolveConfigurationParts(
  List<ConfigFile> files, {
  Iterable<String>? rootIds,
}) {
  final byId = <String, ConfigFile>{};

  for (final file in files) {
    final id = file.config.name;
    if (id.trim().isEmpty) {
      throw PartResolutionException(
        'Configuration ${_sourcePath(file)} must declare a non-empty id.',
      );
    }
    final existing = byId[id];
    if (existing != null) {
      throw PartResolutionException(
        'Duplicate configuration id "$id" in '
        '${_sourcePath(existing)} and ${_sourcePath(file)}.',
      );
    }
    byId[id] = file;
  }

  for (final file in files) {
    final seen = <String>{};
    for (final partId in file.config.partFiles) {
      if (!seen.add(partId)) {
        throw PartResolutionException(
          'Configuration "${file.config.name}" declares part "$partId" '
          'more than once.',
        );
      }
      if (!byId.containsKey(partId)) {
        throw PartResolutionException(
          'Configuration "${file.config.name}" references missing part '
          '"$partId".',
        );
      }
    }
  }

  final state = <String, int>{};
  final stack = <String>[];

  void visit(String id) {
    if (state[id] == 2) {
      return;
    }
    if (state[id] == 1) {
      final cycleStart = stack.indexOf(id);
      final cycle = [...stack.sublist(cycleStart), id];
      throw PartResolutionException(
        'Configuration part cycle detected: ${cycle.join(' -> ')}.',
      );
    }

    state[id] = 1;
    stack.add(id);
    for (final partId in byId[id]!.config.partFiles) {
      visit(partId);
    }
    stack.removeLast();
    state[id] = 2;
  }

  for (final id in byId.keys) {
    visit(id);
  }

  final referenced = {for (final file in files) ...file.config.partFiles};
  final memo = <String, YamlConfiguration>{};

  YamlConfiguration compose(String id) {
    final cached = memo[id];
    if (cached != null) {
      return _copyConfiguration(cached);
    }

    final source = byId[id]!.config;
    final result = _copyConfiguration(source);
    for (final partId in source.partFiles) {
      result + compose(partId);
    }
    memo[id] = _copyConfiguration(result);
    return result;
  }

  final idsToEmit = rootIds?.toSet() ??
      {
        for (final file in files)
          if (!referenced.contains(file.config.name)) file.config.name,
      };
  return [
    for (final file in files)
      if (idsToEmit.contains(file.config.name))
        ConfigFile(file.name, file.directory, compose(file.config.name)),
  ];
}

YamlConfiguration _copyConfiguration(YamlConfiguration source) {
  return YamlConfiguration(
    name: source.name,
    partFiles: source.partFiles,
    weight: source.weight,
    flags: source.flags,
    colors: source.colors,
    images: source.images,
    misc: source.misc,
    textStyles: source.textStyles,
    sizes: source.sizes,
    routes: source.routes,
    strings: source.strings,
    padding: source.padding,
    margins: source.margins,
    i18n: source.i18n,
  );
}

String _sourcePath(ConfigFile file) {
  return '${file.directory}/${file.name}.config.yaml';
}
