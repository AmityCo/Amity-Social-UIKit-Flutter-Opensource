part of 'comment_creator_bloc.dart';

abstract class CommentCreatorEvent extends Equatable {
  const CommentCreatorEvent();

  @override
  List<Object> get props => [];
}

class CommentCreatorTextChage extends CommentCreatorEvent {
  final String text;

  const CommentCreatorTextChage({required this.text});

  @override
  List<Object> get props => [text];
}

class CommentCreatorCreated extends CommentCreatorEvent {
  final AmityCommentReferenceType referenceType;
  final String referenceId;
  final String text;
  final List<AmityMentionMetadata> mentionMetadataList;
  final List<String> mentionUserIds;
  final AmityToastBloc toastBloc;

  const CommentCreatorCreated({
    required this.referenceId,
    required this.text ,
    required this.mentionMetadataList,
    required this.mentionUserIds,
    required this.referenceType,
    required this.toastBloc});

  @override
  List<Object> get props => [referenceId, text];
}