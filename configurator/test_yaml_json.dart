import 'dart:convert';
import 'package:yaml/yaml.dart';

void main() {
  var yaml = loadYaml('enums:\n  theme:\n    type: AppTheme\n    value: dark');
  try {
    print('jsonEncode(yaml): ${jsonEncode(yaml)}');
  } catch (e) {
    print('jsonEncode failed: $e');
  }
}
