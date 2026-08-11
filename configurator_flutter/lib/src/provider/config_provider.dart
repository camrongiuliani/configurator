import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

/// A stateful widget that provides configuration management and rebuilding capabilities.
///
/// This widget manages a [Configuration] instance and automatically rebuilds its child
/// when the configuration changes. It uses [ConfigurationProvider] internally to make
/// the configuration available to descendant widgets.
///
/// Example:
/// ```dart
/// Configurator(
///   config: myConfig,
///   builder: (context, config) => Text(config.getString('welcome_message')),
/// )
/// ```
class Configurator extends StatefulWidget {
  /// The configuration instance to be managed
  final Configuration config;

  /// A builder function that creates the widget tree using the provided configuration
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [config] - The current configuration instance
  final Widget Function(BuildContext, Configuration) builder;

  const Configurator({required this.config, required this.builder, super.key});

  @override
  State<Configurator> createState() => _ConfigurationProviderState();
}

class _ConfigurationProviderState extends State<Configurator> {
  @override
  void initState() {
    widget.config.listenable().addListener(configListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.config.listenable().removeListener(configListener);
    super.dispose();
  }

  /// Callback that triggers a rebuild when the configuration changes
  void configListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfigurationProvider(
      config: widget.config,
      child: Builder(builder: (ctx) => widget.builder(ctx, widget.config)),
    );
  }
}

/// An [InheritedWidget] that provides configuration access to descendant widgets.
///
/// This widget makes a [Configuration] instance available to its descendants through
/// the [of] and [maybeOf] static methods. Widgets that depend on the configuration
/// will automatically rebuild when the configuration changes.
///
/// Example:
/// ```dart
/// final config = ConfigurationProvider.of(context).config;
/// final welcomeMessage = config.getString('welcome_message');
/// ```
class ConfigurationProvider extends InheritedWidget {
  /// The configuration instance being provided to descendants
  final Configuration config;

  const ConfigurationProvider({
    required this.config,
    required super.child,
    super.key,
  });

  /// Retrieves the nearest [ConfigurationProvider] ancestor from the widget tree.
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [listen] - Whether to register the calling widget for rebuilds when the configuration changes
  ///
  /// Returns:
  /// * The nearest [ConfigurationProvider] instance
  ///
  /// Throws:
  /// * [AssertionError] if no [ConfigurationProvider] is found in the widget tree
  static ConfigurationProvider of(BuildContext context, {bool listen = true}) {
    final ConfigurationProvider? result =
        context.findAncestorWidgetOfExactType();

    if (listen) {
      context.dependOnInheritedWidgetOfExactType<ConfigurationProvider>();
    }

    assert(result != null, 'No ConfigurationProvider found in context');
    return result!;
  }

  /// Similar to [of], but returns null if no [ConfigurationProvider] is found.
  ///
  /// Parameters:
  /// * [context] - The build context
  /// * [listen] - Whether to register the calling widget for rebuilds when the configuration changes
  ///
  /// Returns:
  /// * The nearest [ConfigurationProvider] instance, or null if none is found
  static ConfigurationProvider? maybeOf(
    BuildContext context, {
    bool listen = true,
  }) {
    final ConfigurationProvider? result =
        context.findAncestorWidgetOfExactType();

    if (result != null && listen) {
      context.dependOnInheritedWidgetOfExactType<ConfigurationProvider>();
    }

    return result;
  }

  @override
  bool updateShouldNotify(covariant ConfigurationProvider oldWidget) {
    // TODO: Eventually manage config state so that we can more efficiently rebuild dependants.
    return true;
  }
}
