import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyleParser {
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