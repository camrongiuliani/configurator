import 'package:configurator/configurator.dart';

// ********************************
// ignore_for_file: type=lint
// ********************************

// ********************************
// Keys
// ********************************

class _FlagKeys {
  const _FlagKeys();

  final storeFrontTabBarPersonal = 'storeFrontTabBarPersonal';

  final storeFrontTabBarBusiness = 'storeFrontTabBarBusiness';
}

class _ImageKeys {
  const _ImageKeys();

  final storeFrontHero = 'storeFrontHero';

  final storeFrontAppBarBg = 'storeFrontAppBarBg';

  final storeFrontAppBarLogo = 'storeFrontAppBarLogo';
}

class _MiscKeys {
  const _MiscKeys();
}

class _TextStyleKeys {
  const _TextStyleKeys();
}

class StoreFrontScopeRouteKeys {
  const StoreFrontScopeRouteKeys();

  final oao = 1;

  final oaoStoreFront = 2;

  final oaoPersonal = 3;

  final oaoPersonalGettingStarted = 4;
}

class _SizeKeys {
  const _SizeKeys();

  final storeFrontHeroTopBorderWidth = 'storeFrontHeroTopBorderWidth';

  final storeFrontHeroBottomBorderWidth = 'storeFrontHeroBottomBorderWidth';

  final storeFrontHeroTextSize = 'storeFrontHeroTextSize';
}

class _PaddingKeys {
  const _PaddingKeys();

  final storeFrontHeroText = 'storeFrontHeroText';
}

class _MarginKeys {
  const _MarginKeys();

  final storeFrontHeroText = 'storeFrontHeroText';
}

class _ColorKeys {
  const _ColorKeys();

  final storeFrontBg = 'storeFrontBg';

  final storeFrontHeroTopBorder = 'storeFrontHeroTopBorder';

  final storeFrontHeroBottomBorder = 'storeFrontHeroBottomBorder';

  final storeFrontHeroTextBg = 'storeFrontHeroTextBg';

  final storeFrontHeroText = 'storeFrontHeroText';

  final storeFrontTabBarBg = 'storeFrontTabBarBg';

  final storeFrontTabBarIndicator = 'storeFrontTabBarIndicator';

  final storeFrontTabBarItemActiveText = 'storeFrontTabBarItemActiveText';

  final storeFrontTabBarItemActiveBg = 'storeFrontTabBarItemActiveBg';

  final storeFrontTabBarItemInactiveText = 'storeFrontTabBarItemInactiveText';

  final storeFrontTabBarItemInactiveBg = 'storeFrontTabBarItemInactiveBg';

  final storeFrontProductSectionText = 'storeFrontProductSectionText';

  final storeFrontProductCardBg = 'storeFrontProductCardBg';

  final storeFrontProductCardTextTitle = 'storeFrontProductCardTextTitle';

  final storeFrontProductCardTextBody = 'storeFrontProductCardTextBody';

  final storeFrontProductCardTextFooter = 'storeFrontProductCardTextFooter';

  final storeFrontSubmitBtnBg = 'storeFrontSubmitBtnBg';

  final storeFrontSubmitBtnText = 'storeFrontSubmitBtnText';
}

class StoreFrontScopeConfigKeys {
  const StoreFrontScopeConfigKeys();

  static final routes = const StoreFrontScopeRouteKeys();

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

  bool get storeFrontTabBarPersonal => _config.flag("storeFrontTabBarPersonal");
  bool get storeFrontTabBarBusiness => _config.flag("storeFrontTabBarBusiness");
}

// ********************************
// Images
// ********************************

class _ImageAccessor {
  const _ImageAccessor(this._config);

  final Configuration _config;

  String get storeFrontHero => _config.image("storeFrontHero");
  String get storeFrontAppBarBg => _config.image("storeFrontAppBarBg");
  String get storeFrontAppBarLogo => _config.image("storeFrontAppBarLogo");
}

// ********************************
// Routes
// ********************************

class _RouteAccessor {
  const _RouteAccessor(this._config);

  final Configuration _config;

  String get oao => _config.route(1);
  String get oaoStoreFront => _config.route(2);
  String get oaoPersonal => _config.route(3);
  String get oaoPersonalGettingStarted => _config.route(4);
}

// ********************************
// Colors
// ********************************

class _ColorAccessor {
  const _ColorAccessor(this._config);

  final Configuration _config;

