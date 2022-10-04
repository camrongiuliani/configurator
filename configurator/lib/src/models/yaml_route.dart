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
        var child = YamlRoute.fromJson( e, json['id'] );


        return child;
      }).toList(),
      parentId,
    );
  }
}