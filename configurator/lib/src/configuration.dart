import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/change_notifier.dart';
import 'package:collection/collection.dart';

typedef VoidCallback = void Function();

class Configuration  {

  final List<ConfigScope> _scopes;
  List<ConfigScope> get scopes => List.from( _scopes );

  List<ConfigScope> get _scopesSorted => _scopes.sorted((a, b) => a.weight.compareTo(b.weight));

  ConfigScope get _currentScope => _scopes.last;
  String get currentScopeName => _currentScope.name;

  final ChangeNotifier changeNotifier;

  Configuration._( this._scopes, this.changeNotifier );

  factory Configuration({ List<ConfigScope> scopes = const [] }) {

    List<ConfigScope> mut = List.from( scopes );

    if ( mut.isEmpty ) {
      var now = DateTime.now().millisecondsSinceEpoch;
      mut.add(  ConfigScope.empty(name: '$now') );
    }

    return Configuration._( mut, ChangeNotifier() );
  }

  Configuration copyWith({
    List<ConfigScope>? scopes,
    ChangeNotifier? changeNotifier,
  }) {
    return Configuration._( scopes ?? List.from( _scopes ), changeNotifier ?? this.changeNotifier );
  }

  void pushScope( covariant ConfigScope config, { bool checkEquality = true, bool notify = true } ) {
    if ( ! checkEquality || config != _currentScope ) {
      _scopes.add( config );

      if ( notify ) {
        notifyListeners();
      }
    }
  }

  Future<void> popScope({ bool notify = true }) async {
    if ( _scopes.length > 1 ) {
      _scopes.removeLast();

      if ( notify ) {
        notifyListeners();
      }
    }
  }

  Future<void> popScopeUntil( bool Function( ConfigScope ) test ) async {
    while ( test( _scopes.last ) == false && _scopes.length > 1 ) {
      _scopes.removeLast();
    }

    notifyListeners();
  }

  bool flag( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.flags.containsKey( id );
    })?.flags[ id ] ?? false;
  }

  String color( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.colors.containsKey( id );
    })?.colors[ id ] ?? '';
  }

  String route( int id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.routes.containsKey( id );
    })?.routes[ id ] ?? '';
  }

  String image( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.images.containsKey( id );
    })?.images[ id ] ?? '';
  }

  List<String> imageList( String id ) {
    dynamic i = _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.images.containsKey( id );
    })?.images[ id ];

    if ( i is String ) {
      return [ i ];
    }

    return i;
  }

  dynamic misc( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.misc.containsKey( id );
    })?.misc[ id ];
  }

  dynamic typefaces( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.typefaces.containsKey( id );
    })?.misc[ id ];
  }

  double size( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.sizes.containsKey( id );
    })?.sizes[ id ] ?? 14.0;
  }

  double padding( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.padding.containsKey( id );
    })?.padding[ id ] ?? 0.0;
  }

  double margin( String id ) {
    return _scopesSorted.reversed.firstWhereOrNull( ( s ) {
      return s.margins.containsKey( id );
    })?.margins[ id ] ?? 0.0;
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

    for ( var s in _scopes ) {
      partFiles.addAll( s.partFiles );
      images.addAll( s.images );
      colors.addAll( s.colors );
      sizes.addAll( s.sizes );
      padding.addAll( s.padding );
      margins.addAll( s.margins );
      misc.addAll( s.misc );
      flags.addAll( s.flags );
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

  void notifyListeners() {
    changeNotifier.notify( this );
  }
}
