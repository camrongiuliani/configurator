import 'package:configurator/configurator.dart';
import 'package:flutter/widgets.dart' hide Router;
import 'package:configurator_annotations/configurator_annotations.dart';

part 'provider.g.dart';

@Configurator(
  yaml: [
    './assets/example1.yaml',
  ],
)
class ConfigurationProvider extends InheritedWidget {

  final Configuration configuration;

  const ConfigurationProvider._( this.configuration, { required super.child, super.key } );

  factory ConfigurationProvider( {
    required Configuration configuration,
    Widget widget = const SizedBox(),
    dynamic arguments,
    Key? key,
  } ) {

    configuration.pushScope( BaseConfigScope() );

    return ConfigurationProvider._(
      configuration,
      key: key ?? UniqueKey(),
      child: widget,
    );
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}