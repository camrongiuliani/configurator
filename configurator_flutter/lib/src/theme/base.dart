import 'package:flutter/material.dart';

/// An abstract base class for creating theme extensions that can be configured
/// using a map of theme values.
///
/// This class extends [ThemeExtension] and provides a foundation for creating
/// custom theme extensions that can be populated from configuration data.
///
/// Type Parameters:
/// * [T] - The concrete theme extension type that extends this class
///
/// Example:
/// ```dart
/// class MyTheme extends ConfigTheme<MyTheme> {
///   MyTheme({required super.themeMap});
///
///   final Color primaryColor = themeMap['primaryColor'];
///   final double spacing = themeMap['spacing'];
///
///   @override
///   ThemeExtension<MyTheme> copyWith() {
///     return MyTheme(themeMap: themeMap);
///   }
///
///   @override
///   ThemeExtension<MyTheme> lerp(MyTheme? other, double t) {
///     return this;
///   }
/// }
/// ```
abstract class ConfigTheme<T extends ConfigTheme<T>> extends ThemeExtension<T> {
  /// Creates a new [ConfigTheme] instance.
  ///
  /// Parameters:
  /// * [themeMap] - A map containing theme values that will be used to configure
  ///   the theme extension
  ConfigTheme({required this.themeMap});

  /// A map containing the theme values used to configure this theme extension.
  ///
  /// This map should contain all the necessary values needed to configure the
  /// concrete theme extension implementation.
  final Map<String, dynamic> themeMap;

  // TODO: Add copyWith and themeDataFrom methods
}
