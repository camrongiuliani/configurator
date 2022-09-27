import 'package:code_builder/code_builder.dart';
import 'package:configurator_builder/src/model/setting.dart';
import 'package:configurator_builder/src/writer/writer.dart';

class FlagWriter extends Writer {

  final List<ProcessedSetting> _flags;

  FlagWriter( this._flags );

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
          ..body = Code( 'map[ ConfigKeys.flags.${e.name} ] == true' );
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
            map['ConfigKeys.flags.${f.name}'] = f.value;
          }

          return map.toString();
        }() );
    });
  }
}