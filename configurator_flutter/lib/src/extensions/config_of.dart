

import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

extension OfContextF on Configuration {
  Configuration of( BuildContext context ) {
    return ConfigurationProvider.of( context ).config;
  }
}