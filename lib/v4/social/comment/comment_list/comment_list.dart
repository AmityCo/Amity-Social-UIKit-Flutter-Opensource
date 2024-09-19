import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/bloc/comment_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_item.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/bloc/comment_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentList extends NewBaseComponent with ChangeNotifier {
  final ScrollController scrollController;
  final CommentAction commentAction;
  final bool shouldAllowInteraction;

  CommentList({
    Key? key,
    String? pageId,
    required this.shouldAllowInteraction,
    required this.scrollController,
    required this.commentAction,
  }) : super(key: key, pageId: pageId, componentId: "comment_list_component");

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<CommentListBloc, CommentListState>(
      builder: (context, state) {
        final commentCount = state.comments.length;
        if (state is CommentListStateInitial) {
          context.read<CommentListBloc>().add(CommentListEventRefresh(
              toastBloc: context.read<AmityToastBloc>()));
        }
        if (state.isFetching && state.comments.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SizedBox(
                  width: double.infinity,
                  child: Shimmer(
                    linearGradient: configProvider.getShimmerGradient(),
                    child: const ShimmerLoading(
                      isLoading: true,
                      child: CommentSkeleton(),
                    ),
                  ),
                );
              },
              childCount: 3,
            ),
          );
        } else if (!state.isFetching && state.comments.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(),
          );
        } else {
          scrollController.addListener(() {
            if ((scrollController.position.pixels ==
                (scrollController.position.maxScrollExtent))) {
              context.read<CommentListBloc>().add(CommentListEventLoadMore(
                  toastBloc: context.read<AmityToastBloc>()));
            }
          });
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.comments.length) {
                  final comment = state.comments[index];
                  final isExpanded =
                      state.expandedId.contains(comment.commentId);
                  return BlocProvider(
                    key: ValueKey(
                        "${comment.commentId}_${isExpanded}_${comment.childrenNumber}_${comment.isFlaggedByMe}"),
                    create: (context) => CommentItemBloc(
                      comment: comment,
                      isExpanded: isExpanded,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: CommentItem(
                        shouldAllowInteraction: shouldAllowInteraction,
                        parentScrollController: scrollController,
                        commentAction: commentAction,
                      ),
                    ),
                  );
                } else {
                  return state.isFetching && state.comments.isNotEmpty
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: theme.primaryColor,
                            ),
                          ),
                        )
                      : Container();
                }
              },
              // Add 1 more item to show loading indicator
              childCount: (commentCount > 0) ? commentCount + 1 : commentCount,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
