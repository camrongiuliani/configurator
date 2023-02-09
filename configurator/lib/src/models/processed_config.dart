import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/writers/font_util_writer.dart';
import 'package:configurator/src/writers/i18n_writer.dart';
import 'package:configurator/src/writers/margin_writer.dart';
import 'package:configurator/src/writers/misc_writer.dart';
import 'package:configurator/src/writers/padding_writer.dart';
import 'package:configurator/src/writers/title_writer.dart';
import 'package:configurator/src/writers/color_util_writer.dart';
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
import 'package:configurator/src/writers/weight_writer.dart';

import '../writers/text_style_writer.dart';

class ProcessedConfig {

  final YamlConfiguration yamlConfiguration;
  final String frameworkName;

  ProcessedConfig( this.frameworkName, this.yamlConfiguration );

  Future write() async {

    LibraryBuilder builder = LibraryBuilder();

    builder.directives.addAll([
      Directive.import( 'dart:ui' ),
      Directive.import( 'package:flutter/material.dart' ),
      Directive.import( 'package:google_fonts/google_fonts.dart' ),
      Directive.import( 'package:configurator_flutter/configurator_flutter.dart' ),
      Directive.import( 'package:collection/collection.dart' ),
      Directive.import( 'package:i18n_extension/i18n_extension.dart', as: 'i18n' ),
    ]);
    
    builder.body.addAll([

      TitleWriter('ignore_for_file: type=lint').write(),

      // TitleWriter( 'Color Util' ).write(),
      // ColorUtilWriter().write(),

      // TitleWriter( 'Font Util' ).write(),
      // FontUtilWriter().write(),

      TitleWriter( 'Keys' ).write(),
      KeyWriter( frameworkName, yamlConfiguration ).write(),

      TitleWriter( 'Weight' ).write(),
      WeightWriter( frameworkName, yamlConfiguration.weight ).write(),

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

      TitleWriter( 'Padding' ).write(),
      PaddingWriter( frameworkName, yamlConfiguration.padding ).write(),

      TitleWriter( 'Margins' ).write(),
      MarginWriter( frameworkName, yamlConfiguration.margins ).write(),

      TitleWriter( 'Misc' ).write(),
      MiscWriter( frameworkName, yamlConfiguration.misc ).write(),

      TitleWriter( 'TextStyles' ).write(),
      TextStyleWriter( frameworkName, yamlConfiguration.textStyles ).write(),

      // TitleWriter( 'Slang (i18n)' ).write(),
      // SlangWriter( yamlConfiguration.strings ).write(),

      TitleWriter( 'Strings' ).write(),
      I18nWriter( frameworkName, yamlConfiguration.i18n ).write(),


      TitleWriter( 'Configuration' ).write(),
      ConfigWriter( frameworkName, yamlConfiguration.i18n ).write(),

      TitleWriter( 'Configuration Extension' ).write(),
      ConfigExtWriter().write(),

    ]);

    final lib = builder.build();

    return lib.accept( DartEmitter() ).toString();
  }
}