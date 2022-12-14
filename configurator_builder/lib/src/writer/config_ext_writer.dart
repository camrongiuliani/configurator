import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

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
          _buildGetter( '_RouteAccessor', 'routes' ),
          _buildGetter( '_I18nDartEn', 'strings', 't' ),
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
}