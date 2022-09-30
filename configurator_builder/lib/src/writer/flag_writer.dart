import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class FlagWriter extends Writer {

  final String name;
  final List<YamlSetting<String, bool>> _flags;

  FlagWriter( String name, List<YamlSetting> _flags )
      : name = name.canonicalize,
        _flags = _flags.convert<String, bool>();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Flags'
        ..methods.addAll([
          _getValuesMap(),
          ..._getGetters(),
        ]);
    });
  }

  List<Method> _getGetters() {
    return _flags.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer( 'bool' )
          ..lambda = true
          ..body = Code( 'map[ ${name}ConfigKeys.flags.${e.name} ] == true' );
      });
    }).toList();
  }

  Method _getValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, bool>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, bool> map = {};

          for ( var f in _flags ) {
            map['${name}ConfigKeys.flags.${f.name}'] = f.value;
          }

          return map.toString();
        }() );
    });
  }
}