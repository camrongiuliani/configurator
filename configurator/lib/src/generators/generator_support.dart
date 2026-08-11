import 'dart:convert';

import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';

/// A normalized setting used by non-Dart generators.
class GeneratedSetting {
  const GeneratedSetting(this.key, this.value);

  final String key;
  final Object? value;
}

/// A normalized route used by non-Dart generators.
class GeneratedRoute {
  const GeneratedRoute({required this.id, required this.path});

  final int id;
  final String path;
}

/// Language-neutral view of a resolved [YamlConfiguration].
class GeneratedConfigModel {
  GeneratedConfigModel._({
    required this.pascalName,
    required this.camelName,
    required this.snakeName,
    required this.constantName,
    required this.scopeName,
    required this.weight,
    required this.flags,
    required this.colors,
    required this.images,
    required this.routes,
    required this.sizes,
    required this.paddings,
    required this.margins,
    required this.misc,
    required this.textStyles,
    required this.translations,
  });

  factory GeneratedConfigModel.fromConfiguration({
    required String name,
    required YamlConfiguration configuration,
  }) {
    final pascalName = pascalIdentifier(name, fallback: 'Config');
    final words = identifierWords(name);
    final snakeName = words.isEmpty
        ? 'config'
        : words.map((word) => word.toLowerCase()).join('_');
    final constantName = snakeName.toUpperCase();

    final flags = normalizeSettings(
      configuration.flags,
      group: 'flags',
      accepts: (value) => value is bool,
      expected: 'bool',
    );
    final colors = normalizeSettings(
      configuration.colors,
      group: 'colors',
      accepts: (value) => value is String,
      expected: 'String',
    );
    final images = normalizeSettings(
      configuration.images,
      group: 'images',
      accepts: isImageValue,
      expected: 'String or List<String>',
    );
    final sizes = normalizeSettings(
      configuration.sizes,
      group: 'sizes',
      accepts: (value) => value is num,
      expected: 'num',
    );
    final paddings = normalizeSettings(
      configuration.padding,
      group: 'paddings',
      accepts: (value) => value is num,
      expected: 'num',
    );
    final margins = normalizeSettings(
      configuration.margins,
      group: 'margins',
      accepts: (value) => value is num,
      expected: 'num',
    );
    final misc = normalizeSettings(
      configuration.misc,
      group: 'misc',
      accepts: isPortableValue,
      expected: 'a portable scalar, list, or string-keyed map',
    );

    final textStyles = <GeneratedSetting>[];
    final textStyleKeys = <String, String>{};
    for (final style in configuration.textStyles) {
      final key = canonicalKey(style.key, group: 'text styles');
      checkKeyCollision(
        keys: textStyleKeys,
        key: key,
        original: style.key,
        group: 'text styles',
      );
      textStyles.add(GeneratedSetting(key, style.toJson()));
    }
    textStyles.sort((left, right) => left.key.compareTo(right.key));

    final routes = <GeneratedRoute>[];
    final routeIds = <int>{};
    for (final route in configuration.routes) {
      if (!routeIds.add(route.id)) {
        throw StateError('Duplicate route id ${route.id}.');
      }
      routes.add(GeneratedRoute(id: route.id, path: route.path));
    }
    routes.sort((left, right) {
      final byId = left.id.compareTo(right.id);
      return byId != 0 ? byId : left.path.compareTo(right.path);
    });

    final parsedTranslations = I18nParser.parse(
      strings: configuration.resolvedTranslations,
    );
    if (!isPortableValue(parsedTranslations)) {
      throw StateError('Translations contain an unsupported value.');
    }
    final translations = parsedTranslations.entries
        .map((entry) => GeneratedSetting(entry.key, entry.value))
        .toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    return GeneratedConfigModel._(
      pascalName: pascalName,
      camelName: lowerFirst(pascalName),
      snakeName: snakeName,
      constantName: constantName,
      scopeName: '__Generated$pascalName',
      weight: configuration.weight,
      flags: flags,
      colors: colors,
      images: images,
      routes: routes,
      sizes: sizes,
      paddings: paddings,
      margins: margins,
      misc: misc,
      textStyles: textStyles,
      translations: translations,
    );
  }

  final String pascalName;
  final String camelName;
  final String snakeName;
  final String constantName;
  final String scopeName;
  final int weight;
  final List<GeneratedSetting> flags;
  final List<GeneratedSetting> colors;
  final List<GeneratedSetting> images;
  final List<GeneratedRoute> routes;
  final List<GeneratedSetting> sizes;
  final List<GeneratedSetting> paddings;
  final List<GeneratedSetting> margins;
  final List<GeneratedSetting> misc;
  final List<GeneratedSetting> textStyles;
  final List<GeneratedSetting> translations;
}

