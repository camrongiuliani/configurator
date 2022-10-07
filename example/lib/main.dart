import 'package:configurator/configurator.dart';
import 'package:example/src/app.dart';
import 'package:example/src/config/example1.config.dart';
import 'package:flutter/material.dart';

void main() {

  Configuration config = Configuration(
      scopes: [
        AppScopeGeneratedScope(),
      ]
  );

  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();


  runApp( TranslationProvider(child: MyApp( config )) );
}