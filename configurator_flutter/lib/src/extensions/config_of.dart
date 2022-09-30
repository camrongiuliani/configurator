

import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

extension Config on Configuration {
  static Configuration of( BuildContext context, { bool listen = true } ) {
    return ConfigurationProvider.of( context, listen: listen ).config;
  }
}