List<GeneratedSetting> normalizeSettings(
  List<YamlSetting> settings, {
  required String group,
  required bool Function(Object? value) accepts,
  required String expected,
}) {
  final result = <GeneratedSetting>[];
  final keys = <String, String>{};

  for (final setting in settings) {
    final rawName = setting.name;
    if (rawName is! String) {
      throw StateError(
        'Every $group key must be a String; found ${rawName.runtimeType}.',
      );
    }
    if (!accepts(setting.value)) {
      throw StateError(
        'The $group value for "$rawName" must be $expected; '
        'found ${setting.value.runtimeType}.',
      );
    }

    final key = canonicalKey(rawName, group: group);
    checkKeyCollision(
      keys: keys,
      key: key,
      original: rawName,
      group: group,
    );
    result.add(GeneratedSetting(key, setting.value));
  }

  result.sort((left, right) => left.key.compareTo(right.key));
  return result;
}

String canonicalKey(String input, {required String group}) {
  final key = input.canonicalize;
  if (key.isEmpty) {
    throw StateError('The $group key "$input" has no usable characters.');
  }
  return key;
}

void checkKeyCollision({
  required Map<String, String> keys,
  required String key,
  required String original,
  required String group,
}) {
  final previous = keys[key];
  if (previous != null) {
    throw StateError(
      'Canonical $group key collision: "$previous" and "$original" '
      'both become "$key".',
    );
  }
  keys[key] = original;
}

bool isImageValue(Object? value) {
  return value is String ||
      value is List && value.every((element) => element is String);
}

bool isPortableValue(Object? value) {
  if (value == null || value is bool || value is num || value is String) {
    return true;
  }
  if (value is List) {
    return value.every(isPortableValue);
  }
  if (value is Map) {
    return value.keys.every((key) => key is String) &&
        value.values.every(isPortableValue);
  }
  return false;
}

List<String> identifierWords(String input) {
  var value = input.replaceAllMapped(
    RegExp(r'([A-Z]+)([A-Z][a-z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  value = value.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  value = value.replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ').trim();
  if (value.isEmpty) {
    return const [];
  }
  return value
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
}

String pascalIdentifier(String input, {required String fallback}) {
  final words = identifierWords(input);
  var result = words.isEmpty
      ? fallback
      : words
          .map(
            (word) =>
                '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}',
          )
          .join();
  if (RegExp(r'^[0-9]').hasMatch(result)) {
    result = '$fallback$result';
  }
  return result;
}

String lowerFirst(String input) {
  if (input.isEmpty) {
    return input;
  }
  return '${input.substring(0, 1).toLowerCase()}${input.substring(1)}';
}

String pythonIdentifier(String input, {String fallback = 'value'}) {
  final words = identifierWords(input);
  var result = words.isEmpty
      ? fallback
      : words.map((word) => word.toLowerCase()).join('_');
  if (RegExp(r'^[0-9]').hasMatch(result)) {
    result = '${fallback}_$result';
  }
  if (pythonReservedWords.contains(result)) {
    result = '${result}_';
  }
  return result;
}

String typeScriptIdentifier(String input, {String fallback = 'value'}) {
  final words = identifierWords(input);
  var result = words.isEmpty
      ? fallback
      : '${words.first.toLowerCase()}${words.skip(1).map((word) => '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}').join()}';
  if (RegExp(r'^[0-9]').hasMatch(result)) {
    result = '_$result';
  }
  if (typeScriptReservedWords.contains(result)) {
    result = '_$result';
  }
  return result;
}

void ensureMemberIdentifiersUnique({
  required Iterable<MapEntry<String, String>> members,
  required String language,
  required String group,
}) {
  final used = <String, String>{};
  for (final member in members) {
    final previous = used[member.value];
    if (previous != null) {
      throw StateError(
        '$language $group identifier collision: "$previous" and '
        '"${member.key}" both become "${member.value}".',
      );
    }
    used[member.value] = member.key;
  }
}

String quotedString(String value) => jsonEncode(value);

String pythonLiteral(Object? value, {int indent = 0}) {
  if (value == null) return 'None';
  if (value is bool) return value ? 'True' : 'False';
  if (value is num) return pythonNumber(value);
  if (value is String) return quotedString(value);
  if (value is List) {
    if (value.isEmpty) return '[]';
    final childIndent = indent + 4;
    final lines = value
        .map(
          (item) =>
              '${' ' * childIndent}${pythonLiteral(item, indent: childIndent)},',
        )
        .join('\n');
    return '[\n$lines\n${' ' * indent}]';
  }
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
          (left, right) => left.key.toString().compareTo(right.key.toString()));
    if (entries.isEmpty) return '{}';
    if (entries.any((entry) => entry.key is! String)) {
      throw StateError('Generated maps must use String keys.');
    }
    final childIndent = indent + 4;
    final lines = entries
        .map(
          (entry) =>
              '${' ' * childIndent}${quotedString(entry.key as String)}: '
              '${pythonLiteral(entry.value, indent: childIndent)},',
        )
        .join('\n');
    return '{\n$lines\n${' ' * indent}}';
  }
  throw StateError('Unsupported Python literal value: ${value.runtimeType}.');
}

