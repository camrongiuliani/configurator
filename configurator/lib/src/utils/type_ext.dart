import 'package:configurator/configurator.dart';

/// Extension methods for type casting on dynamic values.
///
/// This extension provides a convenient way to cast dynamic values to specific types.
extension DynamicCasting on dynamic {
  /// Casts the dynamic value to the specified type [T].
  ///
  /// This is a type-safe alternative to the `as` operator that can be used
  /// in method chains.
  ///
  /// Example:
  /// ```dart
  /// final value = someDynamicValue.as<String>();
  /// ```
  T as<T>() => this as T;
}

/// Extension methods for lists of [YamlSetting] objects.
///
/// This extension provides functionality to convert lists of [YamlSetting] objects
/// to lists with specific key and value types.
extension YamlSettingList on List<YamlSetting> {
  /// Converts a list of [YamlSetting] objects to a list of [YamlSetting] objects
  /// with specific key and value types.
  ///
  /// Parameters:
  /// * [K] - The type of the setting key
  /// * [V] - The type of the setting value
  ///
  /// Returns:
  /// * A new list of [YamlSetting] objects with the specified key and value types
  List<YamlSetting<K, V>> convert<K, V>() {
    return map((e) {
      final value = V == double && e.value is num
          ? (e.value as num).toDouble() as V
          : e.value as V;
      return YamlSetting<K, V>(e.name as K, value);
    }).toList();
  }
}
