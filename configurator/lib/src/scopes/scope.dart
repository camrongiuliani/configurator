import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';

abstract class ConfigScope {

  abstract final String name;

  List<String> get partFiles => [];
  int get weight;
  Map<String, bool> get flags;
  Map<String, dynamic> get images;
  Map<String, dynamic> get misc;
  Map<String, String> get colors;
  Map<String, double> get sizes;
  Map<String, double> get padding;
  Map<String, double> get margins;
  Map<int, String?> get routes;


  static ConfigScope empty({ required String name }) {
    return ProxyScope( name: name );
  }

  static ConfigScope fromYaml( String yamlString ) {
    final YamlConfiguration config = YamlParser.fromYamlString( yamlString );

    return ProxyScope(
      name: config.name,
      partFiles: config.partFiles,
      weight: config.weight,
      flags: { for (var e in config.flags) e.name : e.value },
      images: { for (var e in config.images) e.name : e.value },
      misc: { for (var e in config.misc) e.name : e.value },
      routes: { for (var e in config.routes) e.id : e.path },
      sizes: { for (var e in config.sizes) e.name : e.value },
      padding: { for (var e in config.padding) e.name : e.value },
      margins: { for (var e in config.margins) e.name : e.value },
      colors: { for (var e in config.colors) e.name : e.value },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partFiles': partFiles,
      'flags': { for (var e in flags.entries) e.key: e.value},
      'images': { for (var e in images.entries) e.key: e.value},
      'misc': { for (var e in misc.entries) e.key: e.value},
      'sizes': { for (var e in sizes.entries) e.key: e.value},
      'padding': { for (var e in padding.entries) e.key: e.value},
      'margins': { for (var e in margins.entries) e.key: e.value},
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
          const ListEquality().equals( partFiles, other.partFiles ) &&
          const MapEquality().equals( images, other.images ) &&
          const MapEquality().equals( misc, other.misc ) &&
          const MapEquality().equals( routes, other.routes ) &&
          const MapEquality().equals( colors, other.colors ) &&
          const MapEquality().equals( padding, other.padding ) &&
          const MapEquality().equals( margins, other.margins ) &&
          const MapEquality().equals( sizes, other.sizes );

  @override
  int get hashCode =>
      name.hashCode
      ^ flags.hashCode
      ^ partFiles.hashCode
      ^ images.hashCode
      ^ misc.hashCode
      ^ padding.hashCode
      ^ margins.hashCode
      ^ routes.hashCode
      ^ colors.hashCode
      ^ sizes.hashCode;
}