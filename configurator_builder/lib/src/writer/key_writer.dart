import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/model/theme.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class KeyWriter extends Writer {

  final List<ProcessedSetting> _flags;
  final List<ProcessedSetting> _images;
  final List<ProcessedRoute> _routes;
  final ProcessedTheme _theme;

  KeyWriter( this._flags, this._images, this._routes, this._theme );

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class flagKeys = Class( ( builder ) {
      builder
        ..name = '_FlagKeys'
        ..fields.addAll([
          ..._flags.map((e) => _buildField( e.name )),
        ]);
    });

    Class imageKeys = Class( ( builder ) {
      builder
        ..name = '_ImageKeys'
        ..fields.addAll([
          ..._images.map((e) => _buildField( e.name )),
        ]);
    });

    Class routeKeys = Class( ( builder ) {
      builder
        ..name = '_RouteKeys'
        ..fields.addAll([
          ..._routes.map((e) => _buildField2( e.path.canonicalize, '${e.id}' )),
        ]);
    });

    Class themeColorKeys = Class( ( builder ) {
      builder
        ..name = '_ThemeColorKeys'
        ..fields.addAll([
          ..._theme.colors.map((e) => _buildField( e.key.canonicalize )),
        ]);
    });

    Class themeSizeKeys = Class( ( builder ) {
      builder
        ..name = '_ThemeSizeKeys'
        ..fields.addAll([
          ..._theme.sizes.map((e) => _buildField( e.key.canonicalize )),
        ]);
    });

    Class themeKeysWrapper = Class( ( builder ) {
      builder
        ..name = '_ThemeKeys'
        ..fields.addAll([
          _buildKeyAccessor( 'color', '_ThemeColorKeys()', static: false ),
          _buildKeyAccessor( 'size', '_ThemeSizeKeys()', static: false ),
        ]);
    });

    Class configKeys = Class( ( builder ) {
      builder
        ..name = 'ConfigKeys'
        ..fields.addAll([
          _buildKeyAccessor( 'routes', '_RouteKeys()' ),
          _buildKeyAccessor( 'flags', '_FlagKeys()' ),
          _buildKeyAccessor( 'images', '_ImageKeys()' ),
          _buildKeyAccessor( 'theme', '_ThemeKeys()' ),
        ]);
    });

    lb..body.addAll([
      flagKeys,
      imageKeys,
      routeKeys,
      themeSizeKeys,
      themeColorKeys,
      themeKeysWrapper,
      configKeys,
    ]);

    return lb.build();
  }

  Field _buildKeyAccessor( String name, String clazz, { bool static = true } ) {
    FieldBuilder fb = FieldBuilder();

    fb..name = name;
    fb..modifier = FieldModifier.constant;
    fb..static = static;
    fb..modifier = FieldModifier.final$;
    fb..assignment = Code( clazz );

    return fb.build();
  }

  Field _buildField( String name ) {
    FieldBuilder fb = FieldBuilder();

    fb..name = name;
    fb..modifier = FieldModifier.final$;
    fb..assignment = Code( '\'${name}\'' );

    return fb.build();
  }

  Field _buildField2( String name, String assignment ) {
    FieldBuilder fb = FieldBuilder();

    fb..name = name;
    fb..modifier = FieldModifier.final$;
    fb..assignment = Code( assignment );

    return fb.build();
  }

}