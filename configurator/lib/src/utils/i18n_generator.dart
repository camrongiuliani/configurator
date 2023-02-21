import 'dart:collection';

import 'package:configurator/src/utils/string_ext.dart';
import 'package:slang/builder/generator/helper.dart';
import 'package:slang/builder/model/enums.dart';
import 'package:slang/builder/model/generate_config.dart';
import 'package:slang/builder/model/i18n_data.dart';
import 'package:slang/builder/model/i18n_locale.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang/builder/model/pluralization.dart';

/// decides which class should be generated
class ClassTask {
  final String className;
  final ObjectNode node;

  ClassTask(this.className, this.node);
}

/// generates all classes of one locale
/// all non-default locales has a postfix of their locale code
/// e.g. Strings, StringsDe, StringsFr
String generateSlangTranslations(GenerateConfig config, I18nData localeData) {
  final queue = Queue<ClassTask>();
  final buffer = StringBuffer();

  queue.add(
    ClassTask(
      getClassNameRoot(
        baseName: config.baseName,
        visibility: config.translationClassVisibility,
      ),
      localeData.root,
    ),
  );

  // only for the first class
  bool root = true;

  do {
    ClassTask task = queue.removeFirst();

    _generateClass(
        config, localeData, buffer, queue, task.className, task.node, root);

    root = false;
  } while (queue.isNotEmpty);

  return buffer.toString();
}

/// generates a class and all of its members of ONE locale
/// adds subclasses to the queue
void _generateClass(
  GenerateConfig config,
  I18nData localeData,
  StringBuffer buffer,
  Queue<ClassTask> queue,
  String className,
  ObjectNode node,
  bool root,
) {
  buffer.writeln();

  // final baseClassName = getClassName(
  //   parentName: className,
  //   locale: config.baseLocale,
  // );
  // final rootClassName = getClassNameRoot(
  //   baseName: config.baseName,
  //   visibility: config.translationClassVisibility,
  //   locale: localeData.locale,
  // );
  // final finalClassName = getClassName(
  //   parentName: className,
  //   locale: localeData.locale,
  // );

  buffer.writeln('class $className {');

  // constructor and custom fields

  buffer.writeln();

  buffer.writeln('\t$className(this._config);');
  buffer.writeln();

  buffer.writeln('''
    final Configuration _config;

    String _localize(String input) {
      return i18n.localize(
        input,
        i18n.Translations.from(
          "en_us",
          _config.currentTranslations(input),
        ),
      );
    }
  ''');


  buffer.writeln();
  buffer.writeln();
  buffer.writeln('\t// Translations');

  bool prevHasComment = false;
  node.entries.forEach((key, value) {
    // comment handling
    if (value.comment != null) {
      // add comment add on the line above
      buffer.writeln();
      buffer.writeln('\t/// ${value.comment}');
      prevHasComment = true;
    } else {
      if (prevHasComment) {
        // add a new line to separate from previous entry with comment
        buffer.writeln();
      }
      prevHasComment = false;
    }

    buffer.write('\t');

    if (value is StringTextNode) {
      if (value.params.isEmpty) {
        buffer.writeln(
            'String get $key => _localize(\'${value.path.canonicalize}\');');
      } else {
        buffer.writeln(
            'String $key${_toParameterList(value.params, value.paramTypeMap)} => _localize(\'${value.path.canonicalize}\').fill([${value.params.join(',')}]);');
      }
    } else if (value is RichTextNode) {
      buffer.write('TextSpan ');
      if (value.params.isEmpty) {
        buffer.write('get $key');
      } else {
        buffer.write(key);
      }
      _addRichTextCall(
        buffer: buffer,
        config: config,
        node: value,
        includeArrowIfNoParams: true,
        depth: 0,
      );
    } else if (value is ListNode) {
      buffer.write('List<${value.genericType}> get $key => ');
      _generateList(
        config: config,
        base: localeData.base,
        locale: localeData.locale,
        buffer: buffer,
        queue: queue,
        className: className,
        node: value,
        depth: 0,
      );
    } else if (value is ObjectNode) {
      String childClassNoLocale =
          getClassName(parentName: className, childName: key);

      if (value.isMap) {
        // inline map
        buffer.write('Map<String, ${value.genericType}> get $key => ');
        _generateMap(
          config: config,
          base: localeData.base,
          locale: localeData.locale,
          buffer: buffer,
          queue: queue,
          className: childClassNoLocale,
          node: value,
          depth: 0,
        );
      } else {
        // generate a class later on
        queue.add(ClassTask(childClassNoLocale, value));
        String childClassWithLocale = getClassName(
          parentName: className,
          childName: key,
        );
        buffer.writeln(
            'late final $childClassWithLocale $key = $childClassWithLocale(_config);');
      }
    } else if (value is PluralNode) {
      final returnType = value.rich ? 'TextSpan' : 'String';
      buffer.write('$returnType $key');
      _addPluralizationCall(
        buffer: buffer,
        config: config,
        language: localeData.locale.language,
        node: value,
        depth: 0,
      );
    } else if (value is ContextNode) {
      final returnType = value.rich ? 'TextSpan' : 'String';
      buffer.write('$returnType $key');
      _addContextCall(
        buffer: buffer,
        config: config,
        node: value,
        depth: 0,
      );
    }
  });

  buffer.writeln('}');
}

