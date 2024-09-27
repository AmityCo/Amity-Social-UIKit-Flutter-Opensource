part of 'comment_item_bloc.dart';

class CommentItemState {
  const CommentItemState({
    required this.comment,
    required this.isReacting,
    required this.isExpanded,
    required this.isEditing,
  });

  final AmityComment comment;
  final bool isReacting;
  final bool isExpanded;
  final bool isEditing;

  @override
  List<Object?> get props => [comment, isReacting, isExpanded, isEditing];

  CommentItemState copyWith({
    AmityComment? comment,
    bool? isReacting,
    bool? isExpanded,
    bool? isEditing,
  }) {
    return CommentItemState(
      comment: comment ?? this.comment,
      isReacting: isReacting ?? this.isReacting,
      isExpanded: isExpanded ?? this.isExpanded,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}
