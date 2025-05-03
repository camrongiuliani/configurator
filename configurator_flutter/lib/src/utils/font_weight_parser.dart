import 'dart:ui';

/// A utility class for parsing font weight values into Flutter [FontWeight] objects.
///
/// This class provides functionality to convert numeric font weight values into
/// Flutter's [FontWeight] constants. The conversion follows the CSS font-weight
/// specification, where values range from 100 to 900 in increments of 100.
class FontWeightParser {
  /// Converts a numeric font weight value into a [FontWeight] constant.
  ///
  /// The conversion follows these rules:
  /// * 100-150 → FontWeight.w100
  /// * 151-250 → FontWeight.w200
  /// * 251-350 → FontWeight.w300
  /// * 351-450 → FontWeight.w400 (normal)
  /// * 451-550 → FontWeight.w500
  /// * 551-650 → FontWeight.w600
  /// * 651-750 → FontWeight.w700 (bold)
  /// * 751-850 → FontWeight.w800
  /// * 851-950 → FontWeight.w900
  ///
  /// If the value is outside these ranges, [FontWeight.w400] (normal) is returned.
  ///
  /// Parameters:
  /// * [value] - The numeric font weight value
  ///
  /// Returns:
  /// * A [FontWeight] constant corresponding to the input value
  static FontWeight parse(int value) {
    if (value <= 150) {
      return FontWeight.w100;
    } else if (value <= 250) {
      return FontWeight.w200;
    } else if (value <= 350) {
      return FontWeight.w300;
    } else if (value <= 450) {
      return FontWeight.w400;
    } else if (value <= 550) {
      return FontWeight.w500;
    } else if (value <= 650) {
      return FontWeight.w600;
    } else if (value <= 750) {
      return FontWeight.w700;
    } else if (value <= 850) {
      return FontWeight.w800;
    } else if (value <= 950) {
      return FontWeight.w900;
    }

    return FontWeight.w400;
  }
}