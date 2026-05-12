/// A configuration management system that allows for hierarchical configuration scopes.
///
/// The Configuration class manages a stack of configuration scopes, where each scope
/// can override or extend settings from previous scopes. This allows for flexible
/// configuration management with different levels of precedence.
///
/// Example usage:
/// ```dart
/// final config = Configuration();
/// config.pushScope(ConfigScope(name: 'base', settings: {...}));
/// config.pushScope(ConfigScope(name: 'override', settings: {...}));
/// ```
///
/// See also:
/// * [ConfigScope] - Represents a single configuration scope
/// * [ConfigAccessLog] - Tracks access to configuration values
import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/change_notifier.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

export 'package:configurator/src/models/config_access_log.dart';

/// A callback function that takes no arguments and returns no value.
typedef VoidCallback = void Function();

/// A predicate function that determines whether a scope should be popped.
typedef PopScopePredicate = bool Function(ConfigScope scope);

class Configuration {
  /// The list of configuration scopes, ordered by weight.
  final List<ConfigScope> _scopes;

  /// Returns a copy of the current scopes list.
  List<ConfigScope> get scopes => List.from(_scopes);

  /// Returns the scopes sorted by their weight in ascending order.
  List<ConfigScope> get _scopesSorted =>
      _scopes.sorted((a, b) => a.weight.compareTo(b.weight));

  /// Returns the current active scope (the last one in the stack).
  ConfigScope get _currentScope => _scopes.last;

  /// Returns the name of the current active scope.
  String get currentScopeName => _currentScope.name;

  /// Notifier for configuration changes.
  final ChangeNotifier changeNotifier;

  Configuration._(this._scopes, this.changeNotifier);

  /// Creates a new Configuration instance with optional initial scopes.
  ///
  /// If no scopes are provided, a default empty scope is created with a timestamp name.
  ///
  /// Parameters:
  /// * [scopes] - Optional list of initial configuration scopes
  factory Configuration({List<ConfigScope> scopes = const []}) {
    List<ConfigScope> mut = List.from(scopes);

    if (mut.isEmpty) {
      var now = DateTime.now().millisecondsSinceEpoch;
      mut.add(ConfigScope.empty(name: '$now'));
    }

    return Configuration._(mut, ChangeNotifier());
  }

  /// Creates a copy of this configuration with optional overrides.
  ///
  /// Parameters:
  /// * [scopes] - Optional new list of scopes
  /// * [changeNotifier] - Optional new change notifier
  Configuration copyWith({
    List<ConfigScope>? scopes,
    ChangeNotifier? changeNotifier,
  }) {
    return Configuration._(
        scopes ?? List.from(_scopes), changeNotifier ?? this.changeNotifier);
  }

