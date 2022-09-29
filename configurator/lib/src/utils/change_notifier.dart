import 'dart:async';
import 'package:configurator/configurator.dart';
import 'package:meta/meta.dart';

/// Not part of public API
class ChangeNotifier {
  final StreamController<Configuration> _streamController;

  /// Not part of public API
  ChangeNotifier() : _streamController = StreamController<Configuration>.broadcast();

  /// Not part of public API
  @visibleForTesting
  ChangeNotifier.debug(this._streamController);

  /// Not part of public API
  void notify( Configuration configuration ) {
    _streamController.add( configuration );
  }

  /// Not part of public API
  Stream<Configuration> watch() => _streamController.stream;

  /// Not part of public API
  Future<void> close() {
    return _streamController.close();
  }
}