class YamlRoute {

  final int id;
  final String path;
  final List<dynamic> children;
  final int? parentId;

  YamlRoute( this.id, this.path, this.children, [ this.parentId ] );

  factory YamlRoute.fromJson( Map<dynamic, dynamic> json, [ int? parentId ] ) {
    return YamlRoute(
      json['id'],
      json['path'],
      ( json['children'] ?? [] ).map( ( e ) {
        e['path'] = '${json['path']}${e['path']}';
        return YamlRoute.fromJson( e, json['id'] );
      }).toList(),
      parentId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlRoute &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          parentId == other.parentId;

  @override
  int get hashCode => id.hashCode ^ path.hashCode ^ parentId.hashCode;
}