import 'package:configurator/configurator.dart';
import 'package:configurator/src/scopes/base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class Configuration extends ValueListenable<Configuration> {

  // ignore: avoid_positional_boolean_parameters
  void throwIf(bool condition, Object error) {
    if (condition) throw error;
  }

  // ignore: avoid_positional_boolean_parameters
  void throwIfNot(bool condition, Object error) {
    if (!condition) throw error;
  }

  final List<ConfigScope> _scopes;
  List<ConfigScope> get scopes => List.from( _scopes );

  final List<VoidCallback> listeners = [];

  Configuration([ List<ConfigScope> scopes = const [] ]) :
        _scopes = [
          RootScope(),
          ...scopes,
        ];

  static T of<T extends Configuration>(
      BuildContext context,
      {
        bool listen = true,
      } ) {

    final ConfigurationProvider? result = context.findAncestorWidgetOfExactType();

    if ( listen ) {
      context.dependOnInheritedWidgetOfExactType<ConfigurationProvider>();
    }

    assert(result != null, 'No $T found in context');
    return result!.configuration as T;
  }

  ConfigScope get _currentScope => _scopes.last;
  String get currentScopeName => _currentScope.name;

  void pushScope( covariant ConfigScope config ) {
    if ( config != _currentScope ) {
      _scopes.add( config );
      notifyListeners();
    }
  }

  Future<void> popScope() async {
    if ( _scopes.length > 2 ) {
      _scopes.removeLast();
      notifyListeners();
    }
  }

  Future<void> popScopeUntil( int index ) async {
    while ( _scopes.length > 2 && _scopes.length != index + 1 ) {
      _scopes.removeLast();
    }

    notifyListeners();
  }

  bool flag( String id ) {
    for ( var s in _scopes.reversed ) {
      if ( s.flags[ id ] != null ) {
        return s.flags[id]!;
      }
    }

    return false;
  }

  String route( int id ) {
    for ( var s in _scopes.reversed ) {
      if ( s.routes[ id ] != null ) {
        return s.routes[id]!;
      }
    }

    return '';
  }

  Map<String, Map<String, dynamic>> get theme {
    Map<String, dynamic> colors = {};
    Map<String, dynamic> sizes = {};

    for ( var s in _scopes.map((e) => e.theme) ) {
      colors.addAll( s['colors'] ?? {} );
      sizes.addAll( s['sizes'] ?? {} );
    }

    return {
      'colors': colors,
      'sizes': sizes,
    };
  }

  @override
  void addListener(VoidCallback listener) {
    listeners.add( listener );
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove( listener );
  }

  void notifyListeners() {
    for ( var l in listeners ) {
      l();
    }
  }

  @override
  Configuration get value => this;

}