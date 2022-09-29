import 'package:configurator/configurator.dart';
import 'package:example/src/app.config.dart';

class TestScope1 extends ConfigScope {
  @override
  String name = 'RuntimeScope1';

  @override
  Map<String, bool> flags = {
    ConfigKeys.flags.showTitle: false,
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

}