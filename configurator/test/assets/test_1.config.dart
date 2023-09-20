import 'package:configurator/configurator.dart';

// ********************************
// ignore_for_file: type=lint
// ********************************

// ********************************
// Keys
// ********************************

class _FlagKeys {
  const _FlagKeys();

  final isEnabled = 'isEnabled';

  final andThis = 'andThis';

  final andThat = 'andThat';

  final orThis = 'orThis';

  final orThat = 'orThat';

  final showTitle = 'showTitle';

  final detailPageEmbActual = 'detailPageEmbActual';
}

class _ImageKeys {
  const _ImageKeys();

  final loginHeaderImage = 'loginHeaderImage';

  final storeFrontHeaderImage = 'storeFrontHeaderImage';
}

class _MiscKeys {
  const _MiscKeys();
}

class _TextStyleKeys {
  const _TextStyleKeys();
}

class AppScopeRouteKeys {
  const AppScopeRouteKeys();

  final master = 1;

  final test = 4;
}

class _SizeKeys {
  const _SizeKeys();

  final homeTitleSize = 'homeTitleSize';

  final detailTitleSize = 'detailTitleSize';
}

class _PaddingKeys {
  const _PaddingKeys();
}

class _MarginKeys {
  const _MarginKeys();
}

class _ColorKeys {
  const _ColorKeys();

  final primary = 'primary';

  final secondary = 'secondary';

  final tertiary = 'tertiary';

  final storeFrontBg = 'storeFrontBg';

  final storeFrontProductSectionText = 'storeFrontProductSectionText';

  final storeFrontProductCardBg = 'storeFrontProductCardBg';

  final storeFrontProductCardTextTitle = 'storeFrontProductCardTextTitle';

  final storeFrontProductCardTextBody = 'storeFrontProductCardTextBody';

  final storeFrontProductCardTextFooter = 'storeFrontProductCardTextFooter';

  final storeFrontSubmitBtnBg = 'storeFrontSubmitBtnBg';

  final storeFrontSubmitBtnText = 'storeFrontSubmitBtnText';
}

class AppScopeConfigKeys {
  const AppScopeConfigKeys();

  static final routes = const AppScopeRouteKeys();

  static final flags = const _FlagKeys();

  static final sizes = const _SizeKeys();

  static final padding = const _PaddingKeys();

  static final margins = const _MarginKeys();

  static final misc = const _MiscKeys();

  static final textStyles = const _TextStyleKeys();

  static final colors = const _ColorKeys();

  static final images = const _ImageKeys();
}

// ********************************
// Flags
// ********************************

class _FlagAccessor {
  const _FlagAccessor(this._config);

  final Configuration _config;

  bool get isEnabled => _config.flag("isEnabled");
  bool get andThis => _config.flag("andThis");
  bool get andThat => _config.flag("andThat");
  bool get orThis => _config.flag("orThis");
  bool get orThat => _config.flag("orThat");
  bool get showTitle => _config.flag("showTitle");
  bool get detailPageEmbActual => _config.flag("detailPageEmbActual");
}

// ********************************
// Images
// ********************************

class _ImageAccessor {
  const _ImageAccessor(this._config);

  final Configuration _config;

  String get loginHeaderImage => _config.image("loginHeaderImage");
  String get storeFrontHeaderImage => _config.image("storeFrontHeaderImage");
}

// ********************************
// Routes
// ********************************

class _RouteAccessor {
  const _RouteAccessor(this._config);

  final Configuration _config;

  String get master => _config.route(1);
  String get test => _config.route(4);
}

// ********************************
// Colors
// ********************************

class _ColorAccessor {
  const _ColorAccessor(this._config);

  final Configuration _config;

  Color get primary => _config.colorValue("primary");
  Color get secondary => _config.colorValue("secondary");
  Color get tertiary => _config.colorValue("tertiary");
  Color get storeFrontBg => _config.colorValue("storeFrontBg");
  Color get storeFrontProductSectionText =>
      _config.colorValue("storeFrontProductSectionText");
  Color get storeFrontProductCardBg =>
      _config.colorValue("storeFrontProductCardBg");
  Color get storeFrontProductCardTextTitle =>
      _config.colorValue("storeFrontProductCardTextTitle");
  Color get storeFrontProductCardTextBody =>
      _config.colorValue("storeFrontProductCardTextBody");
  Color get storeFrontProductCardTextFooter =>
      _config.colorValue("storeFrontProductCardTextFooter");
  Color get storeFrontSubmitBtnBg =>
      _config.colorValue("storeFrontSubmitBtnBg");
  Color get storeFrontSubmitBtnText =>
      _config.colorValue("storeFrontSubmitBtnText");
}

