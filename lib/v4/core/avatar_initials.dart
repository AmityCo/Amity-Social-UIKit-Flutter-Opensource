import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AvatarInitials extends StatelessWidget {
  final String displayName;
  final Size size;
  final TextStyle? characterTextStyle;
  final AmityThemeColor theme;

  const AvatarInitials({
    Key? key,
    required this.theme,
    required this.displayName,
    this.size = const Size(40, 40),
    this.characterTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final fontSize = size.height * 0.3;

    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        color: theme.avatarBackgroundColor,
        border: Border.all(color: theme.avatarBorderColor, width: 1.0),
        shape: BoxShape.circle,
      ),
      child: Center(
          child: Text(
        initials,
        style: characterTextStyle ?? AmityTextStyle.custom(fontSize, FontWeight.w400, theme.avatarTextColor),
      )),
    );
  }

  String _getInitials() {
    if (displayName.trim().isEmpty) {
      return 'A';
    }

    final nameParts = displayName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
  }
}
