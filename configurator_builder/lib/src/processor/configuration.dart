import 'dart:io';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:configurator_annotations/configurator_annotations.dart' as annotations;
import 'package:configurator_builder/src/model/configuration.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:configurator_builder/src/processor/route.dart';
import 'package:configurator_builder/src/processor/setting.dart';
import 'package:configurator_builder/src/type_utils.dart';
import 'package:configurator_builder/src/iterable_extension.dart';
import 'package:yaml/yaml.dart';

class ConfigProcessor extends Processor<ProcessedConfig> {

  final ClassElement _frameworkElement;
  late final DartObject? _configAnnotation;

  ConfigProcessor( this._frameworkElement ) {
    _configAnnotation = _getConfigAnnotation();
  }

  @override
  ProcessedConfig process() {

    final List<String> yamlInput = _getYamlPaths();

    final List<File> yamlFiles = yamlInput.map((e) => File( e )).toList();

    final List<String> yamlContents = yamlFiles.map((e) => e.readAsStringSync()).toList();

    final List<YamlDocument> yamlDocs = yamlContents.map((e) => loadYamlDocument( e )).toList();

    final List<YamlNode> yamlNodes = yamlDocs.map((e) => e.contents).toList();

    final List<ProcessedSetting> flags = yamlNodes
        .map((e) => SettingProcessor( e, 'flags' ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    final List<ProcessedSetting> images = yamlNodes
        .map((e) => SettingProcessor( e, 'images' ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    final List<ProcessedRoute> routes = yamlNodes
        .map((e) => RouteProcessor( e ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    return ProcessedConfig( _frameworkElement, flags, images, routes );
  }

  DartObject? _getConfigAnnotation() {
    return _frameworkElement.getAnnotation( annotations.Configurator );
  }

  List<String> _getYamlPaths() {
    return _configAnnotation
        ?.getField( 'yaml' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toStringValue())
        .toList() ?? [];
  }
}