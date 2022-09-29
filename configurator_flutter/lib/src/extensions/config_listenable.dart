import 'dart:async';
import 'package:configurator/configurator.dart';
import 'package:flutter/foundation.dart';

extension ConfigurationF on Configuration {
  ValueListenable<Configuration> listenable() => _ConfigListenable( this );
}

class _ConfigListenable extends ValueListenable<Configuration> {

  final Configuration configuration;

  final List<VoidCallback> _listeners = [];

  StreamSubscription? _subscription;

  _ConfigListenable( this.configuration );

  @override
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
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);

    if (_listeners.isEmpty) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  Configuration get value => configuration;
}