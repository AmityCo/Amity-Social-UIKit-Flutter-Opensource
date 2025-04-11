import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/single_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class UserImageFeedElement extends BaseElement {
  final AmityPost post;
  final AmityThemeColor theme;

  UserImageFeedElement({super.key, required this.post, required this.theme})
      : super(elementId: "");

  @override
  Widget buildElement(BuildContext context) {
    final imageUrl = (post.data as ImageData).getUrl(AmityImageSize.MEDIUM);

    return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleImagePostViewer(
                  post: post,
                  theme: theme
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.baseColorShade4,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }
}
