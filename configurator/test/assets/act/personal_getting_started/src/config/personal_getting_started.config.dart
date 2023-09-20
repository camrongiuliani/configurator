import 'package:configurator/configurator.dart';

// ********************************
// ignore_for_file: type=lint
// ********************************

// ********************************
// Keys
// ********************************

class _FlagKeys {
  const _FlagKeys();

  final personalGettingStartedTabBarPersonal =
      'personalGettingStartedTabBarPersonal';

  final personalGettingStartedTabBarBusiness =
      'personalGettingStartedTabBarBusiness';
}

class _ImageKeys {
  const _ImageKeys();
}

class _MiscKeys {
  const _MiscKeys();
}

class _TextStyleKeys {
  const _TextStyleKeys();
}

class PersonalGettingStartedRouteKeys {
  const PersonalGettingStartedRouteKeys();
}

class _SizeKeys {
  const _SizeKeys();
}

class _PaddingKeys {
  const _PaddingKeys();
}

class _MarginKeys {
  const _MarginKeys();
}

class _ColorKeys {
  const _ColorKeys();

  final personalGettingStartedBg = 'personalGettingStartedBg';
}

class PersonalGettingStartedConfigKeys {
  const PersonalGettingStartedConfigKeys();

  static final routes = const PersonalGettingStartedRouteKeys();

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

  bool get personalGettingStartedTabBarPersonal =>
      _config.flag("personalGettingStartedTabBarPersonal");
  bool get personalGettingStartedTabBarBusiness =>
      _config.flag("personalGettingStartedTabBarBusiness");
}

// ********************************
// Images
// ********************************

class _ImageAccessor {
  const _ImageAccessor(this._config);

  final Configuration _config;
}

// ********************************
// Routes
// ********************************

class _RouteAccessor {
  const _RouteAccessor(this._config);

  final Configuration _config;
}

// ********************************
// Colors
// ********************************

class _ColorAccessor {
  const _ColorAccessor(this._config);

  final Configuration _config;

  Color get personalGettingStartedBg =>
      _config.colorValue("personalGettingStartedBg");
}

// ********************************
// Sizes
// ********************************

class _SizeAccessor {
  const _SizeAccessor(this._config);

  final Configuration _config;
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

class GeneratedPersonalGettingStarted extends ConfigScope {
  const GeneratedPersonalGettingStarted();

  @override
  final String name = "__GeneratedPersonalGettingStarted";

  @override
  final int weight = 0;

  @override
  final Map<String, bool> flags = const {
    "personalGettingStartedTabBarPersonal": true,
    "personalGettingStartedTabBarBusiness": true
  };

  @override
  final Map<String, dynamic> images = const {};

  @override
  final Map<String, String> colors = const {
    "personalGettingStartedBg": 'EFF1F3'
  };

  @override
  final Map<String, double> sizes = const {};

  @override
  final Map<String, double> padding = const {};

  @override
  final Map<String, double> margins = const {};

  @override
  final Map<String, dynamic> misc = const {};

  @override
  final Map<String, dynamic> textStyles = const {};

  @override
  final Map<int, String> routes = const {};

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
