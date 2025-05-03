import 'dart:async';
import 'package:configurator/configurator.dart';
import 'package:meta/meta.dart';

/// A class that manages configuration change notifications.
///
/// This class provides a mechanism to notify listeners when the configuration changes.
/// It uses a broadcast stream controller to allow multiple listeners to receive
/// configuration updates.
///
/// Note: This class is not part of the public API and is intended for internal use only.
class ChangeNotifier {
  final StreamController<Configuration> _streamController;

  /// Creates a new [ChangeNotifier] with a broadcast stream controller.
  ///
  /// Note: This constructor is not part of the public API.
  ChangeNotifier() : _streamController = StreamController<Configuration>.broadcast();

  /// Creates a new [ChangeNotifier] with a custom stream controller for testing.
  ///
  /// Note: This constructor is not part of the public API.
  @visibleForTesting
  ChangeNotifier.debug(this._streamController);

  /// Notifies all listeners that the configuration has changed.
  ///
  /// Parameters:
  /// * [configuration] - The new configuration to notify listeners about
  ///
  /// Note: This method is not part of the public API.
  void notify(Configuration configuration) {
    _streamController.add(configuration);
  }

  /// Returns a stream of configuration changes.
  ///
  /// Returns:
  /// * A [Stream] that emits configuration updates
  ///
  /// Note: This method is not part of the public API.
  Stream<Configuration> watch() => _streamController.stream;

  /// Closes the stream controller and releases its resources.
  ///
  /// Returns:
  /// * A [Future] that completes when the stream controller is closed
  ///
  /// Note: This method is not part of the public API.
  Future<void> close() {
    return _streamController.close();
  }
}