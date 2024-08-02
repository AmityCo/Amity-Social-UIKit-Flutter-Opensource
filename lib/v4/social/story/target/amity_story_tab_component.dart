import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/community/amity_story_community_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/community/bloc/community_feed_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityStoryTabComponent extends StatelessWidget {
  final AmityStoryTabComponentType type;
  final Function (AmityStoryTarget  storytarget, AmityStoryMediaType mediaType , AmityStoryImageDisplayMode? imageMode , HyperLink? hyperlionk) createStory;
  const AmityStoryTabComponent({super.key, required this.type , required this.createStory});

  @override
  Widget build(BuildContext context) {
    if (type is CommunityFeedStoryTab) {
      var communityFeedStoryTab = type as CommunityFeedStoryTab;
      return BlocProvider(
        create: (context) => CommunityFeedStoryBloc(),
        child: AmityStoryCommunityTabComponent(
          createStory: createStory,
            communityId: communityFeedStoryTab.communityId),
      );
    }

    if (type is GlobalFeedStoryTab) {}

    return Placeholder();
  }
}