/// generates a map of ONE locale
/// similar to _generateClass but anonymous and accessible via key
void _generateMap({
  required GenerateConfig config,
  required bool base,
  required I18nLocale locale,
  required StringBuffer buffer,
  required Queue<ClassTask> queue,
  required String className, // without locale
  required ObjectNode node,
  required int depth,
}) {
  if (config.translationOverrides && node.genericType == 'String') {
    buffer
        .write('TranslationOverrides.map(_root.\$meta, \'${node.path}\') ?? ');
  }
  buffer.writeln('{');

  node.entries.forEach((key, value) {
    _addTabs(buffer, depth + 2);
    if (value is StringTextNode) {
      if (value.params.isEmpty) {
        buffer.writeln('\'$key\': _localize(\'${value.path.canonicalize}\'),');
      } else {
        buffer.writeln(
            '\'$key\': ${_toParameterList(value.params, value.paramTypeMap)} => _localize(\'${value.path.canonicalize}\'),');
      }
    } else if (value is ListNode) {
      buffer.write('\'$key\': ');
      _generateList(
        config: config,
        base: base,
        locale: locale,
        buffer: buffer,
        queue: queue,
        className: className,
        node: value,
        depth: depth + 1,
      );
    } else if (value is ObjectNode) {
      String childClassNoLocale =
          getClassName(parentName: className, childName: key);

      if (value.isMap) {
        // inline map
        buffer.write('\'$key\': ');
        _generateMap(
          config: config,
          base: base,
          locale: locale,
          buffer: buffer,
          queue: queue,
          className: childClassNoLocale,
          node: value,
          depth: depth + 1,
        );
      } else {
        // generate a class later on
        queue.add(ClassTask(childClassNoLocale, value));
        String childClassWithLocale =
            getClassName(parentName: className, childName: key);
        buffer.writeln('\'$key\': $childClassWithLocale(_config),');
      }
    } else if (value is PluralNode) {
      buffer.write('\'$key\': ');
      _addPluralizationCall(
        buffer: buffer,
        config: config,
        language: locale.language,
        node: value,
        depth: depth + 1,
      );
    } else if (value is ContextNode) {
      buffer.write('\'$key\': ');
      _addContextCall(
        buffer: buffer,
        config: config,
        node: value,
        depth: depth + 1,
      );
    }
  });

  _addTabs(buffer, depth + 1);

  buffer.write('}');

  if (depth == 0) {
    buffer.writeln(';');
  } else {
    buffer.writeln(',');
  }
}

/// generates a list
void _generateList({
  required GenerateConfig config,
  required bool base,
  required I18nLocale locale,
  required StringBuffer buffer,
  required Queue<ClassTask> queue,
  required String className,
  required ListNode node,
  required int depth,
}) {
  if (config.translationOverrides && node.genericType == 'String') {
    buffer
        .write('TranslationOverrides.list(_root.\$meta, \'${node.path}\') ?? ');
  }

  buffer.writeln('[');

  for (int i = 0; i < node.entries.length; i++) {
    final Node value = node.entries[i];

    _addTabs(buffer, depth + 2);
    if (value is StringTextNode) {
      if (value.params.isEmpty) {
        buffer.writeln('_localize(\'${value.path.canonicalize}\'),');
      } else {
        buffer.writeln(
            '${_toParameterList(value.params, value.paramTypeMap)} => _localize(\'${value.path.canonicalize}\'),');
      }
    } else if (value is ListNode) {
      _generateList(
        config: config,
        base: base,
        locale: locale,
        buffer: buffer,
        queue: queue,
        className: className,
        node: value,
        depth: depth + 1,
      );
    } else if (value is ObjectNode) {
      final String key = depth.toString() + 'i' + i.toString();
      final String childClassNoLocale =
          getClassName(parentName: className, childName: key);

      if (value.isMap) {
        // inline map
        _generateMap(
          config: config,
          base: base,
          locale: locale,
          buffer: buffer,
          queue: queue,
          className: childClassNoLocale,
          node: value,
          depth: depth + 1,
        );
      } else {
        // generate a class later on
        queue.add(ClassTask(childClassNoLocale, value));
        String childClassWithLocale = getClassName(
          parentName: className,
          childName: key,
          // locale: locale,
        );
        buffer.writeln('$childClassWithLocale(_config),');
      }
    } else if (value is PluralNode) {
      _addPluralizationCall(
        buffer: buffer,
        config: config,
        language: locale.language,
        node: value,
        depth: depth + 1,
      );
    } else if (value is ContextNode) {
      _addContextCall(
        buffer: buffer,
        config: config,
        node: value,
        depth: depth + 1,
      );
    }
  }

  _addTabs(buffer, depth + 1);

  buffer.write(']');

  if (depth == 0) {
    buffer.writeln(';');
  } else {
    buffer.writeln(',');
  }
}

