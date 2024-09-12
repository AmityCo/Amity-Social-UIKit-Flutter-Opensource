part of 'create_story_bloc.dart';

abstract class CreateStoryEvent extends Equatable {
  const CreateStoryEvent();

  @override
  List<Object> get props => [];
}


class CreateStory extends CreateStoryEvent {
  String targetId;
  AmityStoryTargetType targetType;
  AmityStoryMediaType mediaType;
  AmityStoryImageDisplayMode? imageMode;
  HyperLink? hyperlink;

  CreateStory({
    required this.targetId,
    required this.targetType,
    required this.mediaType,
    this.imageMode,
    this.hyperlink,
  });
}

class CreateStorySuccessEvent extends CreateStoryEvent {}

class CreateStoryFailEvent extends CreateStoryEvent {}