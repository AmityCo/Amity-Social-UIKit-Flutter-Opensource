import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_comment_count_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_reaction_count_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_view_count_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityStoryEngagementRow extends StatefulWidget {
  final String storyId;
  final AmityStory amityStory;
  final bool isCommunityJoined;
  final bool isAllowedComment;
  final int reachCount;
  final int commentCount;
  final int reactionCount;
  final bool isReactedByMe;
  final bool isCreatedByMe;
  final bool hasModeratorRole;

  const AmityStoryEngagementRow({
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
  State<AmityStoryEngagementRow> createState() =>
      _AmityStoryEngagementRowState();
}

class _AmityStoryEngagementRowState extends State<AmityStoryEngagementRow> {
  Timer? _debounceTimer;
  late bool _localIsReactedByMe;
  late int _localReactionCount;
  bool? _initialReactedByMe;

  @override
  void initState() {
    super.initState();
    _localIsReactedByMe = widget.isReactedByMe;
    _localReactionCount = widget.reactionCount;
    _initialReactedByMe = widget.isReactedByMe;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onReactionTap(bool addReaction) {
    setState(() {
      if (addReaction) {
        _localIsReactedByMe = true;
        _localReactionCount++;
      } else {
        _localIsReactedByMe = false;
        _localReactionCount--;
      }
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Only dispatch event if the final state is different from initial
      if (_localIsReactedByMe != _initialReactedByMe) {
        if (_localIsReactedByMe) {
          BlocProvider.of<ViewStoryBloc>(context)
              .add(AddReactionEvent(storyId: widget.storyId));
        } else {
          BlocProvider.of<ViewStoryBloc>(context)
              .add(RemoveReactionEvent(storyId: widget.storyId));
        }
        _initialReactedByMe = _localIsReactedByMe;
      }
    });
  }

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
          (widget.hasModeratorRole || widget.isCreatedByMe)
              ? AmityStoryViewCountElement(
                  count: "${widget.reachCount}",
                  onClick: () {},
                )
              : Container(),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AmityStoryCommentCountElement(
                  onClick: () {
                    BlocProvider.of<ViewStoryBloc>(context)
                        .add(ShoudPauseEvent(shouldPause: true));
                    BlocProvider.of<StoryVideoPlayerBloc>(context)
                        .add(const PauseStoryVideoEvent());
                    openCommentTraySheet(context, widget.amityStory,
                        widget.isCommunityJoined, widget.isAllowedComment);
                  },
                  count: "${widget.commentCount}"),
              const SizedBox(width: 10),
              AmityStoryReactionCountElement(
                count: "$_localReactionCount",
                onClick: _onReactionTap,
                isReactedByMe: _localIsReactedByMe,
                isCommunityJoined: widget.isCommunityJoined,
              ),
            ],
          )),
        ],
      ),
    );
  }
}
