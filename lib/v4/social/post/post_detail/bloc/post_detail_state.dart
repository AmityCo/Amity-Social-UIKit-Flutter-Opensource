part of 'post_detail_bloc.dart';

class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailStateInitial extends PostDetailState {
  final String postId;

  const PostDetailStateInitial({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class PostDetailStateLoaded extends PostDetailState {
  final AmityPost post;
  final AmityComment? replyTo;

  const PostDetailStateLoaded({required this.post, this.replyTo});

  @override
  List<Object?> get props => [post, replyTo];

  PostDetailStateLoaded copyWith({
    AmityPost? post,
    AmityComment? replyTo,
  }) {
    return PostDetailStateLoaded(
      post: post ?? this.post,
      replyTo: replyTo ?? this.replyTo,
    );
  }
}

class PostDetailStateError extends PostDetailState {
  final String message;

  const PostDetailStateError({required this.message});

  @override
  List<Object?> get props => [message];
}