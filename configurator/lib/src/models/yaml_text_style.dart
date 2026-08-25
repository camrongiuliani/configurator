/// A model class representing text style configuration loaded from YAML.
///
/// This class encapsulates all the properties needed to define a text style,
/// including color, size, weight, height, and typeface information. It provides
/// methods to convert between YAML/JSON and Dart objects.
///
/// Example YAML:
/// ```yaml
/// textStyles:
///   heading1:
///     color: "#000000"
///     size: 24
///     weight: 700
///     height: 1.2
///     typeface:
///       family: "Roboto"
///       style: "normal"
/// ```
class YamlTextStyle {
  /// The unique identifier for this text style.
  final String key;

  /// The color of the text, typically in hex format (e.g., "#000000").
  final String color;

  /// The font size in logical pixels.
  final int size;

  /// The font weight (e.g., 400 for normal, 700 for bold).
  final int weight;

  /// The line height multiplier.
  final int height;

  /// Typeface information including family and style.
  final Map<String, String> typeface;

  /// Creates a new YamlTextStyle instance.
  ///
  /// Parameters:
  /// * [key] - The unique identifier for this text style
  /// * [color] - The text color in hex format
  /// * [size] - The font size in logical pixels
  /// * [weight] - The font weight
  /// * [height] - The line height multiplier
  /// * [typeface] - Typeface configuration including family and style
  YamlTextStyle({
    required this.key,
    required this.color,
    required this.size,
    required this.weight,
    required this.height,
    required this.typeface,
  });

  /// Creates a YamlTextStyle instance from a JSON map.
  ///
  /// Parameters:
  /// * [json] - A map containing the text style properties
  /// Returns:
  /// * A new YamlTextStyle instance
  factory YamlTextStyle.fromJson(Map json) => YamlTextStyle(
        key: json['key'] as String,
        color: json['color'] as String,
        size: json['size'] as int,
        weight: json['weight'] as int,
        height: json['height'] as int,
        typeface: json['typeface'] as Map<String, String>,
      );

  /// Converts this YamlTextStyle instance to a JSON map.
  ///
  /// Returns:
  /// * A map containing all the text style properties
  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'color': color,
        'size': size,
        'weight': weight,
        'height': height,
        'typeface': typeface,
      };
}
