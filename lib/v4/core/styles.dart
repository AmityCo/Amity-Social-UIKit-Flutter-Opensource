import 'package:flutter/material.dart';

/// Custom TextStyle class for Amity with default font family
class AmityTextStyle {
  static TextStyle headline(Color color, {double? textHeight}) {
    return getStyle(20, FontWeight.w700, color, textHeight);
  }

  static TextStyle titleBold(Color color, {double? textHeight}) {
    return getStyle(17, FontWeight.w600, color, textHeight);
  }

  static TextStyle title(Color color, {double? textHeight}) {
    return getStyle(17, FontWeight.w400, color, textHeight);
  }

  static TextStyle bodyBold(Color color, {double? textHeight}) {
    return getStyle(15, FontWeight.w600, color, textHeight);
  }

  static TextStyle body(Color color, {double? textHeight}) {
    return getStyle(15, FontWeight.w400, color, textHeight);
  }

  static TextStyle captionBold(Color color, {double? textHeight}) {
    return getStyle(13, FontWeight.w600, color, textHeight);
  }

  static TextStyle caption(Color color, {double? textHeight}) {
    return getStyle(13, FontWeight.w400, color, textHeight);
  }

  static TextStyle captionSmall(Color color, {double? textHeight}) {
    return getStyle(10, FontWeight.w400, color, textHeight);
  }

  static TextStyle custom(double fontSize, FontWeight fontWeight, Color color,
      {double? textHeight}) {
    return getStyle(fontSize, fontWeight, color, textHeight);
  }

  // Note:
  // The height of the container for text is not always same as the actual font size of the text. This can cause issue in few scenarios.
  // Ex:
  // Consider a Row widget with and Icon & Text where both text & icon are centered. Depending upon text style, the position of icon
  // might be slight off from the center.
  // To fix this, we can assign a text height to be 1.0 which will make sure the height of the container is same as the font size of the text.
  //
  // At the moment, i don't want to apply it everywhere because it might cause issue of font size. So, we apply it only where it is necessary.
  static TextStyle getStyle(
      double fontSize, FontWeight fontWeight, Color color, double? textHeight) {
    return TextStyle(
      fontFamily: 'SF Pro Text',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: textHeight,
      color: color,
    );
  }
}
