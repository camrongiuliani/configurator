import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:configurator_annotations/configurator_annotations.dart';
import 'package:configurator_builder/src/model/configuration.dart';
import 'package:configurator_builder/src/processor/configuration.dart';
import 'package:configurator_annotations/configurator_annotations.dart' as annotations;
import 'package:source_gen/source_gen.dart' ;
import 'package:build/build.dart';

class ConfiguratorGenerator extends GeneratorForAnnotation<ConfiguratorApp> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [Configurator] annotation from `$friendlyName`.',
      );
    }

    ProcessedConfig framework = ConfigProcessor( element, annotations.ConfiguratorApp ).process();

    return framework.write();

  }
}