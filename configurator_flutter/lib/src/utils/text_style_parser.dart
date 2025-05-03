import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class for parsing text style configurations into Flutter [TextStyle] objects.
///
/// This class provides functionality to convert text style configurations from
/// the configurator into Flutter's [TextStyle] objects, with support for
/// Google Fonts integration.
class TextStyleParser {
  /// Parses a text style configuration into a Flutter [TextStyle] object.
  ///
  /// This method takes a configuration key and creates a [TextStyle] object
  /// with the following properties:
  /// * Color (parsed using [ColorParser])
  /// * Font size
  /// * Font weight (parsed using [FontWeightParser])
  /// * Font family
  /// * Line height
  ///
  /// If the font source is specified as 'GoogleFont', it will attempt to use
  /// Google Fonts to load the font family.
  ///
  /// Parameters:
  /// * [config] - The configuration containing the text style settings
  /// * [key] - The key of the text style in the configuration
  ///
  /// Returns:
  /// * A [TextStyle] object with the parsed properties
  static TextStyle parse(Configuration config, String key) {
    var ts = config.textStyle(key);
    var fontSize = ts["size"] ?? 12.0;
    var source = ts["typeface"]?["source"];
    var heightAbs = ts["height"] ?? 0.0;
    var fontFamily = ts["typeface"]?["family"] ?? "Poppins";

    var style = TextStyle(
      color: ColorParser.parse(ts["color"]),
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeightParser.parse(ts["weight"] ?? 400),
      fontFamily: fontFamily,
      height: heightAbs == 0 ? null : (heightAbs / fontSize),
    );

    if (source == 'GoogleFont') {
      try {
        return GoogleFonts.getFont(fontFamily, textStyle: style);
      } catch (_) {}
    }

    return style;
  }
}