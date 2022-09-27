import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/writer/configuration_writer.dart';
import 'package:configurator_builder/src/writer/flag_writer.dart';
import 'package:configurator_builder/src/writer/image_writer.dart';
import 'package:configurator_builder/src/writer/key_writer.dart';
import 'package:configurator_builder/src/writer/route_writer.dart';
import 'package:configurator_builder/src/writer/title_writer.dart';

class ProcessedConfig {

  final ClassElement classElement;
  final List<ProcessedSetting> flags;
  final List<ProcessedSetting> images;
  final List<ProcessedRoute> routes;

  late final String frameworkName;

  ProcessedConfig( this.classElement, this.flags, this.images, this.routes ) {
    frameworkName = classElement.displayName;
  }

  String write() {

    LibraryBuilder builder = LibraryBuilder();

    builder..body.addAll([

      KeyWriter( flags, images, routes ).write(),

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