/// returns the parameter list
/// e.g. ({required Object name, required Object age})
String _toParameterList(Set<String> params, Map<String, String> paramTypeMap) {
  if (params.isEmpty) {
    return '()';
  }
  StringBuffer buffer = StringBuffer();
  buffer.write('({');
  bool first = true;
  for (final param in params) {
    if (!first) buffer.write(', ');
    buffer.write('required ${paramTypeMap[param] ?? 'Object'} ');
    buffer.write(param);
    first = false;
  }
  buffer.write('})');
  return buffer.toString();
}

/// returns a map containing all parameters
/// e.g. {'name': name, 'age': age}
String _toParameterMap(Set<String> params) {
  StringBuffer buffer = StringBuffer();
  buffer.write('{');
  bool first = true;
  for (final param in params) {
    if (!first) buffer.write(', ');
    buffer.write('\'');
    buffer.write(param);
    buffer.write('\': ');
    buffer.write(param);
    first = false;
  }
  buffer.write('}');
  return buffer.toString();
}

void _addPluralizationCall({
  required StringBuffer buffer,
  required GenerateConfig config,
  required String language,
  required PluralNode node,
  required int depth,
  bool forceSemicolon = false,
}) {
  final textNodeList = node.quantities.values.toList();

  if (textNodeList.isEmpty) {
    throw ('${node.path} is empty but it is marked for pluralization.');
  }

  // parameters are union sets over all plural forms
  final paramSet = <String>{};
  final paramTypeMap = <String, String>{};
  for (final textNode in textNodeList) {
    paramSet.addAll(textNode.params);
    paramTypeMap.addAll(textNode.paramTypeMap);
  }
  final params = paramSet.where((p) => p != node.paramName).toList();

  // add plural parameter first
  buffer.write('({required num ${node.paramName}');
  if (node.rich) {
    buffer
        .write(', required InlineSpan Function(num) ${node.paramName}Builder');
  }
  for (int i = 0; i < params.length; i++) {
    buffer.write(', required ${paramTypeMap[params[i]] ?? 'Object'} ');
    buffer.write(params[i]);
  }

  // custom resolver has precedence
  final prefix = node.pluralType.name;
  buffer.write('}) => ');

  if (node.rich) {
    final translationOverrides = config.translationOverrides
        ? 'TranslationOverridesFlutter.richPlural(_root.\$meta, \'${node.path}\', ${_toParameterMap({
                ...params,
                node.paramName,
                '${node.paramName}Builder',
              })}) ?? '
        : '';
    buffer.writeln('${translationOverrides}RichPluralResolvers.bridge(');
    _addTabs(buffer, depth + 2);
    buffer.writeln('n: ${node.paramName},');
    _addTabs(buffer, depth + 2);
    buffer.writeln(
        'resolver: _root.\$meta.${prefix}Resolver ?? PluralResolvers.$prefix(\'$language\'),');
    for (final quantity in node.quantities.entries) {
      _addTabs(buffer, depth + 2);
      buffer.write('${quantity.key.paramName()}: () => ');

      buffer.write('TextSpan(children: [');
      for (final span in (quantity.value as RichTextNode).spans) {
        if (span is VariableSpan && span.variableName == node.paramName) {
          // the 'n' is now a builder, e.g. 'nBuilder'
          buffer.write('${node.paramName}Builder(${node.paramName})');
        } else {
          buffer.write(span.code);
        }
        buffer.write(',');
      }
      buffer.write('])');
      buffer.writeln(',');
    }
  } else {
    final translationOverrides = config.translationOverrides
        ? 'TranslationOverrides.plural(_root.\$meta, \'${node.path}\', ${_toParameterMap({
                ...params,
                node.paramName,
              })}) ?? '
        : '';
    buffer.writeln(
        '$translationOverrides(_root.\$meta.${prefix}Resolver ?? PluralResolvers.$prefix(\'$language\'))(${node.paramName},');
    for (final quantity in node.quantities.entries) {
      _addTabs(buffer, depth + 2);
      buffer.writeln(
          '${quantity.key.paramName()}: \'${(quantity.value as StringTextNode).content}\',');
    }
  }

  _addTabs(buffer, depth + 1);
  buffer.write(')');

  if (depth == 0 || forceSemicolon) {
    buffer.writeln(';');
  } else {
    buffer.writeln(',');
  }
}

