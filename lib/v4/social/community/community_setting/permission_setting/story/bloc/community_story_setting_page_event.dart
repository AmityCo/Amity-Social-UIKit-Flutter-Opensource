part of 'community_story_setting_page_bloc.dart';

class CommunityStorySettingPageEvent extends Equatable {
  final bool isCommentEnabled;

  const CommunityStorySettingPageEvent({
    this.isCommentEnabled = false,
  });

  @override
  List<Object> get props => [isCommentEnabled];
}

class CommunityStorySettingChangedEvent extends CommunityStorySettingPageEvent {
  const CommunityStorySettingChangedEvent({bool isCommentEnabled = false})
      : super(isCommentEnabled: isCommentEnabled);

  @override
  List<Object> get props => [isCommentEnabled];
}
