import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class SizeWriter extends Writer {

  final name;
  final List<YamlSetting<String, double>> _sizes;

  SizeWriter( this.name, List<YamlSetting> _sizes )
      : _sizes = _sizes.convert<String, double>();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Sizes'
        ..methods.addAll([
          _getSizeValuesMap(),
          ..._getSizeGetters(),
        ]);
    });
  }

  List<Method> _getSizeGetters() {
    return _sizes.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name.canonicalize
          ..type = MethodType.getter
          ..returns = refer( 'double' )
          ..lambda = true
          ..body = Code( 'map[ ${name.canonicalize}ConfigKeys.sizes.${e.name.canonicalize} ] ?? 0.0' );
      });
    }).toList();
  }

  Method _getSizeValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, double>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, double> map = {};

          for ( var f in _sizes ) {
            map['${name.canonicalize}ConfigKeys.sizes.${f.name.canonicalize}'] = f.value;
          }

          return map.toString();
        }() );
    });
  }
}