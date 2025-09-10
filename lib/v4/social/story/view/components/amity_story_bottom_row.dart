import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_engagement_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_upload_progress_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryBottomRow extends StatelessWidget {
  final String storyId;
  final AmityStory story;
  final AmityStoryTarget? target;
  final AmityStorySyncState state;
  final int reachCount;
  final int commentCount;
  final int reactionCount;
  final bool isReactedByMe;
  final bool isCreatedByMe;
  final bool hasModeratorRole;
  final Function onStoryDelete;


  const AmityStoryBottomRow({
    super.key,
    required this.storyId,
    required this.story,
    required this.target,
    required this.state,
    required this.reachCount,
    required this.commentCount,
    required this.reactionCount,
    required this.isReactedByMe,
    required this.isCreatedByMe,
    required this.hasModeratorRole,
    required this.onStoryDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (state == AmityStorySyncState.SYNCING) {
      return AmityStoryUploadProgressRow();
    }

    if (state == AmityStorySyncState.SYNCED) {
      return Align(
        alignment: Alignment.topCenter,
        child: AmityStoryEngagementRow(
          storyId: storyId,
          amityStory: story,
          isCommunityJoined: BlocProvider.of<ViewStoryBloc>(context).state.isCommunityJoined ?? false,
          isReactedByMe: isReactedByMe,
          isAllowedComment: BlocProvider.of<ViewStoryBloc>(context).state.community?.allowCommentInStory ?? false,
          reachCount: reachCount,
          reactionCount: reactionCount,
          commentCount: commentCount,
          isCreatedByMe: isCreatedByMe,
          hasModeratorRole: hasModeratorRole,
        ),
      );
    }

    if (state == AmityStorySyncState.FAILED) {
      return SizedBox(
        child: Align(
          alignment: Alignment.topCenter,
          child: AmityStoryUploadFailedRow(
            onStoryDelete: onStoryDelete,
            storyId: storyId,
            story: story,
          ),
        ),
      );
    }

    return const Placeholder();
  }
}

class AmityStoryUploadFailedRow extends StatelessWidget {
  final String storyId;
  final AmityStory story;
  final Function onStoryDelete;
  AmityStoryUploadFailedRow({super.key, required this.storyId, required this.story , required this.onStoryDelete});

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: const BoxDecoration(
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/Icons/ic_warning_outline_white.svg",
                package: 'amity_uikit_beta_service',
                width: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getText(context, 'error_message_failed_to_upload_story') ??
                    "Failed to upload",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: "SF Pro Text",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
              if (story.dataType == AmityStoryDataType.VIDEO) {
                BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
              }
              AmityAlertDialogWithThreeActions().show(
                  context: context,
                  title: _getText(context, 'failed_upload_story_title') ??
                      "Failed to upload story",
                  detailText: _getText(context, 'failed_upload_story_desc') ??
                      "Would you like to discard or retry uploading?",
                  actionOneText: _getText(context, 'general_retry') ?? "Retry",
                  actionTwoText: context.l10n.general_discard,
                  actionOneColor: Colors.blue,
                  dismissText: context.l10n.general_cancel,
                  actionOne: () {
                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
                    if (story.dataType == AmityStoryDataType.VIDEO) {
                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                    }
                    BlocProvider.of<ViewStoryBloc>(context).add(StoryRetryEvent(storyId: storyId, amityStory: story));
                  },
                  actionTwo: () {
                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
                    if (story.dataType == AmityStoryDataType.VIDEO) {
                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                    }
                    BlocProvider.of<ViewStoryBloc>(context).add(DeleteStoryEvent(storyId: storyId));
                    onStoryDelete();
                    // 
                  },
                  onDismissRequest: () {
                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
                    if (story.dataType == AmityStoryDataType.VIDEO) {
                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                    }
                  });
            },
            icon: SvgPicture.asset(
              "assets/Icons/ic_dots_horizontal.svg",
              package: 'amity_uikit_beta_service',
              width: 16,
            ),
          )
        ],
      ),
    );
  }
}