  Color get storeFrontBg => _config.colorValue("storeFrontBg");
  Color get storeFrontHeroTopBorder =>
      _config.colorValue("storeFrontHeroTopBorder");
  Color get storeFrontHeroBottomBorder =>
      _config.colorValue("storeFrontHeroBottomBorder");
  Color get storeFrontHeroTextBg => _config.colorValue("storeFrontHeroTextBg");
  Color get storeFrontHeroText => _config.colorValue("storeFrontHeroText");
  Color get storeFrontTabBarBg => _config.colorValue("storeFrontTabBarBg");
  Color get storeFrontTabBarIndicator =>
      _config.colorValue("storeFrontTabBarIndicator");
  Color get storeFrontTabBarItemActiveText =>
      _config.colorValue("storeFrontTabBarItemActiveText");
  Color get storeFrontTabBarItemActiveBg =>
      _config.colorValue("storeFrontTabBarItemActiveBg");
  Color get storeFrontTabBarItemInactiveText =>
      _config.colorValue("storeFrontTabBarItemInactiveText");
  Color get storeFrontTabBarItemInactiveBg =>
      _config.colorValue("storeFrontTabBarItemInactiveBg");
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

  double get storeFrontHeroTopBorderWidth =>
      _config.size("storeFrontHeroTopBorderWidth");
  double get storeFrontHeroBottomBorderWidth =>
      _config.size("storeFrontHeroBottomBorderWidth");
  double get storeFrontHeroTextSize => _config.size("storeFrontHeroTextSize");
}

// ********************************
// Padding
// ********************************

class _PaddingAccessor {
  const _PaddingAccessor(this._config);

  final Configuration _config;

  double get storeFrontHeroText => _config.padding("storeFrontHeroText");
}

// ********************************
// Margins
// ********************************

class _MarginAccessor {
  const _MarginAccessor(this._config);

  final Configuration _config;

  double get storeFrontHeroText => _config.margin("storeFrontHeroText");
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

class GeneratedStoreFrontScope extends ConfigScope {
  const GeneratedStoreFrontScope();

  @override
  final String name = "__GeneratedStoreFrontScope";

  @override
  final int weight = 0;

  @override
  final Map<String, bool> flags = const {
    "storeFrontTabBarPersonal": true,
    "storeFrontTabBarBusiness": true
  };

  @override
  final Map<String, dynamic> images = const {
    "storeFrontHero": 'assets/man_on_mountain_hero.png',
    "storeFrontAppBarBg": 'assets/mobile_appbar.png',
    "storeFrontAppBarLogo": 'assets/battle-bank-mini-logo.svg'
  };

  @override
  final Map<String, String> colors = const {
    "storeFrontBg": 'EFF1F3',
    "storeFrontHeroTopBorder": 'FC9403',
    "storeFrontHeroBottomBorder": 'FC9403',
    "storeFrontHeroTextBg": 'FFFFFF',
    "storeFrontHeroText": '000000',
    "storeFrontTabBarBg": '1D2F3F',
    "storeFrontTabBarIndicator": '00FFFFFF',
    "storeFrontTabBarItemActiveText": 'FFFFFF',
    "storeFrontTabBarItemActiveBg": '1D2F3F',
    "storeFrontTabBarItemInactiveText": 'FFFFFF',
    "storeFrontTabBarItemInactiveBg": '1D2F3F',
    "storeFrontProductSectionText": '000000',
    "storeFrontProductCardBg": 'FFFFFF',
    "storeFrontProductCardTextTitle": '000000',
    "storeFrontProductCardTextBody": '000000',
    "storeFrontProductCardTextFooter": '000000',
    "storeFrontSubmitBtnBg": '1D2F3F',
    "storeFrontSubmitBtnText": 'FFFFFF'
  };

  @override
  final Map<String, double> sizes = const {
    "storeFrontHeroTopBorderWidth": 8.0,
    "storeFrontHeroBottomBorderWidth": 8.0,
    "storeFrontHeroTextSize": 20.0
  };

  @override
  final Map<String, double> padding = const {"storeFrontHeroText": 20.0};

  @override
  final Map<String, double> margins = const {"storeFrontHeroText": 12.0};

  @override
  final Map<String, dynamic> misc = const {};

  @override
  final Map<String, dynamic> textStyles = const {};

  @override
  final Map<int, String> routes = const {
    1: '/oao',
    2: '/oao/store-front',
    3: '/oao/personal',
    4: '/oao/personal/getting-started'
  };

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
