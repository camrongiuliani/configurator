import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:example/src/config/example1.config.dart';
import 'package:example/src/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {

  final Configuration config;

  const MyApp( this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Configurator(
      config: config,
      builder: ( context, config ) => MaterialApp(
        title: 'Flutter Demo',
        locale: TranslationProvider.of(context).flutterLocale, // use provider
        supportedLocales: LocaleSettings.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,

        theme: config.buildTheme(
            extensions: [
              AppScopeGeneratedThemeExtension(
                themeMap: config.themeMap,
              ),
            ]
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

