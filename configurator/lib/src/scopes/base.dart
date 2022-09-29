import 'package:configurator/configurator.dart';

class RootScope extends ConfigScope {
  @override
  String name = '__root';

  @override
  Map<String, bool> flags = const {};

  @override
  Map<String, String> images = const {};

  @override
  Map<int, String> routes = const {};

  @override
  Map<String, Map<String, dynamic>> get theme => const {};
}