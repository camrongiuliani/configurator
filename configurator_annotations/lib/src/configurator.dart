import 'package:meta/meta.dart';

@immutable
class Configurator {

  final List<String> yaml;

  const Configurator({ this.yaml = const [] });
}
