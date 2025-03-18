
import 'dart:ui';

import 'package:amity_uikit_beta_service/v4/core/theme.dart';

class MessageColor {
  final AmityThemeColor theme;
  final Map<String, dynamic> config;
  late Color leftBubbleDefault;
  late Color leftBubblePressed;
  late Color leftBubbleText;
  late Color leftBubbleSubtleText;
  late Color rightBubbleDefault;
  late Color rightBubblePressed;
  late Color rightBubbleText;
  late Color rightBubbleSubtleText;
  late Color bubbleDivider;

  MessageColor({
    required this.theme,
    required this.config,
  }) {
    leftBubbleDefault = getColor('left_bubble_color', theme.baseColorShade4);
    leftBubblePressed = getColor('left_bubble_pressed_color', theme.baseColorShade3);
    leftBubbleText = getColor('left_bubble_text_color', theme.baseColor);
    leftBubbleSubtleText = getColor('left_bubble_subtle_text_color', theme.baseColorShade2);
    rightBubbleDefault = getColor('right_bubble_color', theme.primaryColor);
    rightBubblePressed = getColor('right_bubble_pressed_color', theme.primaryColor.darken(15));
    rightBubbleText = getColor('right_bubble_text_color', theme.baseInverseColor);
    rightBubbleSubtleText = getColor('right_bubble_subtle_text_color', theme.primaryColor.blend(ColorBlendingOption.shade2));
    bubbleDivider = getColor('bubble_divider_color', _colorFromHex("#C1C1C1"));
  }
  
  Color getColor(String configName, Color defaultColor) {
    try {
      final configString = config[configName] as String?;
      return _colorFromHex(configString);
    } catch (e) {
      return defaultColor;
    }
  }



  static Color _colorFromHex(String? hexColor) {
    if (hexColor == null) return const Color(0x00000000);
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
