import 'package:flutter/material.dart';

abstract class ConfigTheme<T extends ConfigTheme<T>> extends ThemeExtension<T> {

  ConfigTheme({required this.themeMap});

  final Map<String, dynamic> themeMap;

  // Todo: Add copyWith and themeDataFrom methods
}
