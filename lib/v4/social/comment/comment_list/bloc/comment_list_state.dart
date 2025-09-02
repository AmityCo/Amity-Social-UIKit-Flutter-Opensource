part of 'comment_list_bloc.dart';

class CommentListState extends Equatable {
  const CommentListState({
    required this.referenceId,
    required this.referenceType,
    required this.comments,
    this.isFetching = false,
    this.hasNextPage = true,
    required this.expandedId,
    this.hasError = false,
  });

  final String referenceId;
  final AmityCommentReferenceType referenceType;
  final List<AmityComment> comments;
  final bool isFetching;
  final bool hasNextPage;
  final List<String> expandedId;
  final bool hasError;

  @override
  List<Object?> get props => [
        referenceId,
        referenceType,
        comments,
        isFetching,
        hasNextPage,
        expandedId,
        hasError,
      ];

  CommentListState copyWith({
    String? referenceId,
    AmityCommentReferenceType? referenceType,
    List<AmityComment>? comments,
    bool? isFetching,
    bool? hasNextPage,
    List<String>? expandedId,
    bool? hasError,
  }) {
    return CommentListState(
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      comments: comments ?? this.comments,
      isFetching: isFetching ?? this.isFetching,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      expandedId: expandedId ?? this.expandedId,
      hasError: hasError ?? this.hasError,
    );
  }
}

class CommentListStateInitial extends CommentListState {
  const CommentListStateInitial({
    required String referenceId,
    required AmityCommentReferenceType referenceType,
  }) : super(
          referenceId: referenceId,
          referenceType: referenceType,
          comments: const [],
          isFetching: false,
          hasNextPage: true,
          expandedId: const [],
        );
}

class CommentListStateChanged extends CommentListState {
  const CommentListStateChanged({
    required String referenceId,
    required AmityCommentReferenceType referenceType,
    required List<AmityComment> comments,
    required bool isFetching,
    required bool hasNextPage,
    required List<String> expandedId,
  }) : super(
          referenceId: referenceId,
          referenceType: referenceType,
          comments: comments,
          isFetching: isFetching,
          hasNextPage: hasNextPage,
          expandedId: expandedId,
        );
}
