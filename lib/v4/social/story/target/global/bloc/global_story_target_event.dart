part of 'global_story_target_bloc.dart';

abstract class GlobalStoryTargetEvent extends Equatable {
  const GlobalStoryTargetEvent();

  @override
  List<Object> get props => [];
}

class ObserverGlobalStoryTarget extends GlobalStoryTargetEvent {}


class LoadNextTargetStoriesEvent extends GlobalStoryTargetEvent {}

class GlobalStoryTargetsFetched extends GlobalStoryTargetEvent {
  final List<AmityStoryTarget> storyTargets;
  const GlobalStoryTargetsFetched(this.storyTargets);

  @override
  List<Object> get props => [storyTargets];
}