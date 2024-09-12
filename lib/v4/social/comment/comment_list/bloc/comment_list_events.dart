part of 'comment_list_bloc.dart';

abstract class CommentListEvent extends Equatable {
  const CommentListEvent();

  @override
  List<Object> get props => [];
}

class CommentListEventRefresh extends CommentListEvent {
  final AmityToastBloc toastBloc;

  const CommentListEventRefresh({required this.toastBloc});
}

class CommentListEventLoadMore extends CommentListEvent {
  final AmityToastBloc toastBloc;

  const CommentListEventLoadMore({required this.toastBloc});}

class CommentListEventDisposed extends CommentListEvent {}

class CommentListEventChanged extends CommentListEvent {

  final List<AmityComment> comments;
  final bool isFetching;

  const CommentListEventChanged({required this.comments, required this.isFetching});

  @override
  List<Object> get props => [comments, isFetching];
}

class CommentListEventLoadingStateUpdated extends CommentListEvent {
  final bool isFetching;

  const CommentListEventLoadingStateUpdated({required this.isFetching});

  @override
  List<Object> get props => [isFetching];
}

class CommentListEventExpandItem extends CommentListEvent {
  final String commentId;

  const CommentListEventExpandItem({required this.commentId});
}