import 'package:configurator/configurator.dart';

class ProxyScope extends ConfigScope {
  @override
  final String name;

  @override
  final List<String> partFiles;

  @override
  final Map<String, bool> flags;

  @override
  final Map<String, String> images;

  @override
  final Map<int, String> routes;

  @override
  Map<String, String> colors;

  @override
  Map<String, double> sizes;

  ProxyScope({
    required this.name,
    this.partFiles = const [],
    this.flags = const {},
    this.images = const {},
    this.routes = const {},
    this.colors = const {},
    this.sizes = const {},
  });
}