part of 'comment_item_bloc.dart';

abstract class CommentItemEvent extends Equatable {
  const CommentItemEvent();

  @override
  List<Object> get props => [];
}

class AddReactionToComment extends CommentItemEvent {
  final AmityComment comment;
  final String reactionType;

  const AddReactionToComment(
      {required this.comment, required this.reactionType});

  @override
  List<Object> get props => [comment, reactionType];
}

class RemoveReactionToComment extends CommentItemEvent {
  final AmityComment comment;
  final String reactionType;

  const RemoveReactionToComment(
      {required this.comment, required this.reactionType});

  @override
  List<Object> get props => [comment, reactionType];
}

class CommentItemLoaded extends CommentItemEvent {
  final AmityComment comment;
  final bool isExpanded;

  const CommentItemLoaded({required this.comment, required this.isExpanded});

  @override
  List<Object> get props => [comment, isExpanded];
}

class CommentItemExpanded extends CommentItemEvent {}

class CommentItemFlag extends CommentItemEvent {
  final AmityComment comment;
  final AmityToastBloc toastBloc;

  const CommentItemFlag({required this.comment, required this.toastBloc});
}

class CommentItemUnFlag extends CommentItemEvent {
  final AmityComment comment;
  final AmityToastBloc toastBloc;

  const CommentItemUnFlag({required this.comment, required this.toastBloc});
}

class CommentItemEdit extends CommentItemEvent {}

class CommentItemCancelEdit extends CommentItemEvent {}

class CommentItemEditChanged extends CommentItemEvent {
  final String text;

  const CommentItemEditChanged({required this.text});
}

class CommentItemUpdate extends CommentItemEvent {
  final String commentId;
  final String text;

  const CommentItemUpdate({required this.commentId, required this.text});
}

class CommentItemDelete extends CommentItemEvent {
  final AmityComment comment;

  const CommentItemDelete({required this.comment});
}
