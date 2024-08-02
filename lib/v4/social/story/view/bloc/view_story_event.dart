part of 'view_story_bloc.dart';

class ViewStoryEvent extends Equatable {
  const ViewStoryEvent();

  @override
  List<Object> get props => [];
}

class ViewStoryFetchDataEvent extends ViewStoryEvent {
  final String targetId;
  final AmityStoryTargetType targetType;
  const ViewStoryFetchDataEvent({required this.targetId, required this.targetType});

  @override
  List<Object> get props => [];
}

class FetchStoryTarget extends ViewStoryEvent {
  final String communityId;
  const FetchStoryTarget({required this.communityId});
  @override
  List<Object> get props => [communityId];
}

class NewCurrentStory extends ViewStoryEvent {
  final AmityStory currentStroy;
  const NewCurrentStory({required this.currentStroy});
  @override
  List<Object> get props => [currentStroy];
}

class StoryTargetFetched extends ViewStoryEvent {
  final AmityStoryTarget storyTarget;
  const StoryTargetFetched({required this.storyTarget});
  @override
  List<Object> get props => [storyTarget];
}

class JumpToUnSeen extends ViewStoryEvent {
  final int jumpToPosition;
  const JumpToUnSeen({required this.jumpToPosition});
}

class FetchActiveStories extends ViewStoryEvent {
  final String communityId;
  const FetchActiveStories({required this.communityId});
  @override
  List<Object> get props => [communityId];
}

class DeleteStoryEvent extends ViewStoryEvent {
  final String storyId;
  const DeleteStoryEvent({required this.storyId});
  @override
  List<Object> get props => [storyId];
}

class ShoudPauseEvent extends ViewStoryEvent {
  final bool shouldPause;
  Random rand = Random();
  ShoudPauseEvent({required this.shouldPause});
  @override
  List<Object> get props => [shouldPause, rand.nextInt(1000)];
}

class StoryDeletedEvent extends ViewStoryEvent {
  const StoryDeletedEvent();
  @override
  List<Object> get props => [];
}

class SegmentTimerEvent extends ViewStoryEvent {
  final bool shouldPuase;
  const SegmentTimerEvent({required this.shouldPuase});
  @override
  List<Object> get props => [shouldPuase];
}

class StoryRetryEvent extends ViewStoryEvent {
  final AmityStory amityStory;
  const StoryRetryEvent({required this.amityStory, required String storyId});
  @override
  List<Object> get props => [amityStory];
}

class FetchManageStoryPermission extends ViewStoryEvent {
  final String communityId;
  const FetchManageStoryPermission({required this.communityId});
  @override
  List<Object> get props => [communityId];
}

class MarkStoryAsViewedEvent extends ViewStoryEvent {
  final AmityStory story;
  const MarkStoryAsViewedEvent({required this.story});
  @override
  List<Object> get props => [story];
}

class MarkStoryLinkAsClickedEvent extends ViewStoryEvent {
  final AmityStory story;
  const MarkStoryLinkAsClickedEvent({required this.story});
  @override
  List<Object> get props => [story];
}

class AddReactionEvent extends ViewStoryEvent {
  final String storyId;
  const AddReactionEvent({required this.storyId});
  @override
  List<Object> get props => [storyId];
}

class RemoveReactionEvent extends ViewStoryEvent {
  final String storyId;
  const RemoveReactionEvent({required this.storyId});
  @override
  List<Object> get props => [storyId];
}

// class SubscribeToStoryTarget extends ViewStoryEvent {
//   final AmityStory story;
//   const MarkStoryLinkAsClickedEvent({required this.story});
//   @override
//   List<Object> get props => [story];
// }

class ManageStoryPermissionFetched extends ViewStoryEvent {
  final bool hasManageStoryPermission;
  const ManageStoryPermissionFetched({required this.hasManageStoryPermission});
  @override
  List<Object> get props => [hasManageStoryPermission];
}

class ActiveStoriesFetched extends ViewStoryEvent {
  final List<AmityStory> stories;
  const ActiveStoriesFetched({required this.stories});
  @override
  List<Object> get props => [stories];
}
