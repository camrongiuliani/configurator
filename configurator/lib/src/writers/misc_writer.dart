import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/string_ext.dart';
import 'package:configurator/src/utils/type_ext.dart';
import 'package:configurator/src/writers/writer.dart';

class MiscWriter extends Writer {

  final String name;
  final List<YamlSetting<String, dynamic>> _settings;

  MiscWriter( String name, List<YamlSetting> settings )
      : name = name.canonicalize.capitalized,
        _settings = settings.convert<String, dynamic>();

  @override
  Spec write() {
    LibraryBuilder lb = LibraryBuilder();

    Class config = _buildAccessor();

    lb.body.add( config );

    return lb.build();

  }

  List<Method> _getGetters() {
    return _settings.map((e) {

      var type = () {
        if (e.value is String) {
          return 'String';
        } else if (e.value is int) {
          return 'int';
        } else if (e.value is double) {
          return 'double';
        } else if (e.value is bool) {
          return 'bool';
        } else if (e.value is List) {
          var types = (e.value as List).map((e) {
            return e.runtimeType.toString();
          }).toSet().toList();

          if (types.length == 1) {
            if (types.first.contains('_Map')) {
              return 'List<Map<String, dynamic>>';
            }

            return 'List<${types.first}>';
          }

          return 'List<dynamic>';
        }

        return 'dynamic';
      }();

      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer(type)
          ..lambda = true
          ..body = Code( () {
            return '_config.misc("${e.name}")${type == 'dynamic' ? '' : ' as $type'}';
          }() );
      });
    }).toList();
  }

  Class _buildAccessor() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) {
          b
            ..constant = true
            ..requiredParameters.addAll([
              Parameter( ( b ) {
                b
                  ..name = '_config'
                  ..toThis = true;
              }),
            ]);
        }) )
        ..name = '_MiscAccessor'
        ..fields.addAll([
          Field( ( b ) {
            b
              ..name = '_config'
              ..type = refer( 'Configuration' )
              ..modifier = FieldModifier.final$;
          }),
        ])
        ..methods.addAll([
          ..._getGetters(),
        ]);
    });
  }

}