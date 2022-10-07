

import 'package:configurator/configurator.dart';

class ConfigFile {
  final String directory;
  final String name;
  YamlConfiguration config;

  ConfigFile( this.name, this.directory, this.config );
}