void _addRichTextCall({
  required StringBuffer buffer,
  required GenerateConfig config,
  required RichTextNode node,
  required bool includeArrowIfNoParams,
  required int depth,
  bool forceSemicolon = false,
}) {
  if (node.params.isNotEmpty) {
    buffer.write(_toParameterList(node.params, node.paramTypeMap));
  }

  if (node.params.isNotEmpty || includeArrowIfNoParams) {
    buffer.write(' => ');
  }

  if (config.translationOverrides) {
    buffer.write(
        'TranslationOverridesFlutter.rich(_root.\$meta, \'${node.path}\', ${_toParameterMap(node.params)}) ?? ');
  }

  buffer.writeln('TextSpan(children: [');
  for (final span in node.spans) {
    _addTabs(buffer, depth + 2);
    if (span is FunctionSpan) {
      buffer.write("${span.functionName}(_localize('${node.path.canonicalize}'))");
    } else {
      buffer.write(span.code);
    }
    buffer.writeln(',');
  }
  _addTabs(buffer, depth + 1);
  if (depth == 0 || forceSemicolon) {
    buffer.writeln(']);');
  } else {
    buffer.writeln(']),');
  }
}

void _addContextCall({
  required StringBuffer buffer,
  required GenerateConfig config,
  required ContextNode node,
  required int depth,
  bool forceSemicolon = false,
}) {
  final textNodeList = node.entries.values.toList();

  // parameters are union sets over all context forms
  final paramSet = <String>{};
  final paramTypeMap = <String, String>{};
  for (final textNode in textNodeList) {
    paramSet.addAll(textNode.params);
    paramTypeMap.addAll(textNode.paramTypeMap);
  }
  final params = paramSet.where((p) => p != node.paramName).toList();

  // parameters with context as first parameter
  buffer.write('({required ${node.context.enumName} ${node.paramName}');
  if (node.rich) {
    buffer.write(
        ', required InlineSpan Function(${node.context.enumName}) ${node.paramName}Builder');
  }
  for (int i = 0; i < params.length; i++) {
    buffer.write(', required ${paramTypeMap[params[i]] ?? 'Object'} ');
    buffer.write(params[i]);
  }
  buffer.writeln('}) {');

  if (config.translationOverrides) {
    final functionCall = node.rich
        ? 'TranslationOverridesFlutter.richContext<${node.context.enumName}>'
        : 'TranslationOverrides.context';

    _addTabs(buffer, depth + 2);
    buffer.writeln(
        'final override = $functionCall(_config.\$meta, \'${node.path}\', ${_toParameterMap({
          ...params,
          node.paramName,
          if (node.rich) '${node.paramName}Builder',
        })});');

    _addTabs(buffer, depth + 2);
    buffer.writeln('if (override != null) {');

    _addTabs(buffer, depth + 3);
    buffer.writeln('return override;');

    _addTabs(buffer, depth + 2);
    buffer.writeln('}');
  }

  _addTabs(buffer, depth + 2);
  buffer.writeln('switch (${node.paramName}) {');

  for (final entry in node.entries.entries) {
    _addTabs(buffer, depth + 3);
    buffer.write('case ${node.context.enumName}.${entry.key}: return ');
    if (node.rich) {
      buffer.write('TextSpan(children: [');
      for (final span in (entry.value as RichTextNode).spans) {
        if (span is VariableSpan && span.variableName == node.paramName) {
          // the 'context' is now a builder, e.g. 'contextBuilder'
          buffer.write('${node.paramName}Builder(${node.paramName})');
        } else {
          buffer.write(span.code);
        }
        buffer.write(',');
      }
      buffer.writeln(']);');
    } else {
      buffer.writeln('\'${(entry.value as StringTextNode).content}\';');
    }
  }

  _addTabs(buffer, depth + 2);
  buffer.writeln('}');

  _addTabs(buffer, depth + 1);
  buffer.write('}');

  if (forceSemicolon) {
    buffer.writeln(';');
  } else if (depth != 0) {
    buffer.writeln(',');
  } else {
    buffer.writeln();
  }
}

/// writes count times \t to the buffer
void _addTabs(StringBuffer buffer, int count) {
  for (int i = 0; i < count; i++) {
    buffer.write('\t');
  }
}
