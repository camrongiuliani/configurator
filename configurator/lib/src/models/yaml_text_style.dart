class YamlTextStyle {
  final String key;
  final String color;
  final int size;
  final int weight;
  final int height;

  final Map<String, String> typeface;

  /// Model containing TextStyle information
  YamlTextStyle({
    required this.key,
    required this.color,
    required this.size,
    required this.weight,
    required this.height,
    required this.typeface,
  });

  factory YamlTextStyle.fromJson(Map json) => YamlTextStyle(
    key: json['key'] as String,
    color: json['color'] as String,
    size: json['size'] as int,
    weight: json['weight'] as int,
    height: json['height'] as int,
    typeface: json['typeface'] as Map<String, String>,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'key': key,
    'color': color,
    'size': size,
    'weight': weight,
    'height': height,
    'typeface': typeface,
  };
}