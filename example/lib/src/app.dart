
import 'package:configurator/configurator.dart';
import 'package:example/src/configuration/provider.dart';
import 'package:example/src/home.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfigurationProvider(
      configuration: const Configuration(),
      widget: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
