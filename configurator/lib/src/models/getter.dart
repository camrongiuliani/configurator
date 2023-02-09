
class Getter<T> {
  final String key;
  final T value;

  Type get type => T;

  Getter(this.key, this.value);
}
