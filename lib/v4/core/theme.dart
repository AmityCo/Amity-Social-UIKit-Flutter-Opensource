import 'dart:ui';

class AmityTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color baseColor;
  final Color baseInverseColor;
  final Color baseColorShade1;
  final Color baseColorShade2;
  final Color baseColorShade3;
  final Color baseColorShade4;
  final Color alertColor;
  final Color backgroundColor;

  AmityTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseColor,
    required this.baseInverseColor,
    required this.baseColorShade1,
    required this.baseColorShade2,
    required this.baseColorShade3,
    required this.baseColorShade4,
    required this.alertColor,
    required this.backgroundColor,
  });

  factory AmityTheme.fromJson(Map<String, dynamic> json) {
    return AmityTheme(
      primaryColor: _colorFromHex(json['primary_color']),
      secondaryColor: _colorFromHex(json['secondary_color']),
      baseColor: _colorFromHex(json['base_color']),
      baseInverseColor: _colorFromHex(json['base_inverse_color']),
      baseColorShade1: _colorFromHex(json['base_shade1_color']),
      baseColorShade2: _colorFromHex(json['base_shade2_color']),
      baseColorShade3: _colorFromHex(json['base_shade3_color']),
      baseColorShade4: _colorFromHex(json['base_shade4_color']),
      alertColor: _colorFromHex(json['alert_color']),
      backgroundColor: _colorFromHex(json['background_color']),
    );
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

class AmityThemeColor {
  final Color primaryColor;
  final Color secondaryColor;
  final Color baseColor;
  final Color baseInverseColor;
  final Color baseColorShade1;
  final Color baseColorShade2;
  final Color baseColorShade3;
  final Color baseColorShade4;
  final Color alertColor;
  final Color backgroundColor;

  AmityThemeColor({
    required this.primaryColor,
    required this.secondaryColor,
    required this.baseColor,
    required this.baseInverseColor,
    required this.baseColorShade1,
    required this.baseColorShade2,
    required this.baseColorShade3,
    required this.baseColorShade4,
    required this.alertColor,
    required this.backgroundColor,
  });
}

// Enum to define theme styles
enum AmityThemeStyle { light, dark, system }

final lightTheme = AmityTheme(
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  baseColor: const Color(0xFF292B32),
  baseInverseColor: const Color(0xFF292B32),
  baseColorShade1: const Color(0xFF636878),
  baseColorShade2: const Color(0xFF898E9E),
  baseColorShade3: const Color(0xFFA5A9B5),
  baseColorShade4: const Color(0xFFEBECEF),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFFFFFFFF),
);

final darkTheme = AmityTheme(
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  baseColor: const Color(0xFFEBECEF),
  baseInverseColor: const Color(0xFFFFFFFF),
  baseColorShade1: const Color(0xFFA5A9B5),
  baseColorShade2: const Color(0xFF6E7487),
  baseColorShade3: const Color(0xFF40434E),
  baseColorShade4: const Color(0xFF292B32),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFF191919),
);
