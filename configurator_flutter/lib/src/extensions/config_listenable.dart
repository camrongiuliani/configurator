import 'dart:async';
import 'package:configurator/configurator.dart';
import 'package:flutter/foundation.dart';

/// Extension methods for making [Configuration] objects listenable.
///
/// This extension provides functionality to convert a [Configuration] object
/// into a [ValueListenable] that can be used with Flutter's reactive widgets.
extension ConfigurationF on Configuration {
  /// Creates a [ValueListenable] that notifies listeners when the configuration changes.
  ///
  /// Returns:
  /// * A [ValueListenable] that wraps this configuration
  ValueListenable<Configuration> listenable() => _ConfigListenable(this);
}

/// A private implementation of [ValueListenable] for configuration objects.
///
/// This class manages a list of listeners and notifies them when the configuration
/// changes. It uses a [StreamSubscription] to listen to configuration updates.
class _ConfigListenable extends ValueListenable<Configuration> {
  /// The configuration being listened to
  final Configuration configuration;

  /// The list of listeners to notify when the configuration changes
  final List<VoidCallback> _listeners = [];

  /// The subscription to the configuration's change stream
  StreamSubscription? _subscription;

  /// Creates a new [_ConfigListenable] for the given configuration.
  ///
  /// Parameters:
  /// * [configuration] - The configuration to listen to
  _ConfigListenable(this.configuration);

  @override
  /// Adds a listener to be notified when the configuration changes.
  ///
  /// If this is the first listener being added, it will also start listening
  /// to the configuration's change stream.
  ///
  /// Parameters:
  /// * [listener] - The callback to be called when the configuration changes
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      _subscription = configuration.watch().listen((_) {
        for (var listener in _listeners) {
          listener();
        }
      });
    }

    _listeners.add(listener);
  }

  @override
  /// Removes a listener from the list of listeners.
  ///
  /// If this was the last listener, it will also cancel the subscription
  /// to the configuration's change stream.
  ///
  /// Parameters:
  /// * [listener] - The callback to be removed
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  /// Gets the current configuration value.
  ///
  /// Returns:
  /// * The current [Configuration] object
  Configuration get value => configuration;
}