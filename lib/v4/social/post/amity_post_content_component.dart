import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_detail.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/post_item.dart';
import 'package:flutter/widgets.dart';

enum AmityPostContentComponentStyle { feed, detail }

enum AmityPostCategory { general, announcement, pin, announcementAndPin, globalFeatured }

class AmityPostContentComponent extends NewBaseComponent {
  final AmityPost post;
  final AmityPostContentComponentStyle style;
  final AmityPostCategory category;
  bool? hideMenu;
  final bool hideTarget;
  final AmityPostAction? action;

  AmityPostContentComponent({
    super.key,
    super.pageId,
    required this.post,
    required this.style,
    this.category = AmityPostCategory.general,
    this.hideMenu,
    this.hideTarget = false,
    super.componentId = "post_content_component",
    this.action,
  });

  @override
  Widget buildComponent(BuildContext context) {
    if (post.targetType == AmityPostTargetType.COMMUNITY) {
      final target = post.target as CommunityTarget;
      hideMenu = hideMenu ?? !(target.targetCommunity?.isJoined ?? true);
    }
    if (style == AmityPostContentComponentStyle.feed) {
      return PostItem(
        pageId: pageId,
        post: post,
        category: category,
        hideMenu: hideMenu ?? false,
        hideTarget: hideTarget,
        action: action,
      );
    } else {
      return PostDetail(
        pageId: pageId,
        post: post,
        category: category,
        hideMenu: hideMenu ?? false,
        hideTarget: hideTarget,
        action: action,
      );
    }
  }
}
