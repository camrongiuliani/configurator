import 'package:meta/meta.dart';

@immutable
class ConfiguratorApp {

  final List<String> yaml;

  const ConfiguratorApp({ this.yaml = const [] });
}