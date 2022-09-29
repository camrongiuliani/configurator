import 'package:configurator/configurator.dart';
import 'package:flutter/widgets.dart';

class ConfiguredWidget extends StatelessWidget {

  final Widget Function( Configuration config ) builder;

  const ConfiguredWidget({ required this.builder, super.key });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Configuration>(
      valueListenable: Configuration.of( context ),
      builder: ( ctx, config, _) => builder( config ),
    );
  }
}
