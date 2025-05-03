/// A model class representing a route configuration loaded from YAML.
///
/// This class encapsulates route information including its ID, path, and child routes,
/// allowing for hierarchical route configuration.
///
/// Example YAML:
/// ```yaml
/// routes:
///   - id: 1
///     path: "/home"
///     children:
///       - id: 2
///         path: "/dashboard"
///       - id: 3
///         path: "/profile"
/// ```
class YamlRoute {
  /// The unique identifier for this route
  final int id;

  /// The path pattern for this route
  final String path;

  /// List of child routes
  final List<dynamic> children;

  /// The ID of the parent route, if any
  final int? parentId;

  /// Creates a new YamlRoute instance.
  ///
  /// Parameters:
  /// * [id] - The unique identifier for this route
  /// * [path] - The path pattern for this route
  /// * [children] - List of child routes
  /// * [parentId] - Optional ID of the parent route
  YamlRoute(this.id, this.path, this.children, [this.parentId]);

  /// Creates a YamlRoute instance from a JSON map.
  ///
  /// This factory constructor also processes child routes recursively,
  /// ensuring their paths are properly prefixed with the parent route's path.
  ///
  /// Parameters:
  /// * [json] - A map containing the route properties
  /// * [parentId] - Optional ID of the parent route
  /// Returns:
  /// * A new YamlRoute instance
  factory YamlRoute.fromJson(Map<dynamic, dynamic> json, [int? parentId]) {
    return YamlRoute(
      json['id'],
      json['path'],
      (json['children'] ?? []).map((e) {
        e['path'] = '${json['path']}${e['path']}';
        return YamlRoute.fromJson(e, json['id']);
      }).toList(),
      parentId,
    );
  }

  /// Compares two YamlRoute instances for equality.
  ///
  /// Two instances are considered equal if they have the same ID, path, and parent ID.
  ///
  /// Parameters:
  /// * [other] - The object to compare with
  /// Returns:
  /// * `true` if the objects are equal, `false` otherwise
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlRoute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          parentId == other.parentId;

  /// Returns a hash code for this YamlRoute instance.
  ///
  /// The hash code is computed from the ID, path, and parent ID.
  ///
  /// Returns:
  /// * A hash code value for this object
  @override
  int get hashCode => id.hashCode ^ path.hashCode ^ parentId.hashCode;
}