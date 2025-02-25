import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class PostContentText extends StatelessWidget {
  final AmityPost post;
  final AmityThemeColor theme;
  const PostContentText({super.key, required this.post, required this.theme});

  @override
  Widget build(BuildContext context) {
    return getTextPostContent(post);
  }

  Widget getTextPostContent(AmityPost post) {
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

    // If there is no metadata, return the text with normal style.
    if (post.metadata == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          textContent,
          style: normalStyle,
        ),
      );
    }

    // Obtain the mention metadata from the post.
    final mentionedGetter = AmityMentionMetadataGetter(metadata: post.metadata!);
    final List<AmityUserMentionMetadata> mentionedUsers = mentionedGetter.getMentionedUsers();

    // Sort mention metadata by starting index (if not already sorted).
    mentionedUsers.sort((a, b) => a.index.compareTo(b.index));

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Iterate over each mention metadata and build spans.
    for (var mention in mentionedUsers) {
      // If the mention's start index is beyond our text, skip it.
      if (mention.index >= textContent.length) continue;

      // Add text before the mention, if any.
      if (mention.index > currentIndex) {
        spans.add(TextSpan(
          text: textContent.substring(currentIndex, mention.index),
          style: normalStyle,
        ));
      }
      // Calculate the raw end index (the mention text length might include a prefix, e.g. '@')
      int rawEndIndex = mention.index + mention.length + 1;
      // Clamp the end index to the text length.
      int safeEndIndex = min(rawEndIndex, textContent.length);

      spans.add(TextSpan(
        text: textContent.substring(mention.index, safeEndIndex),
        style: mentionStyle,
      ));

      currentIndex = safeEndIndex;
    }
    // Append any remaining text after the last mention.
    if (currentIndex < textContent.length) {
      spans.add(TextSpan(
        text: textContent.substring(currentIndex),
        style: normalStyle,
      ));
    }

    // Return a RichText widget with the computed spans.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }
}