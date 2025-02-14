import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_image.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_video.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_poll.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../amity_post_content_component.dart';

class PostChildrenContent extends StatelessWidget {
  final AmityPost post;
  final AmityPostContentComponentStyle style;
  final bool hideMenu;
  final AmityThemeColor theme;

  const PostChildrenContent({super.key, required this.post, required this.style, required this.hideMenu, required this.theme});

  @override
  Widget build(BuildContext context) {
    final noChildrenPost = post.children?.isEmpty ?? true;
    if(noChildrenPost) {
      return Container();
    } else if (post.children!.first.data is ImageData) {
      return PostContentImage(posts: post.children!);
    } else if (post.children!.first.data is VideoData) {
      return PostContentVideo(posts: post.children!);
    } else if (post.children!.first.data is PollData) {
      return PostPollContent(post: post.children!.first, style: style, theme: theme, hideMenu: hideMenu, goToDetail: (){},);
    } else {
      return Container();
    }
  }
}