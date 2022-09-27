// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// ConfiguratorGenerator
// **************************************************************************

class _FlagKeys {
  final isEnabled = 'isEnabled';

  final andThis = 'andThis';

  final andThat = 'andThat';

  final orThis = 'orThis';

  final orThat = 'orThat';
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

class ConfigKeys {
  static final routes = _RouteKeys();

  static final flags = _FlagKeys();

  static final images = _ImageKeys();
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
        ConfigKeys.flags.orThat: false
      };
  bool get isEnabled => map[ConfigKeys.flags.isEnabled] == true;
  bool get andThis => map[ConfigKeys.flags.andThis] == true;
  bool get andThat => map[ConfigKeys.flags.andThat] == true;
  bool get orThis => map[ConfigKeys.flags.orThis] == true;
  bool get orThat => map[ConfigKeys.flags.orThat] == true;
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

class BaseConfigScope extends ConfigScope {
  @override
  String name = '__GeneratedConfig';

  @override
  Map<String, bool> flags = const _Flags().map;

  @override
  Map<String, String> images = const _Images().map;

  @override
  Map<int, String> routes = const _Routes().map;
}
