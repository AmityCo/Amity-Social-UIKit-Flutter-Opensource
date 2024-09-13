import 'package:amity_uikit_beta_service/v4/social/story/target/community/amity_story_community_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/community/bloc/community_feed_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/global/amity_story_global_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/global/bloc/global_story_target_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityStoryTabComponent extends StatelessWidget {
  final AmityStoryTabComponentType type;
  const AmityStoryTabComponent({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (type is CommunityFeedStoryTab) {
      var communityFeedStoryTab = type as CommunityFeedStoryTab;
      return BlocProvider(
        create: (context) => CommunityFeedStoryBloc(),
        child: AmityStoryCommunityTabComponent(
          communityId: communityFeedStoryTab.communityId,
        ),
      );
    }

    if (type is GlobalFeedStoryTab) {
      return BlocProvider(
        create: (context) => GlobalStoryTargetBloc(),
        child: AmityStoryGlobalTabComponent(),
      );
    }

    return const Placeholder();
  }
}
