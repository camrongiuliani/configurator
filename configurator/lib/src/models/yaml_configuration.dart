import 'package:configurator/src/models/yaml_setting.dart';

class YamlConfiguration {

  final String name;
  final List<YamlSetting> flags;
  final List<YamlSetting> colors;
  final List<YamlSetting> images;
  final List<YamlSetting> sizes;
  final List<YamlSetting> routes;

  YamlConfiguration({
    required this.name,
    this.flags = const [],
    this.colors = const [],
    this.images = const [],
    this.sizes = const [],
    this.routes = const [],
  });

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
  }
}