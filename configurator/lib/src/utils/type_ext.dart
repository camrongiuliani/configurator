import 'package:configurator/configurator.dart';

extension DynamicCasting on dynamic {
  T as<T>() => this as T;
}

extension YamlSettingList on List<YamlSetting> {
  List<YamlSetting<K, V>> convert<K, V>() {
    return map((e) => YamlSetting<K, V>( e.name as K, e.value as V)).toList();
  }
}