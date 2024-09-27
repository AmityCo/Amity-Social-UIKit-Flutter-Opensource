import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_content_text.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_header.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_detail_info.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/bloc/post_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/post_item_bottom.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetail extends NewBaseComponent {
  final AmityPost post;
  final AmityPostAction? action;

  PostDetail({
    super.key,
    super.pageId,
    super.componentId = "post_detail",
    required this.post,
    this.action,
  });

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<PostItemBloc, PostItemState>(builder: (context, state) {
      onAddReaction(reactionType) {
        context.read<PostItemBloc>().add(AddReactionToPost(
            post: post, reactionType: reactionType, action: action));
      }

      onRemoveReaction(reactionType) {
        context.read<PostItemBloc>().add(RemoveReactionToPost(
            post: post, reactionType: reactionType, action: action));
      }

      var postAction = (action != null)
          ? action!.copyWith(
              onAddReaction: onAddReaction, onRemoveReaction: onRemoveReaction)
          : AmityPostAction(
              onAddReaction: onAddReaction,
              onRemoveReaction: onRemoveReaction,
              onPostDeleted: (_) {},
              onPostUpdated: (_) {});
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmityPostHeader(
            post: post,
            theme: theme,
          ),
          PostContentText(
            post: post,
            theme: theme,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PostChildrenContent(post: post),
          ),
          PostDetailInfo(post: post, componentId: ''),
          PostItemBottom(
            post: post,
            action: postAction,
            isReacting: state is PostItemStateReacting,
            hideReactionCount: true,
            componentId: '',
            isOptimisticUi: false,
          ),
        ],
      );
    });
  }
}
