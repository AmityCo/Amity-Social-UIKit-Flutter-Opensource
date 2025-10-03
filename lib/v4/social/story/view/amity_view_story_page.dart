import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_global_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'amity_view_community_story_page.dart';

class AmityViewStoryPage extends NewBasePage {
  final AmityViewStoryPageType type;
  final List<AmityStoryTarget>? targets;
  final AmityStoryTarget? selectedTarget;

  AmityViewStoryPage({
    Key? key,
    required this.type,
    this.targets,
    this.selectedTarget,
  }) : super(key: key, pageId: 'story_page');

  @override
  Widget buildPage(BuildContext context) {
    if (type is AmityViewStoryCommunityFeed) {
      var amityViewStoryPageType = type as AmityViewStoryCommunityFeed;
      return BlocProvider(
        create: (context) => ViewStoryBloc(),
        child: AmityViewCommunityStoryPage(
          communityId: '',
          targetId: amityViewStoryPageType.communityId,
          targetType: AmityStoryTargetType.COMMUNITY,
          isSingleTarget: true,
          theme: theme,
          // createStory: widget.createStory,
          lastSegmentReached: () {
            Navigator.of(context).pop();
            BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
            AmityStorySingleSegmentTimerElement.currentValue = -1;
          },
        ),
      );
    } else if (type is AmityViewStoryGlobalFeed) {
      // var amityViewStoryPageType = type as AmityViewStoryGlobalFeed;
      return AmityViewGlobalStoryPage(
        selectedTarget: selectedTarget!,
        targets: targets!,
        theme: theme,
        // createStory: widget.createStory,
      );
    }
    return const SizedBox();
  }
}
