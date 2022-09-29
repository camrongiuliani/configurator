import 'package:configurator/configurator.dart';

class ProxyScope extends ConfigScope {
  @override
  final String name;

  @override
  final Map<String, bool> flags;

  @override
  final Map<String, String> images;

  @override
  final Map<int, String> routes;

  @override
  final Map<String, Map<String, dynamic>> theme;

  ProxyScope({
    required this.name,
    this.flags = const {},
    this.images = const {},
    this.routes = const {},
    this.theme = const {},
  });
}