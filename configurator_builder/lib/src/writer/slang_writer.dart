import 'dart:async';

import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/writer/writer.dart';
import 'package:configurator/configurator.dart';

class SlangWriter extends Writer {

  final List<YamlI18n> strings;

  SlangWriter( this.strings );

  @override
  Spec write() {
    return Code( SlangUtil.generateTranslations(
      rawConfig: {},
      i18nNodes: strings,
      verbose: true,
    ) );
  }
}