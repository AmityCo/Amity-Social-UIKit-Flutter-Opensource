part of 'post_item_bloc.dart';

class PostItemState extends Equatable {
  const PostItemState();

  @override
  List<Object?> get props => [];
}

class PostItemStateInitial extends PostItemState {}

class PostItemStateLoaded extends PostItemState {
  final AmityPost post;

  const PostItemStateLoaded({required this.post});

  @override
  List<Object?> get props => [post];
}

class PostItemStateDeleted extends PostItemState {
  final AmityPost post;

  const PostItemStateDeleted({required this.post});

  @override
  List<Object?> get props => [post];
}

class PostItemStateReacting extends PostItemState {
  final AmityPost post;

  const PostItemStateReacting({required this.post});

  @override
  List<Object?> get props => [post];
}