String typeScriptLiteral(Object? value, {int indent = 0}) {
  if (value == null) return 'null';
  if (value is bool) return value ? 'true' : 'false';
  if (value is num) return typeScriptNumber(value);
  if (value is String) return quotedString(value);
  if (value is List) {
    if (value.isEmpty) return '[]';
    final childIndent = indent + 2;
    final lines = value
        .map(
          (item) =>
              '${' ' * childIndent}${typeScriptLiteral(item, indent: childIndent)},',
        )
        .join('\n');
    return '[\n$lines\n${' ' * indent}]';
  }
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort(
          (left, right) => left.key.toString().compareTo(right.key.toString()));
    if (entries.isEmpty) return '{}';
    if (entries.any((entry) => entry.key is! String)) {
      throw StateError('Generated objects must use String keys.');
    }
    final childIndent = indent + 2;
    final lines = entries
        .map(
          (entry) =>
              '${' ' * childIndent}${quotedString(entry.key as String)}: '
              '${typeScriptLiteral(entry.value, indent: childIndent)},',
        )
        .join('\n');
    return '{\n$lines\n${' ' * indent}}';
  }
  throw StateError(
    'Unsupported TypeScript literal value: ${value.runtimeType}.',
  );
}

String pythonNumber(num value) {
  if (value is double && value.isNaN) return 'float("nan")';
  if (value == double.infinity) return 'float("inf")';
  if (value == double.negativeInfinity) return 'float("-inf")';
  return value.toString();
}

String typeScriptNumber(num value) {
  if (value is double && value.isNaN) return 'Number.NaN';
  if (value == double.infinity) return 'Number.POSITIVE_INFINITY';
  if (value == double.negativeInfinity) return 'Number.NEGATIVE_INFINITY';
  return value.toString();
}

String pythonType(Object? value) {
  if (value == null) return 'Any';
  if (value is bool) return 'bool';
  if (value is int) return 'int';
  if (value is num) return 'float';
  if (value is String) return 'str';
  if (value is List) {
    if (value.isEmpty) return 'list[Any]';
    final types = value.map(pythonType).toSet();
    return types.length == 1 ? 'list[${types.single}]' : 'list[Any]';
  }
  if (value is Map) return 'dict[str, Any]';
  return 'Any';
}

String typeScriptType(Object? value) {
  if (value == null) return 'unknown';
  if (value is bool) return 'boolean';
  if (value is num) return 'number';
  if (value is String) return 'string';
  if (value is List) {
    if (value.isEmpty) return 'unknown[]';
    final types = value.map(typeScriptType).toSet().toList()..sort();
    return 'Array<${types.join(' | ')}>';
  }
  if (value is Map) return 'Record<string, unknown>';
  return 'unknown';
}

const pythonReservedWords = <String>{
  'False',
  'None',
  'True',
  'and',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'class',
  'continue',
  'def',
  'del',
  'elif',
  'else',
  'except',
  'finally',
  'for',
  'from',
  'global',
  'if',
  'import',
  'in',
  'is',
  'lambda',
  'match',
  'nonlocal',
  'not',
  'or',
  'pass',
  'raise',
  'return',
  'try',
  'type',
  'while',
  'with',
  'yield',
};

const typeScriptReservedWords = <String>{
  'any',
  'as',
  'async',
  'await',
  'boolean',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'constructor',
  'continue',
  'debugger',
  'declare',
  'default',
  'delete',
  'do',
  'else',
  'enum',
  'export',
  'extends',
  'false',
  'finally',
  'for',
  'from',
  'function',
  'get',
  'if',
  'implements',
  'import',
  'in',
  'infer',
  'instanceof',
  'interface',
  'is',
  'keyof',
  'let',
  'module',
  'namespace',
  'never',
  'new',
  'null',
  'number',
  'object',
  'of',
  'package',
  'private',
  'protected',
  'public',
  'readonly',
  'require',
  'return',
  'set',
  'static',
  'string',
  'super',
  'switch',
  'symbol',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typeof',
  'undefined',
  'unique',
  'unknown',
  'var',
  'void',
  'while',
  'with',
  'yield',
};
