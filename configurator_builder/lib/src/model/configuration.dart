import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/writer/color_util_writer.dart';
import 'package:configurator_builder/src/writer/config_ext_writer.dart';
import 'package:configurator_builder/src/writer/configuration_writer.dart';
import 'package:configurator_builder/src/writer/flag_writer.dart';
import 'package:configurator_builder/src/writer/image_writer.dart';
import 'package:configurator_builder/src/writer/key_writer.dart';
import 'package:configurator_builder/src/writer/route_writer.dart';
import 'package:configurator_builder/src/writer/color_writer.dart';
import 'package:configurator_builder/src/writer/size_writer.dart';
import 'package:configurator_builder/src/writer/slang_writer.dart';
import 'package:configurator_builder/src/writer/theme_writer.dart';
import 'package:configurator_builder/src/writer/title_writer.dart';

class ProcessedConfig {

  final YamlConfiguration yamlConfiguration;
  final String frameworkName;

  ProcessedConfig( this.frameworkName, this.yamlConfiguration );

  Future write() async {

    LibraryBuilder builder = LibraryBuilder();

    builder..directives.addAll([
      Directive.import( 'package:flutter/material.dart' ),
      Directive.import( 'package:configurator_flutter/configurator_flutter.dart' ),
      Directive.import( 'dart:ui' ),
      Directive.import( 'package:slang/builder/model/node.dart' ),
      Directive.export( 'package:slang_flutter/slang_flutter.dart' ),
    ]);

    builder..body.addAll([

      TitleWriter( 'Color Util' ).write(),
      ColorUtilWriter().write(),

      TitleWriter( 'Keys' ).write(),
      KeyWriter( frameworkName, yamlConfiguration ).write(),

      TitleWriter( 'Theme' ).write(),
      ThemeWriter( frameworkName, yamlConfiguration ).write(),

      TitleWriter( 'Flags' ).write(),
      FlagWriter( frameworkName, yamlConfiguration.flags ).write(),

      TitleWriter( 'Images' ).write(),
      ImageWriter( frameworkName, yamlConfiguration.images ).write(),

      TitleWriter( 'Routes' ).write(),
      RouteWriter( frameworkName, yamlConfiguration.routes ).write(),

      TitleWriter( 'Colors' ).write(),
      ColorWriter( frameworkName, yamlConfiguration.colors ).write(),

      TitleWriter( 'Sizes' ).write(),
      SizeWriter( frameworkName, yamlConfiguration.sizes ).write(),

      TitleWriter( 'Slang (i18n)' ).write(),
      SlangWriter( yamlConfiguration.strings ).write(),

      TitleWriter( 'Configuration' ).write(),
      ConfigWriter( frameworkName ).write(),

      TitleWriter( 'Configuration Extension' ).write(),
      ConfigExtWriter().write(),

    ]);

    final lib = builder.build();

    return lib.accept( DartEmitter() ).toString();
  }
}