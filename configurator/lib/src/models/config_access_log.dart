
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

  ConfigKeyLog(this.type, this.key, this.value);
}