  /// Pushes a new configuration scope onto the stack.
  ///
  /// Parameters:
  /// * [config] - The configuration scope to push
  /// * [checkEquality] - If true, checks if the new scope is different from the current one
  /// * [notify] - If true, notifies listeners of the change
  void pushScope(covariant ConfigScope config,
      {bool checkEquality = true, bool notify = true}) {
    if (!checkEquality || config != _currentScope) {
      _scopes.add(config);

      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Pops the current scope from the stack.
  ///
  /// If there is only one scope remaining, it will not be removed.
  ///
  /// Parameters:
  /// * [notify] - If true, notifies listeners of the change
  Future<void> popScope({bool notify = true}) async {
    if (_scopes.length > 1) {
      _scopes.removeLast();

      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Pops scopes from the stack until the given test function returns true.
  ///
  /// Parameters:
  /// * [test] - A function that determines when to stop popping scopes
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

  /// Removes all scopes that match the given predicate.
  ///
  /// Parameters:
  /// * [predicate] - A function that determines which scopes to remove
  /// * [notify] - If true, notifies listeners of the change
  Future<void> removeScopeWhere(
    PopScopePredicate predicate, {
    bool notify = true,
  }) async {
    _scopes.removeWhere((scope) => predicate(scope));
  }

  /// Removes the last scope that matches the given predicate.
  ///
  /// Parameters:
  /// * [predicate] - A function that determines which scope to remove
  /// * [notify] - If true, notifies listeners of the change
  Future<void> removeLastScopeWhere(
    PopScopePredicate predicate, {
    bool notify = true,
  }) async {
    var idx = _scopes.lastIndexWhere((scope) => predicate(scope));

    if (idx > -1) {
      _scopes.removeAt(idx);
    }
  }

  /// Removes all scopes of the specified type.
  ///
  /// Parameters:
  /// * [T] - The type of scopes to remove
  Future<void> removeScopesOfType<T extends ConfigScope>() async {
    _scopes.removeWhere((s) => s is T);

    notifyListeners();
  }
  
  /// Checks if a flag is set in any of the scopes.
  ///
  /// The flag is checked in reverse order of scope weight, so higher weight
  /// scopes take precedence.
  ///
  /// Parameters:
  /// * [id] - The identifier of the flag to check
  /// Returns:
  /// * `true` if the flag is set to true in any scope, `false` otherwise
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

  /// Gets a color value from the configuration scopes.
  ///
  /// The color is retrieved from the highest weight scope that contains it.
  /// If no scope contains the color, an empty string is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the color to retrieve
  /// Returns:
  /// * The color value as a string, or an empty string if not found
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

  /// Gets a route value from the configuration scopes.
  ///
  /// The route is retrieved from the highest weight scope that contains it.
  /// If no scope contains the route, an empty string is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the route to retrieve
  /// Returns:
  /// * The route value as a string, or an empty string if not found
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

  /// Gets an image value from the configuration scopes.
  ///
  /// The image is retrieved from the highest weight scope that contains it.
  /// If no scope contains the image, an empty string is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the image to retrieve
  /// Returns:
  /// * The image value as a string, or an empty string if not found
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

  /// Gets a list of image values from the configuration scopes.
  ///
  /// The images are retrieved from the highest weight scope that contains them.
  /// If the value is a single string, it is returned as a single-item list.
  ///
  /// Parameters:
  /// * [id] - The identifier of the image list to retrieve
  /// Returns:
  /// * A list of image values, or an empty list if not found
  List<String> imageList(String id) {
    dynamic i = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.images.containsKey(id);
    })?.images[id];

    if (i is String) {
      return [i];
    }

    return i;
  }

  /// Gets a miscellaneous value from the configuration scopes.
  ///
  /// The value is retrieved from the highest weight scope that contains it.
  /// If no scope contains the value, null is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the miscellaneous value to retrieve
  /// Returns:
  /// * The miscellaneous value, or null if not found
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

  /// Gets a text style configuration from the configuration scopes.
  ///
  /// The text style is retrieved from the highest weight scope that contains it.
  /// If no scope contains the text style, an empty map is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the text style to retrieve
  /// Returns:
  /// * A map containing the text style properties, or an empty map if not found
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

  /// Gets an enum value from the configuration scopes.
  ///
  /// The value is retrieved from the highest weight scope that contains it.
  /// If no scope contains the value, an empty string is returned.
  ///
  /// Parameters:
  /// * [id] - The identifier of the enum value to retrieve
  /// Returns:
  /// * The enum value as a string, or an empty string if not found
  String enumValue(String id) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.enums.containsKey(id);
    });

    final value = scope?.enums[id] ?? '';

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.enumType, scope, id, value),
      );
    }

    return value;
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
    int weight = 0;
    Map<String, String> colors = {};
    Map<String, dynamic> images = {};
    Map<String, double> sizes = {};
    Map<String, double> padding = {};
    Map<String, double> margins = {};
    Map<String, bool> flags = {};
    Map<String, String> enums = {};
    Map<String, dynamic> misc = {};
    Map<String, dynamic> textStyles = {};
    // Map<int, String?> routes = {};

    for (var s in _scopes) {
      partFiles.addAll(s.partFiles);
      weight += s.weight;
      images.addAll(s.images);
      colors.addAll(s.colors);
      sizes.addAll(s.sizes);
      padding.addAll(s.padding);
      margins.addAll(s.margins);
      misc.addAll(s.misc);
      flags.addAll(s.flags);
      enums.addAll(s.enums);
      textStyles.addAll(s.textStyles);
      // routes.addAll( s.routes );
    }

    return {
      'partFiles': partFiles,
      'weight': weight,
      'colors': colors,
      'sizes': sizes,
      'padding': padding,
      'margins': margins,
      'misc': misc,
      'textStyles': textStyles,
      'images': images,
      'flags': flags,
      'enums': enums,
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
