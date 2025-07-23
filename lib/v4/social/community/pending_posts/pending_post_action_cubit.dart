import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_posts_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// States for the pending post actions
class PendingPostActionState extends Equatable {
  final bool isApprovingPost;
  final bool isDecliningPost;
  final bool isLoadingPost;
  final bool isDeletingPost;
  final bool isModerator;
  final AmityPost post;
  final String? error;

  const PendingPostActionState({
    this.isApprovingPost = false,
    this.isDecliningPost = false,
    this.isLoadingPost = false,
    this.isDeletingPost = false,
    this.isModerator = false,
    required this.post,
    this.error,
  });

  PendingPostActionState copyWith({
    bool? isApprovingPost,
    bool? isDecliningPost,
    bool? isLoadingPost,
    bool? isDeletingPost,
    bool? isModerator,
    AmityPost? post,
    String? error,
  }) {
    return PendingPostActionState(
      isApprovingPost: isApprovingPost ?? this.isApprovingPost,
      isDecliningPost: isDecliningPost ?? this.isDecliningPost,
      isLoadingPost: isLoadingPost ?? this.isLoadingPost,
      isDeletingPost: isDeletingPost ?? this.isDeletingPost,
      isModerator: isModerator ?? this.isModerator,
      post: post ?? this.post,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isApprovingPost,
        isDecliningPost,
        isLoadingPost,
        isDeletingPost,
        isModerator,
        post,
        error
      ];
}

// Cubit to manage the approve and decline actions
class PendingPostActionCubit extends Cubit<PendingPostActionState> {
  final PendingPostsCubit parentCubit;
  final BuildContext context;
  final AmityThemeColor theme;
  final AmityToastBloc toastBloc;

  PendingPostActionCubit({
    required AmityPost post,
    required this.parentCubit,
    required this.context,
    required this.theme,
    required this.toastBloc,
    bool isModerator = false, // Accept isModerator from component
  }) : super(PendingPostActionState(
          post: post,
          isLoadingPost: true,
        )) {
    // Check if the user is a moderator from post data or the provided value
    bool isModeratorFromRoles = false;

    if (post.target is CommunityTarget) {
      var roles = (post.target as CommunityTarget).postedCommunityMember?.roles;
      if (roles != null &&
          (roles.contains("moderator") ||
              roles.contains("community-moderator"))) {
        isModeratorFromRoles = true;
      }
    }

    // Immediately update the state with the final moderator status
    emit(state.copyWith(
      isModerator: isModerator || isModeratorFromRoles,
      isLoadingPost: false,
    ));
  }

  Future<void> approvePost() async {
    if (state.isApprovingPost) return;

    emit(state.copyWith(isApprovingPost: true, error: null));

    try {
      // Approve post
      await AmitySocialClient.newPostRepository()
          .reviewPost(postId: state.post.postId!)
          .approve();

      toastBloc.add(
        const AmityToastShort(
          message: 'Post accepted.',
          icon: AmityToastIcon.success,
        ),
      );

      parentCubit.handlePostAction(state.post.postId!, true);

      emit(state.copyWith(isApprovingPost: false));
    } catch (error) {
      toastBloc.add(
        const AmityToastShort(
          message:
              'Failed to accept post. This post has been reviewed by another moderator.',
          icon: AmityToastIcon.warning,
        ),
      );

      parentCubit.handlePostAction(state.post.postId!, false);

      emit(state.copyWith(
        isApprovingPost: false,
        error: error.toString(),
      ));
    }
  }

  Future<void> declinePost() async {
    if (state.isDecliningPost) return;

    emit(state.copyWith(isDecliningPost: true, error: null));

    try {
      await AmitySocialClient.newPostRepository()
          .reviewPost(postId: state.post.postId!)
          .decline();

      toastBloc.add(
        const AmityToastShort(
          message: 'Post declined.',
          icon: AmityToastIcon.warning,
        ),
      );

      parentCubit.handlePostAction(state.post.postId!, true);

      emit(state.copyWith(isDecliningPost: false));
    } catch (error) {
      toastBloc.add(
        const AmityToastShort(
          message:
              'Failed to decline post. This post has been reviewed by another moderator.',
          icon: AmityToastIcon.warning,
        ),
      );
      parentCubit.handlePostAction(state.post.postId!, false);

      emit(state.copyWith(
        isDecliningPost: false,
        error: error.toString(),
      ));
    }
  }

  void refreshPost() {
    emit(state.copyWith(isLoadingPost: true));
    emit(state.copyWith(isLoadingPost: false));
  }

  Future<void> deletePost() async {
    if (state.isDeletingPost) return;

    emit(state.copyWith(isDeletingPost: true, error: null));

    try {
      await AmitySocialClient.newPostRepository()
          .deletePost(postId: state.post.postId!);

      toastBloc.add(
        const AmityToastShort(
          message: 'Post deleted successfully',
          icon: AmityToastIcon.success,
        ),
      );

      // Update parent cubit to refresh the list
      parentCubit.handlePostAction(state.post.postId!, true);

      // Keep current post in state
      emit(state.copyWith(isDeletingPost: false));
    } catch (error) {
      toastBloc.add(
        AmityToastShort(
          message: 'Failed to delete post: $error',
          icon: AmityToastIcon.warning,
        ),
      );

      // Update state with error
      emit(state.copyWith(
        isDeletingPost: false,
        error: error.toString(),
      ));
    }
  }
}
