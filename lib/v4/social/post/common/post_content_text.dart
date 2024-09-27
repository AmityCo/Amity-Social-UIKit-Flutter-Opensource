import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class PostContentText extends StatelessWidget {
  final AmityPost post;
  final AmityThemeColor theme;
  const PostContentText({super.key, required this.post, required this.theme});

  @override
  Widget build(BuildContext context) {
    String textContent = "";
    if (post.data is TextData) {
      textContent = (post.data as TextData).text ?? "";
    }
    return textContent.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              textContent,
              style: TextStyle(
                color: theme.baseColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : Container();
  }
}
