

import 'package:configurator/configurator.dart';

class ConfigFile {
  final String directory;
  final String name;
  YamlConfiguration config;

  ConfigFile? parent;
  List<ConfigFile> children = [];

  ConfigFile( this.name, this.directory, this.config );
}