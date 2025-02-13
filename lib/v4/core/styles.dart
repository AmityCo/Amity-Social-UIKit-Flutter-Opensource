import 'package:flutter/material.dart';

/// Custom TextStyle class for Amity with default font family
class AmityTextStyle {

  static TextStyle headline(Color color) {
    return getStyle(20, FontWeight.w700, color);
  }

  static TextStyle titleBold(Color color) {
    return getStyle(17, FontWeight.w600, color);
  }

  static TextStyle title(Color color) {
    return getStyle(17, FontWeight.w400, color);
  }

  static TextStyle bodyBold(Color color) {
    return getStyle(15, FontWeight.w600, color);
  }

  static TextStyle body(Color color) {
    return getStyle(15, FontWeight.w400, color);
  }

  static TextStyle captionBold(Color color) {
    return getStyle(13, FontWeight.w600, color);
  }

  static TextStyle caption(Color color) {
    return getStyle(13, FontWeight.w400, color);
  }

  static TextStyle captionSmall(Color color) {
    return getStyle(10, FontWeight.w400, color);
  }

  static TextStyle custom(double fontSize, FontWeight fontWeight, Color color) {
    return getStyle(fontSize, fontWeight, color);
  }

  static TextStyle getStyle(double fontSize, FontWeight fontWeight, Color color) {
    return TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
  }
}
