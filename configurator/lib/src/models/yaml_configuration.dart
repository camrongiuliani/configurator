import 'dart:math';

import 'package:configurator/configurator.dart';

class YamlConfiguration {

  final String name;
  final List<String> partFiles;
  final int weight;
  final List<YamlSetting> flags;
  final List<YamlSetting> colors;
  final List<YamlSetting> images;
  final List<YamlSetting> misc;
  final List<YamlSetting> sizes;
  final List<YamlSetting> padding;
  final List<YamlSetting> margins;
  final List<YamlRoute> routes;
  final List<YamlI18n> strings;

  YamlConfiguration({
    required this.name,
    this.weight = 0,
    this.partFiles = const [],
    this.flags = const [],
    this.colors = const [],
    this.images = const [],
    this.misc = const [],
    this.sizes = const [],
    this.routes = const [],
    this.strings = const [],
    this.padding = const [],
    this.margins = const [],
  });

  Map<dynamic, dynamic> toJson() {
    return {
      'partFiles': partFiles,
      'weight': weight,
      'flags': { for (var e in flags) e.name: e.value},
      'images': { for (var e in images) e.name: e.value},
      'misc': { for (var e in misc) e.name: e.value},
      'sizes': { for (var e in sizes) e.name: e.value},
      'colors': { for (var e in colors) e.name: e.value},
      'routes': { for (var e in routes) e.id : e.path },
      'strings': { for (var e in strings) e.name : e.value },
      'padding': { for (var e in padding) e.name : e.value },
      'margins': { for (var e in margins) e.name : e.value },
    };
  }

  operator +( YamlConfiguration t ) {
    misc.removeWhere(( e ) => t.misc.contains( e ));
    misc.addAll( t.misc );

    padding.removeWhere(( e ) => t.padding.contains( e ));
    padding.addAll( t.padding );

    margins.removeWhere(( e ) => t.margins.contains( e ));
    margins.addAll( t.margins );

    colors.removeWhere(( e ) => t.colors.contains( e ));
    colors.addAll( t.colors );

    sizes.removeWhere(( e ) => t.sizes.contains( e ));
    sizes.addAll( t.sizes );

    images.removeWhere(( e ) => t.images.contains( e ));
    images.addAll( t.images );

    flags.removeWhere(( e ) => t.flags.contains( e ));
    flags.addAll( t.flags );

    routes.removeWhere(( e ) => t.routes.contains( e ));
    routes.addAll( t.routes );

    strings.removeWhere(( e ) => t.strings.contains( e ));
    strings.addAll( t.strings );

    return this;
  }
}