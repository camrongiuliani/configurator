import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/margin_writer.dart';
import 'package:configurator/src/writers/misc_writer.dart';
import 'package:configurator/src/writers/padding_writer.dart';
import 'package:configurator/src/writers/title_writer.dart';
import 'package:configurator/src/writers/config_ext_writer.dart';
import 'package:configurator/src/writers/configuration_writer.dart';
import 'package:configurator/src/writers/flag_writer.dart';
import 'package:configurator/src/writers/image_writer.dart';
import 'package:configurator/src/writers/key_writer.dart';
import 'package:configurator/src/writers/route_writer.dart';
import 'package:configurator/src/writers/color_writer.dart';
import 'package:configurator/src/writers/size_writer.dart';
import 'package:configurator/src/writers/slang_writer.dart';
import 'package:configurator/src/writers/theme_writer.dart';
import 'package:configurator/src/writers/text_style_writer.dart';

class ProcessedConfig {
  final YamlConfiguration yamlConfiguration;
  final String frameworkName;

  ProcessedConfig(this.frameworkName, this.yamlConfiguration);

  Future write(bool pureDart) async {
    LibraryBuilder builder = LibraryBuilder();

    builder.directives.addAll([
      if (pureDart) ...[
        Directive.import('package:configurator/configurator.dart'),
      ] else ...[
        Directive.import('dart:ui'),
        Directive.import('package:flutter/material.dart'),
        Directive.import('package:collection/collection.dart'),
        Directive.import(
            'package:configurator_flutter/configurator_flutter.dart'),
      ]
    ]);

    builder.body.addAll([
      TitleWriter('ignore_for_file: type=lint').write(),
      TitleWriter('Keys').write(),
      KeyWriter(frameworkName, yamlConfiguration).write(),
      if (!pureDart) ...[
        TitleWriter('Theme').write(),
        ThemeWriter(frameworkName, yamlConfiguration).write(),
      ],
      TitleWriter('Flags').write(),
      FlagWriter(frameworkName, yamlConfiguration.flags).write(),
      TitleWriter('Images').write(),
      ImageWriter(frameworkName, yamlConfiguration.images).write(),
      TitleWriter('Routes').write(),
      RouteWriter(frameworkName, yamlConfiguration.routes).write(),
      TitleWriter('Colors').write(),
      ColorWriter(frameworkName, yamlConfiguration.colors).write(),
      TitleWriter('Sizes').write(),
      SizeWriter(frameworkName, yamlConfiguration.sizes).write(),
      TitleWriter('Padding').write(),
      PaddingWriter(frameworkName, yamlConfiguration.padding).write(),
      TitleWriter('Margins').write(),
      MarginWriter(frameworkName, yamlConfiguration.margins).write(),
      TitleWriter('Misc').write(),
      MiscWriter(frameworkName, yamlConfiguration.misc).write(),
      TitleWriter('TextStyles').write(),
      TextStyleWriter(frameworkName, yamlConfiguration.textStyles).write(),
      TitleWriter('Strings').write(),
      SlangWriter(yamlConfiguration.i18n).write(),
      TitleWriter('Configuration').write(),
      ConfigWriter(
        name: frameworkName,
        weight: yamlConfiguration.weight,
        strings: yamlConfiguration.i18n,
        routes: yamlConfiguration.routes,
        flags: yamlConfiguration.flags,
        colors: yamlConfiguration.colors,
        misc: yamlConfiguration.misc,
        textStyles: yamlConfiguration.textStyles,
        sizes: yamlConfiguration.sizes,
        margins: yamlConfiguration.margins,
        padding: yamlConfiguration.padding,
        images: yamlConfiguration.images,
      ).write(),
      TitleWriter('Configuration Extension').write(),
      ConfigExtWriter().write(),
    ]);

    final lib = builder.build();

    return lib.accept(DartEmitter()).toString();
  }
}
