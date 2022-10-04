import 'package:configurator/configurator.dart';
import 'package:configurator/src/utils/change_notifier.dart';
import 'package:collection/collection.dart';

typedef VoidCallback = void Function();

class Configuration  {

  final List<ConfigScope> _scopes;
  List<ConfigScope> get scopes => List.from( _scopes );

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
    return _scopes.reversed.firstWhereOrNull( ( s ) {
      return s.flags.containsKey( id );
    })?.flags[ id ] ?? false;
  }

  String color( String id ) {
    return _scopes.reversed.firstWhereOrNull( ( s ) {
      return s.colors.containsKey( id );
    })?.colors[ id ] ?? '';
  }

  String route( int id ) {
    return _scopes.reversed.firstWhereOrNull( ( s ) {
      return s.routes.containsKey( id );
    })?.routes[ id ] ?? '';
  }

  String image( String id ) {
    return _scopes.reversed.firstWhereOrNull( ( s ) {
      return s.images.containsKey( id );
    })?.images[ id ] ?? '';
  }

  double size( String id ) {
    return _scopes.reversed.firstWhereOrNull( ( s ) {
      return s.sizes.containsKey( id );
    })?.sizes[ id ] ?? 14.0;
  }

  Map<String, Map<String, dynamic>> get themeMap {

    Map<String, String> colors = {};
    Map<String, String?> images = {};
    Map<String, double> sizes = {};
    Map<String, bool> flags = {};
    // Map<int, String?> routes = {};

    for ( var s in _scopes ) {
      images.addAll( s.images );
      colors.addAll( s.colors );
      sizes.addAll( s.sizes );
      flags.addAll( s.flags );
      // routes.addAll( s.routes );
    }

    return {
      'colors': colors,
      'sizes': sizes,
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