
import 'package:configurator/configurator.dart';
import 'package:example/src/app.config.dart';
import 'package:example/src/home.dart';
import 'package:flutter/material.dart';
import 'package:configurator_annotations/configurator_annotations.dart';

@Configurator(
  yaml: [
    './assets/example1.yaml',
  ],
)
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ConfigurationProvider(
      config: Configuration([
        GeneratedScope(),
      ]),
      child: ConfiguredWidget(
        builder: ( config ) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData().copyWith(
            extensions: <GeneratedConfigTheme>[
              GeneratedConfigTheme(
                themeMap: config.theme,
              )
            ],
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
