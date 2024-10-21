part of 'story_draft_bloc.dart';

abstract class StoryDraftEvent {}

class ObserveStoryTargetEvent extends StoryDraftEvent {
  String communityId;
  AmityStoryTargetType targetType;
  ObserveStoryTargetEvent({required this.communityId , required this.targetType});
}

class NewStoryTargetEvent extends StoryDraftEvent {
  AmityStoryTarget storyTarget;
  NewStoryTargetEvent({required this.storyTarget});
}


class OnHyperlinkAddedEvent extends StoryDraftEvent {
  HyperLink hyperlink;
  OnHyperlinkAddedEvent({required this.hyperlink});
}


class OnHyperlinkRemovedEvent extends StoryDraftEvent {
  
}

class OnPostImageStoryEvent extends StoryDraftEvent {
  File imageFile;
  AmityStoryImageDisplayMode imageDisplayMode;
  HyperLink? hyperlink;
  OnPostImageStoryEvent({required this.imageFile, required this.imageDisplayMode , this.hyperlink});
}

class OnPostVideoStoryEvent extends StoryDraftEvent {
  File videoFile;
  HyperLink? hyperlink;
  OnPostVideoStoryEvent({required this.videoFile,  this.hyperlink});
}


class DraftLoadingEvent extends StoryDraftEvent {
  DraftLoadingEvent();
}


class FillFitToggleEvent extends StoryDraftEvent {
  AmityStoryImageDisplayMode imageDisplayMode;
  FillFitToggleEvent({required this.imageDisplayMode});
}


class OnStoryPostedEvent extends StoryDraftEvent {
  OnStoryPostedEvent();
}