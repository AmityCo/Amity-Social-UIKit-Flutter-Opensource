import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/expandable_text.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

class PostContentText extends StatelessWidget {
  final AmityPost post;
  final AmityThemeColor theme;
  const PostContentText({super.key, required this.post, required this.theme});

  @override
  Widget build(BuildContext context) {
    return getTextPostContent(context, post);
  }

  Widget getTextPostContent(BuildContext context, AmityPost post) {
    // Get the text content from the post.
    String textContent = "";
    if (post.data is TextData) {
      textContent = (post.data as TextData).text ?? "";
    }

    // Define your normal text style and mention highlight style.
    final normalStyle = TextStyle(
      color: theme.baseColor,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
    final mentionStyle = TextStyle(
      color: theme.highlightColor, // Use your highlight color from the theme.
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );

    List<AmityUserMentionMetadata>? mentionedUsers;
    if (post.metadata != null && post.metadata!['mentioned'] != null) {
      // Obtain the mention metadata from the post.
      final mentionedGetter =
          AmityMentionMetadataGetter(metadata: post.metadata!);
      mentionedUsers =
          mentionedGetter.getMentionedUsers();

      // Sort mention metadata by starting index (if not already sorted).
      mentionedUsers.sort((a, b) => a.index.compareTo(b.index));
    }

    // Return a RichText widget with the computed spans.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpandableText(
          text: textContent,
          mentionedUsers: mentionedUsers,
          style: normalStyle,
          linkStyle: mentionStyle,
          onMentionTap: (userId) => _goToUserProfilePage(context, userId),
          ),
    );
  }

  void _goToUserProfilePage(BuildContext context, String userId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AmityUserProfilePage(userId: userId)));
  }
}
