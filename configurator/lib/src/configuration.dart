import 'package:configurator/configurator.dart';

class Configuration {

  // ignore: avoid_positional_boolean_parameters
  void throwIf(bool condition, Object error) {
    if (condition) throw error;
  }

  // ignore: avoid_positional_boolean_parameters
  void throwIfNot(bool condition, Object error) {
    if (!condition) throw error;
  }

  final List<ConfigScope> _scopes;

  const Configuration([ this._scopes = const [] ]);

  ConfigScope get _currentScope => _scopes.last;

  void pushScope( covariant ConfigScope config ) {
    _scopes.add( config );
  }

  Future<void> popScope() async {
    throwIfNot(
        _scopes.length > 1,
        StateError(
            "Configurations: You are already on the base scope. you can't pop this one"));

    _scopes.removeLast();
  }

  bool flag( String id ) => _currentScope.flags[id]!;
  String route( int id ) => _currentScope.routes[id]!;

}