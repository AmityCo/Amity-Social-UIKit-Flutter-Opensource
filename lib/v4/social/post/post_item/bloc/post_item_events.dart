part of 'post_item_bloc.dart';

abstract class PostItemEvent extends Equatable {
  const PostItemEvent();

  @override
  List<Object> get props => [];
}

class PostItemLoading extends PostItemEvent {
  final String postId;

  const PostItemLoading({required this.postId});

  @override
  List<Object> get props => [postId];
}

class AddReactionToPost extends PostItemEvent {
  final AmityPost post;
  final String reactionType;
  final AmityPostAction? action;

  const AddReactionToPost(
      {required this.post, required this.reactionType, this.action});

  @override
  List<Object> get props => [post, reactionType];
}

class RemoveReactionToPost extends PostItemEvent {
  final AmityPost post;
  final String reactionType;
  final AmityPostAction? action;

  const RemoveReactionToPost(
      {required this.post, required this.reactionType, this.action});

  @override
  List<Object> get props => [post, reactionType];
}

class PostItemLoaded extends PostItemEvent {
  final AmityPost post;

  const PostItemLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

class PostItemFlag extends PostItemEvent {
  final AmityPost post;
  final AmityToastBloc toastBloc;

  const PostItemFlag({required this.post, required this.toastBloc});
}

class PostItemUnFlag extends PostItemEvent {
  final AmityPost post;
  final AmityToastBloc toastBloc;

  const PostItemUnFlag({required this.post, required this.toastBloc});
}

class PostItemDelete extends PostItemEvent {
  final AmityPost post;
  final AmityPostAction? action;

  const PostItemDelete({required this.post, this.action});
}
