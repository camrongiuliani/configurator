import 'dart:convert';
import 'dart:io';

import 'package:configurator/src/utils/string_ext.dart';
import 'package:yaml/yaml.dart';

/// A definitions or source-resolution error intended for a CLI user.
class DefinitionResolutionException implements Exception {
  const DefinitionResolutionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _DefinitionDocument {
  const _DefinitionDocument({
    required this.path,
    required this.definitions,
  });

  final String path;
  final Map<String, dynamic> definitions;
}

/// Resolves external `*.defs.yaml` anchors entirely in memory.
///
/// The original configuration YAML is never rewritten. A private definitions
/// node is inserted before `configuration` in the source passed to the YAML
/// parser, which makes its anchors available while keeping definitions out of
/// the generated configuration values.
class DefinitionCatalog {
  DefinitionCatalog._(this._documents);

  factory DefinitionCatalog.fromFiles(Iterable<FileSystemEntity> files) {
    final documents = <String, _DefinitionDocument>{};

    for (final entity in files) {
      final file = File(entity.path);
      late final YamlNode root;
      try {
        root = loadYamlNode(file.readAsStringSync());
      } on Object catch (error) {
        throw DefinitionResolutionException(
          'Invalid definitions YAML at ${file.path}: $error',
        );
      }

      if (root.value is! YamlMap) {
        throw DefinitionResolutionException(
          'Definitions file ${file.path} must contain a YAML map.',
        );
      }

      final map = root.value as YamlMap;
      final id = map['id'];
      final definitions = map['definitions'];
      if (id is! String || id.trim().isEmpty) {
        throw DefinitionResolutionException(
          'Definitions file ${file.path} must declare a non-empty string id.',
        );
      }
      if (definitions is! YamlMap) {
        throw DefinitionResolutionException(
          'Definitions file ${file.path} must declare a definitions map.',
        );
      }

      final existing = documents[id];
      if (existing != null) {
        throw DefinitionResolutionException(
          'Duplicate definitions id "$id" in ${existing.path} and ${file.path}.',
        );
      }

      documents[id] = _DefinitionDocument(
        path: file.path,
        definitions: _plainMap(definitions),
      );
    }

    return DefinitionCatalog._(Map.unmodifiable(documents));
  }

  final Map<String, _DefinitionDocument> _documents;

  /// Returns source with the requested external definitions available as YAML
  /// anchors, without changing [source] or its file on disk.
  String resolveSource({
    required String path,
    required String source,
  }) {
    final sourceId = _readDefinitionSource(source, path);
    if (sourceId == null) {
      return source;
    }

    final document = _documents[sourceId];
    if (document == null) {
      throw DefinitionResolutionException(
        'Configuration $path references missing definitions id "$sourceId".',
      );
    }

    if (RegExp(
      r'^_configurator_definitions\s*:',
      multiLine: true,
    ).hasMatch(source)) {
      throw DefinitionResolutionException(
        'Configuration $path uses the reserved key '
        '"_configurator_definitions".',
      );
    }

    final configuration = RegExp(
      r'^configuration\s*:',
      multiLine: true,
    ).firstMatch(source);
    if (configuration == null) {
      throw DefinitionResolutionException(
        'Configuration $path does not declare a root configuration map.',
      );
    }

    final block = _renderDefinitions(document.definitions, document.path);
    return '${source.substring(0, configuration.start)}'
        '$block\n'
        '${source.substring(configuration.start)}';
  }
}

String? _readDefinitionSource(String source, String path) {
  final matches = RegExp(
    r'^def_source\s*:\s*(.*)$',
    multiLine: true,
  ).allMatches(source);
  if (matches.length > 1) {
    throw DefinitionResolutionException(
      'Configuration $path declares def_source more than once.',
    );
  }
  if (matches.isEmpty) {
    return null;
  }

  final rawValue = matches.single.group(1)?.trim() ?? '';
  try {
    final value = loadYaml(rawValue);
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  } on Object {
    // The friendly error below includes the source path.
  }

  throw DefinitionResolutionException(
    'Configuration $path must use a non-empty string def_source.',
  );
}

String _renderDefinitions(
  Map<String, dynamic> definitions,
  String definitionPath,
) {
  final lines = <String>['_configurator_definitions:'];
  final anchors = <String, String>{};

  for (final entry in definitions.entries) {
    lines.add('  ${_yamlKey(entry.key)}:');
    if (entry.value is Map<String, dynamic>) {
      for (final child in (entry.value as Map<String, dynamic>).entries) {
        _renderNamedValue(
          lines: lines,
          key: child.key,
          value: child.value,
          indent: 4,
          path: [entry.key, child.key],
          anchors: anchors,
          definitionPath: definitionPath,
        );
      }
    } else {
      _renderNamedValue(
        lines: lines,
        key: 'value',
        value: entry.value,
        indent: 4,
        path: [entry.key, 'value'],
        anchors: anchors,
        definitionPath: definitionPath,
      );
    }
  }

  return lines.join('\n');
}

void _renderNamedValue({
  required List<String> lines,
  required String key,
  required dynamic value,
  required int indent,
  required List<String> path,
  required Map<String, String> anchors,
  required String definitionPath,
}) {
  final padding = List.filled(indent, ' ').join();
  final anchor = _anchorName(path);
  final previousPath = anchors[anchor];
  if (previousPath != null) {
    throw DefinitionResolutionException(
      'Definitions file $definitionPath produces duplicate anchor "$anchor" '
      'for $previousPath and ${path.join('.')}.',
    );
  }
  anchors[anchor] = path.join('.');

  if (value is Map<String, dynamic>) {
    lines.add('$padding${_yamlKey(key)}: &$anchor');
    for (final entry in value.entries) {
      _renderNamedValue(
        lines: lines,
        key: entry.key,
        value: entry.value,
        indent: indent + 2,
        path: [...path, entry.key],
        anchors: anchors,
        definitionPath: definitionPath,
      );
    }
    return;
  }

  lines.add('$padding${_yamlKey(key)}: &$anchor ${jsonEncode(value)}');
}

String _anchorName(List<String> path) {
  final raw = path.length == 2 ? path.last : path.join('.').canonicalize;
  final safe = raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  return RegExp(r'^[A-Za-z_]').hasMatch(safe) ? safe : 'value$safe';
}

String _yamlKey(String key) {
  return RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*$').hasMatch(key)
      ? key
      : jsonEncode(key);
}

Map<String, dynamic> _plainMap(YamlMap map) {
  return {
    for (final entry in map.entries)
      entry.key.toString(): _plainValue(entry.value),
  };
}

dynamic _plainValue(dynamic value) {
  if (value is YamlMap) {
    return _plainMap(value);
  }
  if (value is YamlList) {
    return value.map(_plainValue).toList();
  }
  return value;
}
