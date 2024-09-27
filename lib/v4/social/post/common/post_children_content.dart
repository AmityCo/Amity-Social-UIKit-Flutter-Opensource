import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_image.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_video.dart';
import 'package:flutter/material.dart';

class PostChildrenContent extends StatelessWidget {
  final AmityPost post;

  const PostChildrenContent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final noChildrenPost = post.children?.isEmpty ?? true;
    if (noChildrenPost) {
      return Container();
    } else if (post.children!.first.data is ImageData) {
      return PostContentImage(posts: post.children!);
    } else if (post.children!.first.data is VideoData) {
      return PostContentVideo(posts: post.children!);
    } else {
      return Container();
    }
  }
}
