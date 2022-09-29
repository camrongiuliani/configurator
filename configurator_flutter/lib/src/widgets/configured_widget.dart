import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

class ConfiguredWidget extends StatelessWidget {

  final Widget Function( Configuration config ) builder;

  const ConfiguredWidget({ required this.builder, super.key });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Configuration>(
      valueListenable: ConfigurationProvider.of( context ).config.listenable(),
      builder: ( ctx, config, _) => builder( config ),
    );
  }
}
