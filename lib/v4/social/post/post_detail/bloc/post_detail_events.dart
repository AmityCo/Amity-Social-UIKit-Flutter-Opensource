part of 'post_detail_bloc.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

class PostDetailLoad extends PostDetailEvent {
  final String postId;

  const PostDetailLoad({required this.postId});

  @override
  List<Object> get props => [postId];
}

class PostDetailLoaded extends PostDetailEvent {
  final AmityPost post;

  const PostDetailLoaded({required this.post});

  @override
  List<Object> get props => [post];
}

class PostDetailReplyComment extends PostDetailEvent {
  final AmityComment? replyTo;

  const PostDetailReplyComment({required this.replyTo});

  @override
  List<Object> get props => [];
}

class PostDetailError extends PostDetailEvent {
  final String message;

  const PostDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
