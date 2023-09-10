import 'package:configurator/configurator.dart';
import 'package:i18n_extension/i18n_extension.dart' as i18n;

class LocalizeUtil {
  static String localize(Configuration config, String input) {
    return i18n.localize(
      input,
      i18n.Translations.from(
        "en_us",
        config.currentTranslations(input),
      ),
    );
  }
}

extension LocalizationExt on String {
  String translate(Configuration config) => LocalizeUtil.localize(
        config,
        this,
      );
}
