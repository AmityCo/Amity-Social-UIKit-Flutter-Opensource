part of 'global_story_target_bloc.dart';

abstract class GlobalStoryTargetState extends Equatable {
  const GlobalStoryTargetState();
  
  @override
  List<Object> get props => [];
}

class GlobalStoryTargetInitial extends GlobalStoryTargetState {}


class GlobalStoryTargetFetchingState extends GlobalStoryTargetState {}
  
class GlobalStoryTargetFetchedState extends GlobalStoryTargetState {
  final List<AmityStoryTarget> storyTargets;
  const GlobalStoryTargetFetchedState({required this.storyTargets});

  @override 
  List<Object> get props => [storyTargets];
}
