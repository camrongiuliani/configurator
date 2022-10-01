import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';

abstract class ConfigScope {

  abstract final String name;

  Map<String, bool> get flags;
  Map<String, String?> get images;
  Map<String, String> get colors;
  Map<String, double> get sizes;
  Map<int, String?> get routes;


  static ConfigScope empty({ required String name }) {
    return ProxyScope( name: name );
  }

  static ConfigScope fromYaml( String yamlString ) {
    final YamlConfiguration config = YamlParser.fromYamlString( yamlString );

    return ProxyScope(
      name: config.name,
      flags: { for (var e in config.flags) e.name : e.value },
      images: { for (var e in config.images) e.name : e.value },
      routes: { for (var e in config.routes) e.name : e.value },
      sizes: { for (var e in config.sizes) e.name : e.value },
      colors: { for (var e in config.colors) e.name : e.value },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flags': { for (var e in flags.entries) e.key: e.value},
      'images': { for (var e in images.entries) e.key: e.value},
      'sizes': { for (var e in sizes.entries) e.key: e.value},
      'colors': { for (var e in colors.entries) e.key: e.value},
      'routes': { for (var e in routes.entries) e.key : e.value },
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigScope &&
          name == other.name &&
          const MapEquality().equals( flags, other.flags ) &&
          const MapEquality().equals( images, other.images ) &&
          const MapEquality().equals( routes, other.routes ) &&
          const MapEquality().equals( colors, other.colors ) &&
          const MapEquality().equals( sizes, other.sizes );

  @override
  int get hashCode =>
      name.hashCode
      ^ flags.hashCode
      ^ images.hashCode
      ^ routes.hashCode
      ^ colors.hashCode
      ^ sizes.hashCode;
}