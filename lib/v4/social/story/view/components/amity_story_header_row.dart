import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_modal_bottom_sheet.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class AmityStoryHeaderRow extends StatelessWidget {
  final AmityStory? story;
  final List<AmityStory> stories;
  final int totalSegments;
  final int currentSegment;
  final bool shouldPauseTimer;
  final bool shouldRestartTimer;
  final bool isSingleTarget;
  final Function moveToNextSegment;
  final Function onCloseClicked;
  final Function navigateToCreatePage;
  final Function onStoryDelete;
  final Function(AmityCommunity) navigateToCommunityProfilePage;

  const AmityStoryHeaderRow({
    super.key,
    this.story,
    required this.totalSegments,
    required this.currentSegment,
    required this.shouldPauseTimer,
    required this.shouldRestartTimer,
    required this.isSingleTarget,
    required this.stories,
    required this.onStoryDelete,
    required this.moveToNextSegment,
    required this.onCloseClicked,
    required this.navigateToCreatePage,
    required this.navigateToCommunityProfilePage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewStoryBloc, ViewStoryState>(builder: (context, state) {
      return Container(
          height: 100,
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                child: AmityStorySegmentTimerElement(
                  shouldPauseTimer: shouldPauseTimer,
                  shouldRestart: shouldRestartTimer,
                  totalSegments: totalSegments,
                  currentSegment: currentSegment,
                  duration: story!.dataType == AmityStoryDataType.VIDEO ? (AmityStorySingleSegmentTimerElement.totalValue+1) : 7,
                  moveToNextSegment: () {
                    moveToNextSegment();
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  state.community != null
                      ? Container(
                          height: 40,
                          width: 40,
                          child: Stack(
                            children: [
                              SizedBox(width: 40, height: 40, child: getProfileIcon(state.community)),
                              (state.hasManageStoryPermission)
                                  ? Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          navigateToCreatePage();
                                        },
                                        child: SvgPicture.asset(
                                          "assets/Icons/ic_add_circle_blue.svg",
                                          package: 'amity_uikit_beta_service',
                                          height: 14,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      : Shimmer.fromColors(
                          baseColor: const Color.fromARGB(255, 49, 49, 49),
                          highlightColor: Color.fromARGB(255, 80, 80, 80),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
                          )),
                  const SizedBox(
                    width: 10,
                  ),
                  (state.community != null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  state.community!.displayName ?? "",
                                  style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: "SF Pro Text"),
                                ),
                                (state.community?.isOfficial != null && state.community?.isOfficial == true)
                                    ? SvgPicture.asset(
                                        "assets/Icons/ic_verified_white.svg",
                                        height: 12,
                                        package: 'amity_uikit_beta_service',
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  story!.createdAt!.toSocialTimestamp(),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white, fontFamily: "SF Pro Text"),
                                ),
                                Container(
                                  height: 3,
                                  width: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                ),
                                Text(
                                  "By ${story?.creator?.displayName}" ?? "",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontFamily: "SF Pro Text", color: Colors.white),
                                ),
                              ],
                            )
                          ],
                        )
                      : Container(
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: const Color.fromARGB(255, 49, 49, 49),
                                highlightColor: Color.fromARGB(255, 80, 80, 80),
                                child: Container(
                                  height: 10,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Shimmer.fromColors(
                                baseColor: const Color.fromARGB(255, 49, 49, 49),
                                highlightColor: Color.fromARGB(255, 80, 80, 80),
                                child: Container(
                                  height: 10,
                                  width: 100,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (story?.creatorId == AmityCoreClient.getUserId() || state.hasManageStoryPermission)
                          ? IconButton(
                              onPressed: () {
                                BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
                                if (story!.dataType == AmityStoryDataType.VIDEO) {
                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                                }
                                amityStoryModalBottomSheetOverFlowMenu(
                                    context: context,
                                    storyId: story!.storyId!,
                                    onDeleted: onStoryDelete,
                                    story: story!,
                                    deleteClicked: (String storyId) {
                                      ConfirmationDialog().show(
                                        context: context,
                                        title: 'Delete this story?',
                                        detailText: 'This story will be permanently deleted.\n You’ll no longer to see and find this story',
                                        leftButtonText: 'Cancel',
                                        rightButtonText: 'Delete',
                                        onConfirm: () {

                                          BlocProvider.of<ViewStoryBloc>(context).add(DeleteStoryEvent(storyId: storyId));
                                          BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
                                          if (story!.dataType == AmityStoryDataType.VIDEO) {
                                            BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                                          }
                                          onStoryDelete();
                                        },
                                      );
                                    });
                              },
                              icon: SvgPicture.asset(
                                "assets/Icons/ic_dots_horizontal.svg",
                                package: 'amity_uikit_beta_service',
                                width: 16,
                              ))
                          : Container(),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset(
                          "assets/Icons/ic_close_white.svg",
                          package: 'amity_uikit_beta_service',
                          width: 12,
                        ),
                      )
                    ],
                  ))
                ],
              )
            ],
          ));
    });
  }

  Widget getProfileIcon(AmityCommunity? community) {
    if (community == null) {
      return const AmityNetworkImage(imageUrl: "", placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg");
    }

    return community.avatarImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AmityNetworkImage(
              imageUrl: community.avatarImage!.fileUrl!,
              placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
            ),
          )
        : const AmityNetworkImage(
            imageUrl: "",
            placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
          );
  }
}
