class YamlRoute {

  final int id;
  final String path;
  final List<dynamic> children;

  YamlRoute( this.id, this.path, this.children );

  factory YamlRoute.fromJson( Map<dynamic, dynamic> json ) {
    return YamlRoute(
      json['id'],
      json['path'],
      ( json['children'] ?? [] ).map( ( e ) => YamlRoute.fromJson( e ) ).toList(),
    );
  }
}