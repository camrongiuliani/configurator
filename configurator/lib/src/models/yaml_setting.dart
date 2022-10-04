class YamlSetting<K, V> {

  final K name;
  final V value;

  YamlSetting( this.name, this.value );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlSetting &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}