part of 'story_draft_bloc.dart';

abstract class StoryDraftState extends Equatable {
  AmityStoryTarget? storyTarget;
  HyperLink? hyperlink;
  AmityStoryImageDisplayMode imageDisplayMode = AmityStoryImageDisplayMode.FILL;
}

class StoryDraftInitial extends StoryDraftState {
  @override
  List<Object?> get props => [storyTarget, hyperlink, imageDisplayMode];
}

class LoadingState extends StoryDraftState {
  @override
  List<Object?> get props => [storyTarget, hyperlink, imageDisplayMode];
}

class HyperlinkAddedState extends StoryDraftState {
  HyperlinkAddedState();
  @override
  List<Object?> get props => [storyTarget, hyperlink, imageDisplayMode];
}


class FitFillToggleState extends StoryDraftState {
  FitFillToggleState();
  @override
  List<Object?> get props => [storyTarget, hyperlink, imageDisplayMode];
}

class StoryPostedState extends StoryDraftState {
  @override
  List<Object?> get props => [storyTarget, hyperlink, imageDisplayMode];
}

