import 'package:configurator/configurator.dart';

class ProxyScope extends ConfigScope {
  @override
  final String name;

  @override
  final int weight;

  @override
  final List<String> partFiles;

  @override
  final Map<String, bool> flags;

  @override
  final Map<String, dynamic> images;

  @override
  final Map<int, String> routes;

  @override
  Map<String, String> colors;

  @override
  Map<String, double> sizes;

  @override
  Map<String, double> padding;

  @override
  Map<String, double> margins;

  @override
  Map<String, dynamic> misc;

  ProxyScope({
    required this.name,
    this.partFiles = const [],
    this.weight = 0,
    this.flags = const {},
    this.images = const {},
    this.routes = const {},
    this.colors = const {},
    this.sizes = const {},
    this.padding = const {},
    this.margins = const {},
    this.misc = const {},
  });
}