import 'package:configurator/configurator.dart';
import 'package:example/src/app.config.dart';
import 'package:example/src/app.dart';
import 'package:flutter/material.dart';

void main() {

  Configuration config = Configuration(
      scopes: [
        MyAppGeneratedScope(),
      ]
  );

  runApp( MyApp( config ) );
}