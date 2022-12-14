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

    Class weightKeys = Class( ( builder ) {
      builder
        ..name = '_WeightKeys'
        ..fields.addAll([
          _buildField( 'weight' ),
        ]);
    });

    Class flagKeys = Class( ( builder ) {
      builder
        ..name = '_FlagKeys'
        ..fields.addAll([
          ..._yamlConfiguration.flags.map((e) => _buildField( e.name )),
        ]);
    });

    Class imageKeys = Class( ( builder ) {
      builder
        ..name = '_ImageKeys'
        ..fields.addAll([
          ..._yamlConfiguration.images.map((e) => _buildField( e.name )),
        ]);
    });

    Class miscKeys = Class( ( builder ) {
      builder
        ..name = '_MiscKeys'
        ..fields.addAll([
          ..._yamlConfiguration.misc.map((e) => _buildField( e.name )),
        ]);
    });

    Class textStyleKeys = Class( ( builder ) {
      builder
        ..name = '_TextStyleKeys'
        ..fields.addAll([
          ..._yamlConfiguration.textStyles.map((e) => _buildField( e.key )),
        ]);
    });

    Class paddingKeys = Class( ( builder ) {
      builder
        ..name = '_PaddingKeys'
        ..fields.addAll([
          ..._yamlConfiguration.padding.map((e) => _buildField( e.name )),
        ]);
    });

    Class marginKeys = Class( ( builder ) {
      builder
        ..name = '_MarginKeys'
        ..fields.addAll([
          ..._yamlConfiguration.margins.map((e) => _buildField( e.name )),
        ]);
    });

    Class routeKeys = Class( ( builder ) {
      builder
        ..name = '_RouteKeys'
        ..fields.addAll([
          ..._yamlConfiguration.routes.map((e) => _buildField2( ( e.path ).canonicalize, '${e.id}' )),
        ]);
    });

    Class colorKeys = Class( ( builder ) {
      builder
        ..name = '_ColorKeys'
        ..fields.addAll([
          ..._yamlConfiguration.colors.map((e) => _buildField( ( e.name as String ).canonicalize )),
        ]);
    });

    Class sizeKeys = Class( ( builder ) {
      builder
        ..name = '_SizeKeys'
        ..fields.addAll([
          ..._yamlConfiguration.sizes.map((e) => _buildField( ( e.name as String ).canonicalize )),
        ]);
    });

    Class configKeys = Class( ( builder ) {
      builder
        ..name = '${name}ConfigKeys'
        ..fields.addAll([
          _buildKeyAccessor( 'weight', '_WeightKeys()' ),
          _buildKeyAccessor( 'routes', '_RouteKeys()' ),
          _buildKeyAccessor( 'flags', '_FlagKeys()' ),
          _buildKeyAccessor( 'sizes', '_SizeKeys()' ),
          _buildKeyAccessor( 'padding', '_PaddingKeys()' ),
          _buildKeyAccessor( 'margins', '_MarginKeys()' ),
          _buildKeyAccessor( 'misc', '_MiscKeys()' ),
          _buildKeyAccessor( 'textStyles', '_TextStyleKeys()' ),
          _buildKeyAccessor( 'colors', '_ColorKeys()' ),
          _buildKeyAccessor( 'images', '_ImageKeys()' ),
        ]);
    });

    lb.body.addAll([
      weightKeys,
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