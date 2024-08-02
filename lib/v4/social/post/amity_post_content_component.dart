import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_detail.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/post_item.dart';
import 'package:flutter/widgets.dart';

enum AmityPostContentComponentStyle { feed, detail }

class AmityPostContentComponent extends NewBaseComponent {
  final AmityPost post;
  final AmityPostContentComponentStyle style;
  final AmityPostAction? action;

  AmityPostContentComponent({
    super.key,
    super.pageId,
    required this.post,
    required this.style,
    super.componentId = "post_content_component",
    this.action,
  });

  @override
  Widget buildComponent(BuildContext context) {
    if (style == AmityPostContentComponentStyle.feed) {
      return PostItem(pageId: pageId, post: post, action: action);
    } else {
      return PostDetail(pageId: pageId, post: post, action: action);
    }
  }
}
