part of 'post_item_bloc.dart';

class PostItemState extends Equatable {
  final AmityPost post;
  final bool isReacting;

  const PostItemState({required this.post, this.isReacting = false});

  @override
  List<Object?> get props => [post, isReacting];

  PostItemState copyWith({AmityPost? post, bool? isReacting}) {
    return PostItemState(
      post: post ?? this.post,
      isReacting: isReacting ?? this.isReacting,
    );
  }
}