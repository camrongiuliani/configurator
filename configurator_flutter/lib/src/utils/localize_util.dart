import 'package:configurator/configurator.dart';
import 'package:i18n_extension/i18n_extension.dart' as i18n;

/// A utility class for localizing strings using the i18n_extension package.
///
/// This class provides functionality to localize strings based on the current
/// configuration and translations.
class LocalizeUtil {
  /// Localizes a string using the given configuration.
  ///
  /// This method uses the i18n_extension package to translate the input string
  /// based on the translations available in the configuration.
  ///
  /// Parameters:
  /// * [config] - The configuration containing the translations
  /// * [input] - The string to localize
  ///
  /// Returns:
  /// * The localized string
  static String localize(Configuration config, String input) {
    return i18n.localize(
      input,
      i18n.Translations.byId(
        'en_us',
        config.currentTranslations(input),
      ),
    );
  }
}

/// Extension methods for string localization.
///
/// This extension provides a convenient way to localize strings using the
/// configuration.
///
/// Example usage:
/// ```dart
/// final localized = 'Hello'.translate(config);
/// ```
extension LocalizationExt on String {
  /// Translates the string using the given configuration.
  ///
  /// Parameters:
  /// * [config] - The configuration containing the translations
  ///
  /// Returns:
  /// * The translated string
  String translate(Configuration config) => LocalizeUtil.localize(
        config,
        this,
      );
}
