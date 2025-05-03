import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/widgets.dart';

/// A widget that automatically rebuilds when the configuration changes.
///
/// This widget provides a convenient way to create configuration-aware UI
/// components. It listens to configuration changes and rebuilds its child
/// widget whenever the configuration is updated.
///
/// Example usage:
/// ```dart
/// ConfiguredWidget(
///   builder: (config) => Text(
///     'Hello',
///     style: TextStyle(
///       color: config.colors.primary,
///       fontSize: config.sizes.text,
///     ),
///   ),
/// )
/// ```
class ConfiguredWidget extends StatelessWidget {
  /// A builder function that creates a widget using the current configuration.
  final Widget Function(Configuration config) builder;

  /// Creates a new [ConfiguredWidget].
  ///
  /// Parameters:
  /// * [builder] - A function that builds a widget using the current configuration
  /// * [key] - An optional key for the widget
  const ConfiguredWidget({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Configuration>(
      valueListenable: ConfigurationProvider.of(context).config.listenable(),
      builder: (ctx, config, _) => builder(config),
    );
  }
}
