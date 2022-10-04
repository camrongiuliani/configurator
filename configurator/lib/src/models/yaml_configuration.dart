import 'package:configurator/configurator.dart';

class YamlConfiguration {

  final String name;
  final List<YamlSetting> flags;
  final List<YamlSetting> colors;
  final List<YamlSetting> images;
  final List<YamlSetting> sizes;
  final List<YamlRoute> routes;
  final List<YamlI18n> strings;

  YamlConfiguration({
    required this.name,
    this.flags = const [],
    this.colors = const [],
    this.images = const [],
    this.sizes = const [],
    this.routes = const [],
    this.strings = const [],
  });

  Map<dynamic, dynamic> toJson() {
    return {
      'flags': { for (var e in flags) e.name: e.value},
      'images': { for (var e in images) e.name: e.value},
      'sizes': { for (var e in sizes) e.name: e.value},
      'colors': { for (var e in colors) e.name: e.value},
      'routes': { for (var e in routes) e.id : e.path },
      'strings': { for (var e in strings) e.name : e.value },
    };
  }

  operator +( YamlConfiguration t ) {
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