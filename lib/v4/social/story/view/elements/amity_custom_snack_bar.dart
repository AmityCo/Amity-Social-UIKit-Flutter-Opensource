import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityCustomSnackBar {
  static void show(
    BuildContext context,
    String message,
    SvgPicture icon, {
    Color backgroundColor = const Color(0xff292B32),
    Color textColor = Colors.white,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
