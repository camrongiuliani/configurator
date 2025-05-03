/// Extension methods for the [String] class.
///
/// This extension provides utility methods for string manipulation and formatting,
/// including capitalization, camel case conversion, and URL detection.
extension StringExtension on String {

  /// Capitalizes the first character of the string.
  ///
  /// Returns:
  /// * The string with its first character capitalized
  /// * The original string if capitalization fails
  String get capitalized {
    try {
      return "${this[0].toUpperCase()}${substring(1)}";
    } catch (e) {
      return this;
    }
  }

  /// Converts the string to camel case format.
  ///
  /// This method:
  /// 1. Capitalizes words separated by spaces, hyphens, or underscores
  /// 2. Removes all spaces, hyphens, and underscores
  /// 3. Makes the first character lowercase
  ///
  /// Returns:
  /// * The string in camel case format
  /// * The original string if conversion fails
  String get camelCase {
    try {
      String s = replaceAllMapped(
          RegExp(
              r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
              (Match m) =>
          "${m[0]?[0].toUpperCase()}${m[0]?.substring(1).toLowerCase()}")
          .replaceAll(RegExp(r'(_|-|\s)+'), '');

      return s[0].toLowerCase() + s.substring(1);
    } catch (e) {
      return this;
    }
  }

  /// Canonicalizes the string by:
  /// 1. Splitting on dots
  /// 2. Capitalizing each part
  /// 3. Joining with underscores
  /// 4. Removing non-word characters
  /// 5. Converting to camel case
  ///
  /// Returns:
  /// * The canonicalized string
  String get canonicalize => split('.').map((e) => e.capitalized).join('_').replaceAll(RegExp(r'[^\w\s]+'), '_').replaceFirst('_', '').camelCase;

  /// Checks if the string is a valid URL.
  ///
  /// Returns:
  /// * `true` if the string is a valid absolute URL starting with 'http'
  /// * `false` otherwise
  bool get isUrl => startsWith('http') && Uri.tryParse(this)?.isAbsolute == true;
}