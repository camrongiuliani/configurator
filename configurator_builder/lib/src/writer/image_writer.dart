import 'package:code_builder/code_builder.dart';
import 'package:configurator/configurator.dart';
import 'package:configurator_builder/src/misc/string_ext.dart';
import 'package:configurator_builder/src/misc/type_ext.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class ImageWriter extends Writer {

  final String name;
  final List<YamlSetting> _images;

  ImageWriter( this.name, List<YamlSetting> _images )
      : _images = _images.convert<String, String>();

  @override
  Spec write() {
    return Class( ( builder ) {
      builder
        ..constructors.add( Constructor( ( b ) => b..constant = true ) )
        ..name = '_Images'
        ..methods.addAll([
          _getValuesMap(),
          ..._getGetters(),
        ]);
    });
  }

  List<Method> _getGetters() {
    return _images.map((e) {
      return Method( ( builder ) {
        builder
          ..name = e.name
          ..type = MethodType.getter
          ..returns = refer( 'String' )
          ..lambda = true
          ..body = Code( 'map[ ${name.canonicalize}ConfigKeys.images.${e.name} ] ?? \'/\'');
      });
    }).toList();
  }

  Method _getValuesMap() {
    return Method( ( builder ) {
      builder
        ..name = 'map'
        ..type = MethodType.getter
        ..returns = refer( 'Map<String, String>' )
        ..lambda = true
        ..body = Code( () {

          Map<String, String> map = {};

          for ( var f in _images ) {
            map['${name.canonicalize}ConfigKeys.images.${f.name}'] = '\'${f.value}\'';
          }

          return map.toString();
        }() );
    });
  }
}