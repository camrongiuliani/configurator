import 'package:configurator/configurator.dart';
import 'package:flutter/widgets.dart';

class ConfigurationProvider extends InheritedWidget {

  final Configuration configuration;

  const ConfigurationProvider._( this.configuration, { required super.child, super.key } );

  factory ConfigurationProvider( {
    required Configuration config,
    required Widget child,
    Key? key,
  } ) {

    return ConfigurationProvider._(
      config,
      key: key ?? UniqueKey(),
      child: child,
    );
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    bool dirt =  configuration.scopes.map( ( e ) => e.dirty ).contains( true );
    print('Config Dirty: $dirt');

    for ( var scope in configuration.scopes ) {
      scope.markClean();
    }

    return dirt;
  }
}