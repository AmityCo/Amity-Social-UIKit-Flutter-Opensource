import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'comment_item_events.dart';
part 'comment_item_state.dart';

class CommentItemBloc extends Bloc<CommentItemEvent, CommentItemState> {
  final AmityComment comment;
  final bool isExpanded;

  CommentItemBloc({
    required this.comment,
    required this.isExpanded,
  }) : super(CommentItemState(
      comment: comment,
      isReacting: false,
      isExpanded: isExpanded,
      isEditing: false,
      editedText: getTextComment(comment),
    )) {
    on<CommentItemLoaded>((event, emit) async {
      emit(
          state.copyWith(comment: event.comment, isExpanded: event.isExpanded));
    });

    on<CommentItemExpanded>((event, emit) async {
      emit(state.copyWith(isExpanded: true));
    });

    on<AddReactionToComment>((event, emit) async {
      AmityComment comment = event.comment;
      emit(state.copyWith(isReacting: true));
      if (comment.myReactions?.isNotEmpty ?? false) {
        await comment.react().removeReaction(comment.myReactions!.first);
      }
      await comment.react().addReaction(event.reactionType);
      var updatedComment = await AmitySocialClient.newCommentRepository()
          .getComment(commentId: event.comment.commentId!);
      emit(state.copyWith(comment: updatedComment, isReacting: false));
    });

    on<RemoveReactionToComment>((event, emit) async {
      AmityComment comment = event.comment;
      emit(state.copyWith(isReacting: true));
      if (comment.myReactions?.isNotEmpty ?? false) {
        await comment.react().removeReaction(event.reactionType);
      }
      var updatedComment = await AmitySocialClient.newCommentRepository()
          .getComment(commentId: event.comment.commentId!);
      emit(state.copyWith(comment: updatedComment, isReacting: false));
    });

    on<CommentItemEdit>((event, emit) async {
      emit(state.copyWith(isEditing: true));
    });

    on<CommentItemCancelEdit>((event, emit) async {
      emit(state.copyWith(isEditing: false));
    });

    on<CommentItemUpdate>((event, emit) async {
      emit(state.copyWith(isEditing: false));

      await AmitySocialClient.newCommentRepository()
          .updateComment(commentId: event.commentId)
          .text(event.text)
          .build()
          .update();
      emit(state.copyWith(
          comment: await AmitySocialClient.newCommentRepository()
              .getComment(commentId: event.commentId),
          isEditing: false));
    });

    on<CommentItemFlag>((event, emit) async {
      try {
        event.comment.report().flag().then((value) async {
          event.toastBloc.add(AmityToastShort(
              message:
                  "${(event.comment.parentId == null) ? "Comment" : "Reply"} reported",
              icon: AmityToastIcon.success));
          var updatedComment = await AmitySocialClient.newCommentRepository()
              .getComment(commentId: event.comment.commentId!);

          emit(state.copyWith(comment: updatedComment));
        });
      } catch (e) {
        emit(state.copyWith(isReacting: false));
      }
    });

    on<CommentItemUnFlag>((event, emit) async {
      try {
        event.comment.report().unflag().then((value) async {
          event.toastBloc.add(AmityToastShort(
              message:
                  "${(event.comment.parentId == null) ? "Comment" : "Reply"} unreported",
              icon: AmityToastIcon.success));
          var updatedComment = await AmitySocialClient.newCommentRepository()
              .getComment(commentId: event.comment.commentId!);
          emit(state.copyWith(comment: updatedComment));
        });
      } catch (e) {
        emit(state.copyWith(isReacting: false));
      }
    });

    on<CommentItemEditChanged>((event, emit) async {
      emit(state.copyWith(editedText: event.text));
    });

    on<CommentItemDelete>((event, emit) async {
      final delete = await event.comment.delete();
      if (delete) {
        if (event.comment.referenceType == AmityCommentReferenceType.POST) {
          await AmitySocialClient.newPostRepository()
              .getPost(event.comment.referenceId ?? "");
        }
        emit(CommentItemState(
            comment: event.comment,
            isReacting: false,
            isExpanded: false,
            isEditing: false,
            editedText: ""));
      }
    });
  }
}

String getTextComment(AmityComment comment) {
  return comment.data is CommentTextData
      ? (comment.data as CommentTextData).text ?? ""
      : "";
}
