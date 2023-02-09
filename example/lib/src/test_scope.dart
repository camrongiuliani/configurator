import 'package:configurator/configurator.dart';
import 'package:example/src/config/example1.config.dart';
import 'package:i18n_extension/i18n_extension.dart' as i18nt;

class TestScope1 extends ConfigScope {
  @override
  String name = 'Dev_Hardcoded_Scope';

  @override
  Map<String, bool> flags = {
    AppScopeConfigKeys.flags.showTitle: false,
  };

  @override
  Map<String, String> images = const {};

  @override
  Map<int, String> routes = const {};

  @override
  Map<String, String> get colors => const {
    'primary': 'FF0000',
    'secondary': '000000',
  };

  @override
  Map<String, double> get sizes => const {};

  @override
  Map<String, dynamic> get misc => const {};

  @override
  Map<String, double> get padding => const {};

  @override
  Map<String, double> get margins => const {};

  @override
  int get weight => 0;

  @override
  i18nt.Translations? i18n = i18nt.Translations('en_us');

  @override
  Map<String, Map<String, String>> get translations => {};


}