
abstract class ConfigScope {

  abstract final String name;

  Map<String, bool> get flags;
  Map<String, String?> get images;
  Map<int, String?> get routes;

}