import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/bloc/comment_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_item.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/bloc/comment_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReplyList extends NewBaseComponent with ChangeNotifier {
  final ScrollController scrollController;
  final bool shouldAllowInteraction;

  ReplyList({
    Key? key,
    String? pageId,
    required this.shouldAllowInteraction,
    required this.scrollController,
  }) : super(key: key, pageId: pageId, componentId: "comment_list_component");

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<CommentListBloc, CommentListState>(
      builder: (context, state) {
        if (state is CommentListStateInitial) {
          context.read<CommentListBloc>().add(CommentListEventRefresh(
              toastBloc: context.read<AmityToastBloc>()));
        }
        if (state.isFetching && state.comments.isEmpty) {
          return Center(
            child: SizedBox(
              width: double.infinity,
              child: Shimmer(
                linearGradient: configProvider.getShimmerGradient(),
                child: const ShimmerLoading(
                  isLoading: true,
                  child: CommentSkeleton(),
                ),
              ),
            ),
          );
        } else {
          scrollController.addListener(() {
            if ((scrollController.position.pixels ==
                (scrollController.position.maxScrollExtent))) {
              context.read<CommentListBloc>().add(CommentListEventLoadMore(
                  toastBloc: context.read<AmityToastBloc>()));
            }
          });
          return ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: state.comments.length,
            itemBuilder: (context, index) {
              final comment = state.comments[index];
              return BlocProvider(
                key: ValueKey(
                    "${comment.commentId}_${comment.childrenNumber}}_${comment.isFlaggedByMe}"),
                create: (context) => CommentItemBloc(
                  context: context,
                  comment: comment,
                  isExpanded: false,
                ),
                child: CommentItem(
                  shouldAllowInteraction: shouldAllowInteraction,
                  parentScrollController: scrollController,
                  commentAction: CommentAction(
                    onReply: (commentId) => {},
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
