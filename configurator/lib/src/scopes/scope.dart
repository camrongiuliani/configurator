import 'package:flutter/foundation.dart';

abstract class ConfigScope {

  abstract final String name;

  bool _dirty = true;

  Map<String, bool> get flags;
  Map<String, String?> get images;
  Map<int, String?> get routes;
  Map<String, Map<String, dynamic>> get theme;

  void markDirty() => _dirty = true;
  void markClean() => _dirty = false;
  bool get dirty => _dirty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigScope &&
          mapEquals( flags, other.flags ) &&
          mapEquals( images, other.images ) &&
          mapEquals( routes, other.routes ) &&
          mapEquals( theme, other.theme );

  @override
  int get hashCode => flags.hashCode ^ images.hashCode ^ routes.hashCode ^ theme.hashCode;
}