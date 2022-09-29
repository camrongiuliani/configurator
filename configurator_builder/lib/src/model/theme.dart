import 'package:configurator_builder/src/model/color.dart';
import 'package:configurator_builder/src/model/size.dart';

class ProcessedTheme {

  final List<ProcessedColor> colors;
  final List<ProcessedSize> sizes;

  ProcessedTheme( this.colors, this.sizes );

  operator +(ProcessedTheme t) {
    colors.retainWhere(( e ) => ! t.colors.contains( e ));
    colors.addAll( t.colors );

    sizes.retainWhere(( e ) => ! t.sizes.contains( e ));
    sizes.addAll( t.sizes );
  }
}