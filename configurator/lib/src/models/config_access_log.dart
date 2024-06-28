
import 'package:configurator/configurator.dart';

enum KeyType {
  flag,
  string,
  route,
  image,
  color,
  size,
  misc,
  textStyle,
}

class ConfigKeyLog<K, V> {
  final KeyType type;
  final K key;
  final V value;
  final ConfigScope scope;

  ConfigKeyLog(this.type, this.scope, this.key, this.value);
}