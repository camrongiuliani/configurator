import 'package:code_builder/code_builder.dart';
import 'package:configurator/src/writers/writer.dart';

class ConfigExtWriter extends Writer {

  ConfigExtWriter();

  @override
  Spec write() {
    return Extension( ( b ) {
      b
        ..name = 'ConfigAccessor'
        ..on = refer( 'Configuration' )
        ..methods.addAll([
          _buildGetter( '_FlagAccessor', 'flags' ),
          _buildGetter( '_ColorAccessor', 'colors' ),
          _buildGetter( '_ImageAccessor', 'images' ),
          _buildGetter( '_SizeAccessor', 'sizes' ),
          _buildGetter( '_PaddingAccessor', 'paddings' ),
          _buildGetter( '_MarginAccessor', 'margins' ),
          _buildGetter( '_MiscAccessor', 'miscellaneous' ),
          _buildGetter( '_TextStyleAccessor', 'textStyles' ),
          _buildGetter( '_RouteAccessor', 'routes' ),
          // _buildGetter( '_I18nDartEn', 'strings', 't' ),
          _buildTranslationGetter(),
          // _buildTranslationMap(),
        ]);
    });
  }

  Method _buildGetter( String className, String fieldName, [ String? body ] ) {
    return Method( ( b ) {
      b
        ..name = fieldName
        ..returns = refer( className )
        ..body = Code( body ?? '$className( this )' )
        ..lambda = true
        ..type = MethodType.getter;
    });
  }

  Method _buildTranslationGetter() {
    return Method( ( b ) {
      b
        ..name = 'strings'
        ..returns = refer( '_i18n' )
        ..body = const Code( '_i18n(this)' )
        ..lambda = true
        ..type = MethodType.getter;
    });
  }

  Method _buildTranslationMap() {
    return Method( ( b ) {
      b
        ..name = '_translationMap'
        ..returns = refer( 'Map<String, Map<String, String>>' )
        ..body = const Code( 'this.scopes.sorted((a, b) => a.weight.compareTo(b.weight)).reversed.firstWhereOrNull((s) => s.translations.isNotEmpty)?.translations ?? {}' )
        ..lambda = true
        ..type = MethodType.getter;
    });
  }
}