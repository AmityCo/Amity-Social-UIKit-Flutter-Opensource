import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'amity_view_community_story_page.dart';

class AmityViewStoryPage extends StatefulWidget {
  final AmityViewStoryPageType type;
  final Function(AmityStoryTarget storytarget, AmityStoryMediaType mediaType, AmityStoryImageDisplayMode? imageMode, HyperLink? hyperlionk) createStory;
  const AmityViewStoryPage({super.key, required this.type, required this.createStory});

  @override
  State<AmityViewStoryPage> createState() => _AmityViewStoryPageState();
}

class _AmityViewStoryPageState extends State<AmityViewStoryPage> {
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type is AmityViewStoryCommunityFeed) {
      var amityViewStoryPageType = widget.type as AmityViewStoryCommunityFeed;
      return BlocProvider(
        create: (context) => ViewStoryBloc(),
        child: AmityViewCommunityStoryPage(
          communityId: '',
          targetId: amityViewStoryPageType.communityId,
          targetType: AmityStoryTargetType.COMMUNITY,
          isSingleTarget: true,
          createStory: widget.createStory,
          lastSegmentReached: () {
            Navigator.of(context).pop();
            BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
            AmityStorySingleSegmentTimerElement.currentValue = -1;
          },
        ),
      );
    } else {
      var amityViewStoryPageType = widget.type as AmityViewStoryPageType;
      return Container();
    }
  }
}
