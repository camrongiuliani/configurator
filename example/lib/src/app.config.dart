// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ConfiguratorGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:configurator/configurator.dart';
import 'dart:ui';

// ********************************
// Color Util
// ********************************

class ColorUtil {
  static Color _colorFromHex(String input) {
    String c = input.toUpperCase().replaceAll("#", "");
    if (![6, 8].contains(c.length)) {
      return Colors.transparent;
    }
    if (c.length == 6) {
      c = 'FF$c';
    }
    int? iVal = int.tryParse(c, radix: 16);
    if (iVal != null) {
      return Color(iVal);
    }
    return Colors.transparent;
  }

  static Color _colorFromRGBString(String color) {
    try {
      bool hasAlpha = color.toLowerCase().startsWith('rgba');
      String numParts = color
          .replaceAll("rgb(", "")
          .replaceAll("rgba(", "")
          .replaceAll(")", "");
      List<String> rgbSplit = numParts.split(",").map((e) => e.trim()).toList();
      int r = int.parse(rgbSplit[0]);
      int g = int.parse(rgbSplit[1]);
      int b = int.parse(rgbSplit[2]);
      double a = hasAlpha ? double.parse(rgbSplit[3]) : 1.0;
      return Color.fromRGBO(r, g, b, a);
    } catch (e) {
      print(e);
      return Colors.transparent;
    }
  }

  static String colorToString(Color color) {
    var r = color.red;
    var g = color.green;
    var b = color.blue;
    var o = color.opacity;
    return 'rgba($r,$g,$b,$o)';
  }

  static Color parseColorValue(dynamic input) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      try {
        return Color(input);
      } catch (e) {
        print(e);
        return Colors.transparent;
      }
    }
    if (input is String) {
      if (input.toLowerCase().startsWith('rgb')) {
        return _colorFromRGBString(input);
      }
      return _colorFromHex(input);
    }
    return Colors.transparent;
  }
}

// ********************************
// Keys
// ********************************

class _FlagKeys {
  final isEnabled = 'isEnabled';

  final andThis = 'andThis';

  final andThat = 'andThat';

  final orThis = 'orThis';

  final orThat = 'orThat';

  final showTitle = 'showTitle';
}

class _ImageKeys {
  final loginHeaderImage = 'loginHeaderImage';

  final storeFrontHeaderImage = 'storeFrontHeaderImage';
}

class _RouteKeys {
  final master = 1;

  final masterDetail = 2;

  final test = 2;
}

class _ThemeSizeKeys {
  final homeTitleSize = 'homeTitleSize';

  final detailTitleSize = 'detailTitleSize';
}

class _ThemeColorKeys {
  final primary = 'primary';

  final secondary = 'secondary';

  final tertiary = 'tertiary';
}

class _ThemeKeys {
  final color = _ThemeColorKeys();

  final size = _ThemeSizeKeys();
}

class ConfigKeys {
  static final routes = _RouteKeys();

  static final flags = _FlagKeys();

  static final images = _ImageKeys();

  static final theme = _ThemeKeys();
}

// ********************************
// Theme
// ********************************

class _ThemeColors {
  const _ThemeColors();

  Map<String, String> get map => {
        ConfigKeys.theme.color.primary: '0000FF',
        ConfigKeys.theme.color.secondary: 'CC0000',
        ConfigKeys.theme.color.tertiary: '000000'
      };
  String get primary => map[ConfigKeys.theme.color.primary] ?? '';
  String get secondary => map[ConfigKeys.theme.color.secondary] ?? '';
  String get tertiary => map[ConfigKeys.theme.color.tertiary] ?? '';
}

class _ThemeSizes {
  const _ThemeSizes();

  Map<String, double> get map => {
        ConfigKeys.theme.size.homeTitleSize: 14.0,
        ConfigKeys.theme.size.detailTitleSize: 22.0
      };
  double get homeTitleSize => map[ConfigKeys.theme.size.homeTitleSize] ?? 0.0;
  double get detailTitleSize =>
      map[ConfigKeys.theme.size.detailTitleSize] ?? 0.0;
}

class GeneratedConfigTheme extends ThemeExtension<GeneratedConfigTheme> {
  GeneratedConfigTheme({required this.themeMap});

