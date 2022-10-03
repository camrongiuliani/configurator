import 'package:configurator/src/models/yaml_i18n_string.dart';
import 'package:configurator/src/models/yaml_setting.dart';

class YamlConfiguration {

  final String name;
  final List<YamlSetting> flags;
  final List<YamlSetting> colors;
  final List<YamlSetting> images;
  final List<YamlSetting> sizes;
  final List<YamlSetting> routes;
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
      'routes': { for (var e in routes) e.name : e.value },
      'strings': { for (var e in strings) e.name : e.value },
    };
  }

  operator +( YamlConfiguration t ) {
    colors.retainWhere(( e ) => ! t.colors.contains( e ));
    colors.addAll( t.colors );

    sizes.retainWhere(( e ) => ! t.sizes.contains( e ));
    sizes.addAll( t.sizes );

    images.retainWhere(( e ) => ! t.images.contains( e ));
    images.addAll( t.images );

    flags.retainWhere(( e ) => ! t.flags.contains( e ));
    flags.addAll( t.flags );

    routes.retainWhere(( e ) => ! t.routes.contains( e ));
    routes.addAll( t.routes );

    strings.retainWhere(( e ) => ! t.strings.contains( e ));
    strings.addAll( t.strings );

    return this;
  }
}