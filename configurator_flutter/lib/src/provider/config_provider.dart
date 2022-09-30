import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

final _configProviderKey = GlobalKey<_ConfigurationProviderState>();

class Configurator extends StatefulWidget {

  final Configuration config;
  final Widget Function( BuildContext, Configuration ) builder;

  Configurator({
    required this.config,
    required this.builder,
  }) : super( key: _configProviderKey );

  @override
  State<Configurator> createState() => _ConfigurationProviderState();
}

class _ConfigurationProviderState extends State<Configurator> {

  @override
  void initState() {

    widget.config.listenable().addListener( configListener );

    super.initState();
  }

  @override
  void dispose() {
    widget.config.listenable().removeListener( configListener );
    super.dispose();
  }

  void configListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConfigurationProvider(
      config: widget.config,
      child: Builder(
        builder: ( ctx ) => widget.builder( ctx, widget.config ),
      ),
    );
  }
}


class ConfigurationProvider extends InheritedWidget {

  final Configuration config;

  const ConfigurationProvider( {
    required this.config,
    required super.child,
    super.key,
  } );

  static ConfigurationProvider of( BuildContext context, { bool listen = true } ) {

    final ConfigurationProvider? result = context.findAncestorWidgetOfExactType();

    if ( listen ) {
      context.dependOnInheritedWidgetOfExactType<ConfigurationProvider>();
    }

    assert(result != null, 'No ConfigurationProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant ConfigurationProvider oldWidget) {
    // Todo: Eventually manage config state so that we can more efficiently rebuild dependants.

    // Function deepEq = const DeepCollectionEquality().equals;

    return true;
  }
}