import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class KeyWriter extends Writer {

  final String name;
  final YamlConfiguration _yamlConfiguration;

  KeyWriter( String name, this._yamlConfiguration ) : name = name.canonicalize.capitalized;

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class flagKeys = Class( ( builder ) {
      builder
        ..name = '_FlagKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.flags.map((e) => _buildField( e.name )),
        ]);
    });

    Class imageKeys = Class( ( builder ) {
      builder
        ..name = '_ImageKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.images.map((e) => _buildField( e.name )),
        ]);
    });

    Class miscKeys = Class( ( builder ) {
      builder
        ..name = '_MiscKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.misc.map((e) => _buildField( e.name )),
        ]);
    });

    Class textStyleKeys = Class( ( builder ) {
      builder
        ..name = '_TextStyleKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.textStyles.map((e) => _buildField( e.key )),
        ]);
    });

    Class paddingKeys = Class( ( builder ) {
      builder
        ..name = '_PaddingKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.padding.map((e) => _buildField( e.name )),
        ]);
    });

    Class marginKeys = Class( ( builder ) {
      builder
        ..name = '_MarginKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.margins.map((e) => _buildField( e.name )),
        ]);
    });

    Class routeKeys = Class( ( builder ) {
      builder
        ..name = '${name}RouteKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.routes.map((e) => _buildField2( ( e.path ).canonicalize, '${e.id}' )),
        ]);
    });

    Class colorKeys = Class( ( builder ) {
      builder
        ..name = '_ColorKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.colors.map((e) => _buildField( ( e.name as String ).canonicalize )),
        ]);
    });

    Class sizeKeys = Class( ( builder ) {
      builder
        ..name = '_SizeKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          ..._yamlConfiguration.sizes.map((e) => _buildField( ( e.name as String ).canonicalize )),
        ]);
    });

    Class configKeys = Class( ( builder ) {
      builder
        ..name = '${name}ConfigKeys'
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..fields.addAll([
          _buildKeyAccessor( 'routes', 'const ${name}RouteKeys()' ),
          _buildKeyAccessor( 'flags', 'const _FlagKeys()' ),
          _buildKeyAccessor( 'sizes', 'const _SizeKeys()' ),
          _buildKeyAccessor( 'padding', 'const _PaddingKeys()' ),
          _buildKeyAccessor( 'margins', 'const _MarginKeys()' ),
          _buildKeyAccessor( 'misc', 'const _MiscKeys()' ),
          _buildKeyAccessor( 'textStyles', 'const _TextStyleKeys()' ),
          _buildKeyAccessor( 'colors', 'const _ColorKeys()' ),
          _buildKeyAccessor( 'images', 'const _ImageKeys()' ),
        ]);
    });

    lb.body.addAll([
      flagKeys,
      imageKeys,
      miscKeys,
      textStyleKeys,
      routeKeys,
      sizeKeys,
      paddingKeys,
      marginKeys,
      colorKeys,
      configKeys,
    ]);

    return lb.build();
  }

  Field _buildKeyAccessor( String name, String clazz, { bool static = true } ) {
    FieldBuilder fb = FieldBuilder();

    fb.name = name;
    fb.modifier = FieldModifier.constant;
    fb.static = static;
    fb.modifier = FieldModifier.final$;
    fb.assignment = Code( clazz );

    return fb.build();
  }

  Field _buildField( String name ) {
    FieldBuilder fb = FieldBuilder();

    fb.name = name;
    fb.modifier = FieldModifier.final$;
    fb.assignment = Code( '\'$name\'' );

    return fb.build();
  }

  Field _buildField2( String name, String assignment ) {
    FieldBuilder fb = FieldBuilder();

    fb.name = name;
    fb.modifier = FieldModifier.final$;
    fb.assignment = Code( assignment );

    return fb.build();
  }

}