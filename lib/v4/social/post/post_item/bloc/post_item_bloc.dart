import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_item_events.dart';
part 'post_item_state.dart';

class PostItemBloc extends Bloc<PostItemEvent, PostItemState> {
  AmityPost post;
  BuildContext context;

  PostItemBloc(this.context, this.post) : super(PostItemState(post: post)) {
    on<PostItemLoading>((event, emit) async {
      var post =
          await AmitySocialClient.newPostRepository().getPost(event.postId);
      emit(state.copyWith(post: post));
    });

    on<PostItemReacted>((event, emit) async {
      emit(state.copyWith(isReacting: false));
    });

    on<AddReactionToPost>((event, emit) async {
      AmityPost post = event.post;
      emit(state.copyWith(isReacting: true));
      if (post.myReactions?.isNotEmpty ?? false) {
        await post.react().removeReaction(post.myReactions!.first);
      }
      await post.react().addReaction(event.reactionType);
      emit(state.copyWith(isReacting: false));
    });

    on<RemoveReactionToPost>((event, emit) async {
      AmityPost post = event.post;
      emit(state.copyWith(isReacting: true));
      if (post.myReactions?.isNotEmpty ?? false) {
        await post.react().removeReaction(event.reactionType);
      }
      emit(state.copyWith(isReacting: false));
    });

    on<PostItemFlag>((event, emit) async {
      final flag = await event.post.report().flag();
      if (flag) {
        event.toastBloc.add(AmityToastShort(
            message: context.l10n.post_reported, icon: AmityToastIcon.success));
        var updatedPost = await AmitySocialClient.newPostRepository()
            .getPost(event.post.postId!);
        emit(state.copyWith(post: updatedPost));
      }
    });

    on<PostItemUnFlag>((event, emit) async {
      final flag = await event.post.report().unflag();
      if (flag) {
        event.toastBloc.add(AmityToastShort(
            message: context.l10n.post_unreported,
            icon: AmityToastIcon.success));
        var updatedPost = await AmitySocialClient.newPostRepository()
            .getPost(event.post.postId!);
        emit(state.copyWith(post: updatedPost));
      }
    });

    on<PostItemDelete>((event, emit) async {
        event.action?.onPostDeleted(event.post);
        var updatedPost = event.post;
        updatedPost.isDeleted = true;
        emit(state.copyWith(post: updatedPost));

    });

    on<PostItemLoaded>((event, emit) async {
      AmityPost post = event.post;
      emit(state.copyWith(post: post));
    });
  }
}
