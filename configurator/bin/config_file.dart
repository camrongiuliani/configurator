import 'package:configurator/configurator.dart';

class ConfigFile {
  final String directory;
  final String name;
  YamlConfiguration config;

  ConfigFile( this.name, this.directory, this.config );

  @override
  String toString() {
    return config.name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ConfigFile
          && other.name == name
          && other.config.name == other.config.name;

  @override
  int get hashCode =>
      directory.hashCode ^
      name.hashCode ^
      config.hashCode;
}