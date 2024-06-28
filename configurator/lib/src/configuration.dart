import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

export 'package:configurator/src/models/config_access_log.dart';


typedef VoidCallback = void Function();

typedef PopScopePredicate = bool Function(ConfigScope scope);

class Configuration {
  final List<ConfigScope> _scopes;

  List<ConfigScope> get scopes => List.from(_scopes);

  List<ConfigScope> get _scopesSorted =>
      _scopes.sorted((a, b) => a.weight.compareTo(b.weight));

  ConfigScope get _currentScope => _scopes.last;

  String get currentScopeName => _currentScope.name;

  final ChangeNotifier changeNotifier;

  Configuration._(this._scopes, this.changeNotifier);

  factory Configuration({List<ConfigScope> scopes = const []}) {
    List<ConfigScope> mut = List.from(scopes);

    if (mut.isEmpty) {
      var now = DateTime.now().millisecondsSinceEpoch;
      mut.add(ConfigScope.empty(name: '$now'));
    }

    return Configuration._(mut, ChangeNotifier());
  }

  Configuration copyWith({
    List<ConfigScope>? scopes,
    ChangeNotifier? changeNotifier,
  }) {
    return Configuration._(
        scopes ?? List.from(_scopes), changeNotifier ?? this.changeNotifier);
  }

  void pushScope(covariant ConfigScope config,
      {bool checkEquality = true, bool notify = true}) {
    if (!checkEquality || config != _currentScope) {
      _scopes.add(config);

      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<void> popScope({bool notify = true}) async {
    if (_scopes.length > 1) {
      _scopes.removeLast();

      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<void> popScopeUntil(bool Function(ConfigScope) test) async {
    int it = 0;
    while (test(_scopes.last) == false &&
        _scopes.length > 1 &&
        it < _scopes.length) {
      _scopes.removeLast();
      it++;
    }

    notifyListeners();
  }

  Future<void> removeScopeWhere(
    PopScopePredicate predicate, {
    bool notify = true,
  }) async {
    _scopes.removeWhere((scope) => predicate(scope));
  }

  Future<void> removeLastScopeWhere(
    PopScopePredicate predicate, {
    bool notify = true,
  }) async {
    var idx = _scopes.lastIndexWhere((scope) => predicate(scope));

    if (idx > -1) {
      _scopes.removeAt(idx);
    }
  }

  Future<void> removeScopesOfType<T extends ConfigScope>() async {
    _scopes.removeWhere((s) => s is T);

    notifyListeners();
  }
  
  bool flag(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.flags.containsKey(id);
    });
    
    final value = scope?.flags[id] == true;

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.flag, scope, id, value),
      );
    }

    return value;
  }

  String color(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.colors.containsKey(id);
    });
    
    final value = scope?.colors[id] ?? '';

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.color, scope, id, value),
      );
    }

    return value;
  }

  String route(int id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.routes.containsKey(id);
    });
    
    final value = scope?.routes[id] ?? '';

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.route, scope, id, value),
      );
    }

    return value;
  }

  String image(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.images.containsKey(id);
    });

    final value = scope?.images[id] ?? '';
    
    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.image, scope, id, value),
      );
    }

    return value;
  }

  List<String> imageList(String id) {
    dynamic i = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.images.containsKey(id);
    })?.images[id];

    if (i is String) {
      return [i];
    }

    return i;
  }

  dynamic misc(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.misc.containsKey(id);
    });
    
    final value = scope?.misc[id];

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.misc, scope, id, value),
      );
    }

    return value;
  }

  Map<String, dynamic> textStyle(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.textStyles.containsKey(id);
    });

    final value = scope?.textStyles[id];

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.textStyle, scope, id, value),
      );
    }

    return value;
  }

  double size(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.sizes.containsKey(id);
    });

    final value = scope?.sizes[id] ?? 14.0;

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.size, scope, id, value),
      );
    }

    return value;
  }

  double padding(String id) {
    return _scopesSorted.reversed.firstWhereOrNull((s) {
          return s.padding.containsKey(id);
        })?.padding[id] ??
        0.0;
  }

  double margin(String id) {
    return _scopesSorted.reversed.firstWhereOrNull((s) {
          return s.margins.containsKey(id);
        })?.margins[id] ??
        0.0;
  }

  Map<String, Map<String, String>> currentTranslations(String key) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.translations.isNotEmpty && s.translations.containsKey(key);
    });
    
    final value = scope?.translations ?? {};

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.string, scope, key, value),
      );
    }
    
    return value;
  }

  Map<String, dynamic> get themeMap {
    List<String> partFiles = [];
    Map<String, String> colors = {};
    Map<String, dynamic> images = {};
    Map<String, double> sizes = {};
    Map<String, double> padding = {};
    Map<String, double> margins = {};
    Map<String, bool> flags = {};
    Map<String, dynamic> misc = {};
    // Map<int, String?> routes = {};

    for (var s in _scopes) {
      partFiles.addAll(s.partFiles);
      images.addAll(s.images);
      colors.addAll(s.colors);
      sizes.addAll(s.sizes);
      padding.addAll(s.padding);
      margins.addAll(s.margins);
      misc.addAll(s.misc);
      flags.addAll(s.flags);
      // routes.addAll( s.routes );
    }

    return {
      'partFiles': partFiles,
      'colors': colors,
      'sizes': sizes,
      'padding': padding,
      'margins': margins,
      'misc': misc,
      'images': images,
      'flags': flags,
      // 'routes': routes,
    };
  }

  /// Not part of public API
  Stream<Configuration> watch() => changeNotifier.watch();

  final publisher = PublishSubject<ConfigKeyLog>();

  Stream<ConfigKeyLog> get accessStream => publisher.stream;

  void notifyListeners() {
    changeNotifier.notify(this);
  }
}