  final Map<String, Map<String, dynamic>> themeMap;

  Color get primary =>
      ColorUtil.parseColorValue(themeMap['colors']?['primary']);
  Color get secondary =>
      ColorUtil.parseColorValue(themeMap['colors']?['secondary']);
  Color get tertiary =>
      ColorUtil.parseColorValue(themeMap['colors']?['tertiary']);
  double get homeTitleSize => themeMap['sizes']?['homeTitleSize'];
  double get detailTitleSize => themeMap['sizes']?['detailTitleSize'];
  @override
  GeneratedConfigTheme copyWith({Map<String, Map<String, dynamic>>? themeMap}) {
    this.themeMap.addAll(themeMap ?? {});
    return GeneratedConfigTheme(themeMap: this.themeMap);
  }

  @override
  GeneratedConfigTheme lerp(
    ThemeExtension<GeneratedConfigTheme>? other,
    double t,
  ) {
    if (other is! GeneratedConfigTheme) {
      return this;
    }
    themeMap['colors']!['primary'] =
        ColorUtil.colorToString(Color.lerp(primary, other.primary, t)!);
    themeMap['colors']!['secondary'] =
        ColorUtil.colorToString(Color.lerp(secondary, other.secondary, t)!);
    themeMap['colors']!['tertiary'] =
        ColorUtil.colorToString(Color.lerp(tertiary, other.tertiary, t)!);
    themeMap['sizes']!['homeTitleSize'] =
        lerpDouble(homeTitleSize, other.homeTitleSize, t);
    themeMap['sizes']!['detailTitleSize'] =
        lerpDouble(detailTitleSize, other.detailTitleSize, t);
    return GeneratedConfigTheme(themeMap: themeMap);
  }
}

// ********************************
// Flags
// ********************************

class _Flags {
  const _Flags();

  Map<String, bool> get map => {
        ConfigKeys.flags.isEnabled: false,
        ConfigKeys.flags.andThis: true,
        ConfigKeys.flags.andThat: true,
        ConfigKeys.flags.orThis: false,
        ConfigKeys.flags.orThat: false,
        ConfigKeys.flags.showTitle: true
      };
  bool get isEnabled => map[ConfigKeys.flags.isEnabled] == true;
  bool get andThis => map[ConfigKeys.flags.andThis] == true;
  bool get andThat => map[ConfigKeys.flags.andThat] == true;
  bool get orThis => map[ConfigKeys.flags.orThis] == true;
  bool get orThat => map[ConfigKeys.flags.orThat] == true;
  bool get showTitle => map[ConfigKeys.flags.showTitle] == true;
}

// ********************************
// Images
// ********************************

class _Images {
  const _Images();

  Map<String, String> get map => {
        ConfigKeys.images.loginHeaderImage:
            'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png',
        ConfigKeys.images.storeFrontHeaderImage:
            'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png'
      };
  String get loginHeaderImage => map[ConfigKeys.images.loginHeaderImage] ?? '/';
  String get storeFrontHeaderImage =>
      map[ConfigKeys.images.storeFrontHeaderImage] ?? '/';
}

// ********************************
// Routes
// ********************************

class _Routes {
  const _Routes();

  Map<int, String> get map => {
        ConfigKeys.routes.master: '/master',
        ConfigKeys.routes.masterDetail: '/master/detail',
        ConfigKeys.routes.test: 'test'
      };
  String get master => map[ConfigKeys.routes.master] ?? '/';
  String get masterDetail => map[ConfigKeys.routes.masterDetail] ?? '/';
  String get test => map[ConfigKeys.routes.test] ?? '/';
}

// ********************************
// Configuration
// ********************************

class GeneratedScope extends ConfigScope {
  @override
  String name = '__GeneratedScope';

  @override
  Map<String, bool> flags = const _Flags().map;

  @override
  Map<String, String> images = const _Images().map;

  @override
  Map<int, String> routes = const _Routes().map;

  @override
  Map<String, Map<String, dynamic>> theme = {
    'colors': const _ThemeColors().map,
    'sizes': const _ThemeSizes().map
  };
}