// ********************************
// Sizes
// ********************************

class _SizeAccessor {
  const _SizeAccessor(this._config);

  final Configuration _config;

  double get homeTitleSize => _config.size("homeTitleSize");
  double get detailTitleSize => _config.size("detailTitleSize");
}

// ********************************
// Padding
// ********************************

class _PaddingAccessor {
  const _PaddingAccessor(this._config);

  final Configuration _config;
}

// ********************************
// Margins
// ********************************

class _MarginAccessor {
  const _MarginAccessor(this._config);

  final Configuration _config;
}

// ********************************
// Misc
// ********************************

class _MiscAccessor {
  const _MiscAccessor(this._config);

  final Configuration _config;
}

// ********************************
// TextStyles
// ********************************

class _TextStyleAccessor {
  const _TextStyleAccessor(this._config);

  final Configuration _config;

  Map<String, String> get typefaces {
    return {};
  }
}

// ********************************
// Strings
// ********************************

class _I18nDart {
  _I18nDart(this._config);

  final Configuration _config;

  // Translations
}

// ********************************
// Configuration
// ********************************

class GeneratedAppScope extends ConfigScope {
  const GeneratedAppScope();

  @override
  final String name = "__GeneratedAppScope";

  @override
  final int weight = 0;

  @override
  final Map<String, bool> flags = const {
    "isEnabled": false,
    "andThis": true,
    "andThat": true,
    "orThis": false,
    "orThat": false,
    "showTitle": true,
    "detailPageEmbActual": true
  };

  @override
  final Map<String, dynamic> images = const {
    "loginHeaderImage":
        'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png',
    "storeFrontHeaderImage":
        'https://pub.dev/static/hash-qr9i96gp/img/pub-dev-logo-2x.png'
  };

  @override
  final Map<String, String> colors = const {
    "primary": 'EFF1F3',
    "secondary": 'CC0000',
    "tertiary": '000000',
    "storeFrontBg": 'EFF1F3',
    "storeFrontProductSectionText": 'EFF1F3',
    "storeFrontProductCardBg": 'EFF1F3',
    "storeFrontProductCardTextTitle": 'EFF1F3',
    "storeFrontProductCardTextBody": 'EFF1F3',
    "storeFrontProductCardTextFooter": 'EFF1F3',
    "storeFrontSubmitBtnBg": 'EFF1F3',
    "storeFrontSubmitBtnText": 'EFF1F3'
  };

  @override
  final Map<String, double> sizes = const {
    "homeTitleSize": 14.0,
    "detailTitleSize": 22.0
  };

  @override
  final Map<String, double> padding = const {};

  @override
  final Map<String, double> margins = const {};

  @override
  final Map<String, dynamic> misc = const {};

  @override
  final Map<String, dynamic> textStyles = const {};

  @override
  final Map<int, String> routes = const {1: '/master', 4: 'test'};

  @override
  final Map<String, Map<String, String>> translations = const {};
}

// ********************************
// Configuration Extension
// ********************************

extension ConfigAccessor on Configuration {
  _FlagAccessor get flags => _FlagAccessor(this);
  _ColorAccessor get colors => _ColorAccessor(this);
  _ImageAccessor get images => _ImageAccessor(this);
  _SizeAccessor get sizes => _SizeAccessor(this);
  _PaddingAccessor get paddings => _PaddingAccessor(this);
  _MarginAccessor get margins => _MarginAccessor(this);
  _MiscAccessor get miscellaneous => _MiscAccessor(this);
  _TextStyleAccessor get textStyles => _TextStyleAccessor(this);
  _RouteAccessor get routes => _RouteAccessor(this);
  _I18nDart get strings => _I18nDart(this);
}
