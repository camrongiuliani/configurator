import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class ImageWriter extends Writer {

  final List<ProcessedSetting> _images;

  ImageWriter( this._images );

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
          ..body = Code( 'map[ ConfigKeys.images.${e.name} ] ?? \'/\'');
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
            map['ConfigKeys.images.${f.name}'] = '\'${f.value}\'';
          }

          return map.toString();
        }() );
    });
  }
}