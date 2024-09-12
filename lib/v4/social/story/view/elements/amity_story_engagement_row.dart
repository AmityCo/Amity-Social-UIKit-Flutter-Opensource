import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_comment_count_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_reaction_count_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_view_count_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityStoryEngagementRow extends StatelessWidget {
  final String storyId;
  final AmityStory amityStory;
  final bool isCommunityJoined;
  final bool isAllowedComment;
  int reachCount;
  int commentCount;
  int reactionCount;
  bool isReactedByMe;
  final bool isCreatedByMe;
  final bool hasModeratorRole;

  AmityStoryEngagementRow({
    super.key,
    required this.storyId,
    required this.isCommunityJoined,
    required this.isAllowedComment,
    required this.amityStory,
    required this.isCreatedByMe,
    required this.hasModeratorRole,
    this.commentCount = 0,
    this.reactionCount = 0,
    this.isReactedByMe = false,
    this.reachCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (hasModeratorRole || isCreatedByMe)
              ? AmityStoryViewCountElement(
                  count: "$reachCount",
                  onClick: () {},
                )
              : Container(),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AmityStoryCommentCountElement(
                  onClick: () {
                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                    openCommentTraySheet(context, amityStory, isAllowedComment);
                  },
                  count: "$commentCount"),
              const SizedBox(width: 10),
              AmityStoryReactionCountElement(
                count: "$reactionCount",
                onClick: (addReaction) {
                  if (addReaction) {
                    BlocProvider.of<ViewStoryBloc>(context).add(AddReactionEvent(storyId: storyId));
                  } else {
                    BlocProvider.of<ViewStoryBloc>(context).add(RemoveReactionEvent(storyId: storyId));
                  }
                },
                isReactedByMe: isReactedByMe,
                isCommunityJoined: isCommunityJoined,
              ),
            ],
          )),
        ],
      ),
    );
  }

  
}
