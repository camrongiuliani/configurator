import 'dart:ui';

class FontWeightParser {
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