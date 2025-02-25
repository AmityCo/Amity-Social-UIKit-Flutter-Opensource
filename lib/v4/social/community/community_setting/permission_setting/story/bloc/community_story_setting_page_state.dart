part of 'community_story_setting_page_bloc.dart';

class CommunityStorySettingPageState extends Equatable {
  final bool isCommentEnabled;

  const CommunityStorySettingPageState({
    this.isCommentEnabled = false,
  });

  CommunityStorySettingPageState copyWith({
    bool? isCommentEnabled,
  }) {
    return CommunityStorySettingPageState(
      isCommentEnabled: isCommentEnabled ?? this.isCommentEnabled,
    );
  }

  @override
  List<Object> get props => [isCommentEnabled];
}
