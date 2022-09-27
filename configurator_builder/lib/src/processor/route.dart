import 'dart:convert';
import 'package:configurator_builder/src/model/route.dart';
import 'package:configurator_builder/src/processor/processor.dart';
import 'package:yaml/yaml.dart';

class RouteProcessor extends Processor<List<ProcessedRoute>> {

  final YamlNode node;

  RouteProcessor( this.node );

  @override
  List<ProcessedRoute> process() {
    List<ProcessedRoute> _routes = [];

    try {

      var nodeValue = node.value[ 'routes' ];

      if ( nodeValue is! YamlList ) {
        return _routes;
      }

      var str = jsonEncode( nodeValue );

      List<dynamic> routeList = json.decode( str );

      for ( var route in routeList ) {
        _routes.add( ProcessedRoute( route[ 'id' ], route[ 'path' ] ) );

        if ( route.containsKey( 'children' ) && route['children'] is List ) {
          var root = route[ 'path' ];

          for ( var route in route['children']) {
            _routes.add( ProcessedRoute( route[ 'id' ], root + route[ 'path' ] ) );
          }
        }
      }

    } catch( e ) {
      print( e );
    }

    return _routes;

  }
}