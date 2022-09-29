import 'dart:io';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/model/configuration.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:configurator_builder/src/type_utils.dart';
import 'package:configurator_builder/src/iterable_extension.dart';

class ConfigProcessor extends Processor<ProcessedConfig> {

  final ClassElement _frameworkElement;
  final Type annotationType;
  late final DartObject? _configAnnotation;

  ConfigProcessor( this._frameworkElement, this.annotationType ) {
    _configAnnotation = _getConfigAnnotation();
  }

  @override
  ProcessedConfig process() {

    // Read yaml paths from annotation
    final List<String> yamlInput = _getYamlPaths();

    // Ingest yaml as File(s)
    final List<File> yamlFiles = yamlInput.map((e) => File( e )).toList();

    // Read yaml bytes
    final List<String> yamlContents = yamlFiles.map((e) => e.readAsStringSync()).toList();

    // Convert to Configs
    List<YamlConfiguration> configs = yamlContents.map((e) => YamlParser.fromYamlString( e ) ).toList();

    // Combine Configs (last added takes priority).
    final YamlConfiguration reduced = configs.reduce((value, element) => value + element);

    return ProcessedConfig( _frameworkElement, reduced );
  }

  DartObject? _getConfigAnnotation() {
    return _frameworkElement.getAnnotation( annotationType );
  }

  List<String> _getYamlPaths() {
    return _configAnnotation
        ?.getField( 'yaml' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toStringValue())
        .toList() ?? [];
  }
}