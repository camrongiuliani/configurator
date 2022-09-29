import 'dart:io';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:configurator_annotations/configurator_annotations.dart' as annotations;
import 'package:configurator_builder/src/model/configuration.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:configurator_builder/src/processor/route.dart';
import 'package:configurator_builder/src/processor/setting.dart';
import 'package:configurator_builder/src/processor/theme.dart';
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

    // Read yaml paths from annotation
    final List<String> yamlInput = _getYamlPaths();

    // Ingest yaml as File(s)
    final List<File> yamlFiles = yamlInput.map((e) => File( e )).toList();

    // Read yaml bytes
    final List<String> yamlContents = yamlFiles.map((e) => e.readAsStringSync()).toList();

    // Convert to YamlDocuments
    final List<YamlDocument> yamlDocs = yamlContents.map((e) => loadYamlDocument( e )).toList();

    // Get the root nodes of each document
    final List<YamlNode> yamlNodes = yamlDocs.map((e) => e.contents).toList();

    // Process the flags
    final List<ProcessedSetting> flags = yamlNodes
        .map((e) => SettingProcessor( e, 'flags' ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    // Process the images
    final List<ProcessedSetting> images = yamlNodes
        .map((e) => SettingProcessor( e, 'images' ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    // Process the routes
    final List<ProcessedRoute> routes = yamlNodes
        .map((e) => RouteProcessor( e ).process())
        .reduce((value, element) => [
          ...value,
          ...element,
    ]).toList();

    // Process the themes
    final ProcessedTheme theme = yamlNodes
        .map((e) => ThemeProcessor( e ).process())
        .reduce((value, element) => value + element);

    return ProcessedConfig( _frameworkElement, flags, images, routes, theme );
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