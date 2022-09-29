import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/writer/color_util_writer.dart';
import 'package:configurator_builder/src/writer/configuration_writer.dart';
import 'package:configurator_builder/src/writer/flag_writer.dart';
import 'package:configurator_builder/src/writer/image_writer.dart';
import 'package:configurator_builder/src/writer/key_writer.dart';
import 'package:configurator_builder/src/writer/route_writer.dart';
import 'package:configurator_builder/src/writer/theme_writer.dart';
import 'package:configurator_builder/src/writer/title_writer.dart';

class ProcessedConfig {

  final ClassElement classElement;
  final List<ProcessedSetting> flags;
  final List<ProcessedSetting> images;
  final List<ProcessedRoute> routes;
  final ProcessedTheme theme;

  late final String frameworkName;

  ProcessedConfig( this.classElement, this.flags, this.images, this.routes, this.theme ) {
    frameworkName = classElement.displayName;
  }

  String write() {

    LibraryBuilder builder = LibraryBuilder();

    builder..directives.addAll([
      Directive.import( 'package:flutter/material.dart' ),
      Directive.import( 'package:configurator/configurator.dart' ),
      Directive.import( 'dart:ui' ),
    ]);

    builder..body.addAll([

      TitleWriter( 'Color Util' ).write(),
      ColorUtilWriter().write(),

      TitleWriter( 'Keys' ).write(),
      KeyWriter( flags, images, routes, theme ).write(),

      TitleWriter( 'Theme' ).write(),
      ThemeWriter( theme ).write(),

      TitleWriter( 'Flags' ).write(),
      FlagWriter( flags ).write(),

      TitleWriter( 'Images' ).write(),
      ImageWriter( images ).write(),

      TitleWriter( 'Routes' ).write(),
      RouteWriter( routes ).write(),


      TitleWriter( 'Configuration' ).write(),
      ConfigWriter().write(),

    ]);

    final lib = builder.build();

    return lib.accept( DartEmitter() ).toString();
  }
}