import 'package:i18n_extension/i18n_extension.dart';

/// Extension methods for string interpolation.
///
/// This extension provides functionality to interpolate parameters into strings
/// using the i18n_extension package. It's particularly useful for internationalized
/// strings that contain placeholders.
///
/// Example usage:
/// ```dart
/// final greeting = 'Hello, {0}!'.interpolate(['World']);
/// // Result: 'Hello, World!'
/// ```
extension InterpolateExt on String {
  /// Interpolates the given parameters into the string.
  ///
  /// This method uses the [fill] method from i18n_extension to replace
  /// placeholders in the string with the provided parameters. If interpolation
  /// fails, the original string is returned.
  ///
  /// Parameters:
  /// * [params] - The list of parameters to interpolate into the string
  ///
  /// Returns:
  /// * The interpolated string if successful
  /// * The original string if interpolation fails
  String interpolate(List<String> params) {
    try {
      return fill(params);
    } catch (e) {
      return this;
    }
  }
}
