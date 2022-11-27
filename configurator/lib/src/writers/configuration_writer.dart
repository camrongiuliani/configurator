import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

class ConfigWriter extends Writer {

  final String name;

  ConfigWriter( this.name );

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..name = 'Generated$name'
        ..extend = refer( 'ConfigScope' )
        ..fields.addAll([
          _nameField(),

          _mapGetter(
            name: 'weight',
            returnType: 'int',
            assignment: '_Weight().map[\'weight\'] ?? 0',
          ),

          _mapGetter(
            name: 'flags',
            returnType: 'Map<String, bool>',
            assignment: 'const _Flags().map',
          ),

          _mapGetter(
            name: 'images',
            returnType: 'Map<String, dynamic>',
            assignment: 'const _Images().map',
          ),

          _mapGetter(
            name: 'colors',
            returnType: 'Map<String, String>',
            assignment: 'const _Colors().map',
          ),

          _mapGetter(
            name: 'sizes',
            returnType: 'Map<String, double>',
            assignment: 'const _Sizes().map',
          ),

          _mapGetter(
            name: 'padding',
            returnType: 'Map<String, double>',
            assignment: 'const _Padding().map',
          ),

          _mapGetter(
            name: 'margins',
            returnType: 'Map<String, double>',
            assignment: 'const _Margins().map',
          ),

          _mapGetter(
            name: 'misc',
            returnType: 'Map<String, dynamic>',
            assignment: 'const _Misc().map',
          ),

          _mapGetter(
            name: 'routes',
            returnType: 'Map<int, String>',
            assignment: 'const _Routes().map',
          ),
        ]);
    });
  }

  Field _nameField() {
    return Field( ( builder ) {
      builder
        ..name = 'name'
        ..annotations.add( refer( 'override' ) )
        ..type = refer('String')
        ..assignment = const Code( '\'__GeneratedScope\'' );
    });
  }

  Field _mapGetter({
    required String name,
    required String returnType,
    required String assignment,
  }) {
    return Field( ( builder ) {
      builder
        ..name = name
        ..annotations.add( refer( 'override' ) )
        ..type = refer( returnType )
        ..assignment = Code( assignment );
    });
  }
}