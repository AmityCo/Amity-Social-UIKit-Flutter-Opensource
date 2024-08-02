part of 'view_story_bloc.dart';

class ViewStoryState extends Equatable {
  final AmityCommunity? community;
  final List<AmityStory>? stories;
  final AmityStory? currentStory;
  final AmityStoryTarget? storyTarget;
  final bool? isCommunityJoined;
  final bool hasManageStoryPermission;
  final bool? shouldPause;
  final int jumpToUnSeen;

  const ViewStoryState({
    required this.community,
    required this.stories,
    required this.currentStory,
    required this.isCommunityJoined,
    required this.storyTarget,
    required this.shouldPause,
    required this.jumpToUnSeen,
    required this.hasManageStoryPermission,
  });

  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class ViewStoryInitial extends ViewStoryState {
  const ViewStoryInitial({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.shouldPause,
    required super.jumpToUnSeen,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class LoadingState extends ViewStoryState {
  const LoadingState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.jumpToUnSeen,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });

  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class ViewStoryTargetFetched extends ViewStoryState {
  const ViewStoryTargetFetched({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.shouldPause,
    required super.jumpToUnSeen,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class NewCurrentStoryState extends ViewStoryState {
  const NewCurrentStoryState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.jumpToUnSeen,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class ManagerStoryPermissionFetchedState extends ViewStoryState {
  const ManagerStoryPermissionFetchedState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.shouldPause,
    required super.jumpToUnSeen,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class ActiveStoriesFetchedState extends ViewStoryState {
  Random random = Random();
  ActiveStoriesFetchedState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.shouldPause,
    required super.jumpToUnSeen,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
        random.nextInt(1000),
      ];
}

class StoryDeletedState extends ViewStoryState {
  const StoryDeletedState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.jumpToUnSeen,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
      ];
}

class ShouldPauseState extends ViewStoryState {
  Random random = Random();
   ShouldPauseState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.jumpToUnSeen,
    required super.storyTarget,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
        shouldPause ?? "",
        random.nextInt(1000),
      ];
}


class TryingReuploadingState extends ViewStoryState {

   const TryingReuploadingState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.jumpToUnSeen,
    required super.storyTarget,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
        shouldPause ?? "",
      ];
}

class JumpToUnSeenState extends ViewStoryState {
  const JumpToUnSeenState({
    required super.community,
    required super.stories,
    required super.currentStory,
    required super.isCommunityJoined,
    required super.storyTarget,
    required super.jumpToUnSeen,
    required super.shouldPause,
    required super.hasManageStoryPermission,
  });
  @override
  List<Object> get props => [
        stories ?? [],
        currentStory ?? "",
        community ?? "",
        isCommunityJoined ?? "",
        storyTarget ?? "",
        shouldPause ?? "",
      ];
}

