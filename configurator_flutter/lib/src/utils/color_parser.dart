// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// A utility class for parsing color values into Flutter [Color] objects.
///
/// This class provides functionality to convert various color formats into
/// Flutter's [Color] objects, including:
/// * Hex color codes (e.g., "#FF0000" or "#FFFF0000")
/// * RGB and RGBA strings (e.g., "rgb(255, 0, 0)" or "rgba(255, 0, 0, 0.5)")
/// * Flutter [Color] objects
class ColorParser {
  /// Converts a hex color code string into a [Color] object.
  ///
  /// The hex string can be in the following formats:
  /// * 6 digits (e.g., "FF0000")
  /// * 8 digits (e.g., "FFFF0000")
  /// * With or without a "#" prefix
  ///
  /// Parameters:
  /// * [input] - The hex color code string
  ///
  /// Returns:
  /// * A [Color] object representing the hex color
  /// * [Colors.transparent] if the input is invalid
  static Color _colorFromHex(String input) {
    String c = input.toUpperCase().replaceAll("#", "");
    if (![6, 8].contains(c.length)) {
      return Colors.transparent;
    }
    if (c.length == 6) {
      c = 'FF$c';
    }
    int? iVal = int.tryParse(c, radix: 16);
    if (iVal != null) {
      return Color(iVal);
    }
    return Colors.transparent;
  }

  /// Converts an RGB or RGBA string into a [Color] object.
  ///
  /// The string should be in one of these formats:
  /// * "rgb(r, g, b)"
  /// * "rgba(r, g, b, a)"
  ///
  /// Parameters:
  /// * [color] - The RGB or RGBA color string
  ///
  /// Returns:
  /// * A [Color] object representing the RGB/RGBA color
  /// * [Colors.transparent] if the input is invalid
  static Color _colorFromRGBString(String color) {
    try {
      bool hasAlpha = color.toLowerCase().startsWith('rgba');
      String numParts = color
          .replaceAll("rgb(", "")
          .replaceAll("rgba(", "")
          .replaceAll(")", "");
      List<String> rgbSplit = numParts.split(",").map((e) => e.trim()).toList();
      int r = int.parse(rgbSplit[0]);
      int g = int.parse(rgbSplit[1]);
      int b = int.parse(rgbSplit[2]);
      double a = hasAlpha ? double.parse(rgbSplit[3]) : 1.0;
      return Color.fromRGBO(r, g, b, a);
    } on Object {
      return Colors.transparent;
    }
  }

  /// Converts a [Color] object into an RGBA string.
  ///
  /// Parameters:
  /// * [color] - The color to convert
  ///
  /// Returns:
  /// * A string in the format "rgba(r, g, b, a)"
  static String colorToString(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    final o = color.opacity;
    return 'rgba($r,$g,$b,$o)';
  }

  /// Parses a color value into a [Color] object.
  ///
  /// This method can handle various input types:
  /// * [Color] objects (returned as-is)
  /// * Hex color strings (e.g., "#FF0000")
  /// * RGB/RGBA strings (e.g., "rgb(255, 0, 0)")
  ///
  /// Parameters:
  /// * [input] - The color value to parse
  ///
  /// Returns:
  /// * A [Color] object representing the input color
  /// * [Colors.transparent] if the input is invalid
  static Color parse(dynamic input) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      return Color(input);
    }
    if (input is String) {
      if (input.toLowerCase().startsWith('rgb')) {
        return _colorFromRGBString(input);
      }
      return _colorFromHex(input);
    }
    return Colors.transparent;
  }
}
