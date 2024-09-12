import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_tray.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_body_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_bottom_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_header_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class AmityViewCommunityStoryPage extends StatefulWidget {
  final String targetId;
  final AmityStoryTargetType targetType;
  final bool isSingleTarget;
  final bool isTargetVisible;
  final bool shouldRestartTimer;
  final Function? firstSegmentReached;
  final Function? lastSegmentReached;
  final Function(AmityCommunity)? navigateToCommunityProfilePage;
  static VideoPlayerController? videoPlayerController;
  AmityViewCommunityStoryPage({
    super.key,
    required this.targetId,
    required this.targetType,
    this.isSingleTarget = true,
    this.isTargetVisible = true,
    this.shouldRestartTimer = false,
    this.firstSegmentReached,
    this.lastSegmentReached,
    this.navigateToCommunityProfilePage,
    required String communityId,
  });

  @override
  State<AmityViewCommunityStoryPage> createState() => _AmityViewCommunityStoryPageState();
}

class _AmityViewCommunityStoryPageState extends State<AmityViewCommunityStoryPage> {
  final PageController _pageController = PageController();
  AmityComment? replyToComment;

  int _currentPage = 0;

  @override
  initState() {
    _pageController.addListener(() {
      setState(() {
        AmityStorySingleSegmentTimerElement.currentValue = -1;
        _currentPage = _pageController.page?.toInt() ?? 0;
        AmityStorySingleSegmentTimerElement.currentValue = -1;
      });
    });
    BlocProvider.of<ViewStoryBloc>(context).add(FetchStoryTarget(communityId: widget.targetId));
    BlocProvider.of<ViewStoryBloc>(context).add(FetchActiveStories(communityId: widget.targetId));
    BlocProvider.of<ViewStoryBloc>(context).add(FetchManageStoryPermission(communityId: widget.targetId));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateStoryBloc, CreateStoryState>(
      listener: (context, state) {
        if (state is CreateStoryLoading) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocConsumer<ViewStoryBloc, ViewStoryState>(
            listener: (context, state) {
              if (state is JumpToUnSeenState) {
                _currentPage = state.jumpToUnSeen;
                _pageController.jumpToPage(_currentPage);
                BlocProvider.of<ViewStoryBloc>(context).add(
                  NewCurrentStory(currentStroy: state.stories![_currentPage]),
                );
              }
              if (state is StoryDeletedEvent) {
                AmityCustomSnackBar.show(
                  context,
                  'Story deleted',
                  SvgPicture.asset(
                    'assets/Icons/ic_check_circled_white.svg',
                    package: 'amity_uikit_beta_service',
                    height: 20,
                    color: Colors.white,
                  ),
                  textColor: Colors.white,
                );
              }
              if (state is ActiveStoriesFetchedState) {
                if (state.stories!.isEmpty) {
                  Navigator.of(context).pop();
                } else if (_currentPage >= state.stories!.length) {
                  _currentPage = _currentPage - 1;
                  _pageController.jumpToPage(_currentPage);
                }
              }
            },
            builder: (context, state) {
              var stories = state.stories;

              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: stories != null
                            ? (stories.isNotEmpty)
                                ? PageView.builder(
                                    onPageChanged: ((value) {
                                      BlocProvider.of<ViewStoryBloc>(context).add(NewCurrentStory(currentStroy: stories[value]));
                                    }),
                                    physics: const NeverScrollableScrollPhysics(),
                                    controller: _pageController,
                                    itemCount: stories.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Flexible(
                                            flex: 6,
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: AmityStoryBodyRow(
                                                  dataType: stories[index].dataType!,
                                                  data: stories[index].data!,
                                                  state: stories[index].syncState!,
                                                  items: stories[index].storyItems,
                                                  isVisible: _currentPage == index,
                                                  onTap: (onTap) {
                                                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                                    AmityStorySingleSegmentTimerElement.currentValue = -1;
                                                    stories[index].analytics().markAsSeen();
                                                    moveSegment(
                                                      shouldMoveToNext: onTap,
                                                      totalSegments: stories.length,
                                                      firstSegmentReached: () {
                                                        widget.firstSegmentReached!();
                                                      },
                                                      lastSegmentReached: () {
                                                        BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                                        AmityStorySingleSegmentTimerElement.currentValue = -1;
                                                        widget.lastSegmentReached!();
                                                      },
                                                    );
                                                  },
                                                  onHold: (isHold) {
                                                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: isHold));
                                                    if (stories[index].dataType == AmityStoryDataType.VIDEO) {
                                                      if (isHold) {
                                                        BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                                                      } else {
                                                        BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                                                      }
                                                    }
                                                  },
                                                  onSwipeUp: () {
                                                    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
                                                    if (stories[index].dataType == AmityStoryDataType.VIDEO) {
                                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                                                    }
                                                    var shouldAllowComment = BlocProvider.of<ViewStoryBloc>(context).state.community?.allowCommentInStory ?? false;

                                                    openCommentTraySheet(context, stories[index], shouldAllowComment);
                                                  },
                                                  onSwipeDown: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  onHyperlinkClick: (hyperLink) async {
                                                    if (hyperLink.url == null || hyperLink.url!.isEmpty) {
                                                      return;
                                                    }

                                                    stories[index].analytics().markLinkAsClicked();

                                                    if (hyperLink.url!.contains('http') || hyperLink.url!.contains('https')) {
                                                      final Uri url = Uri.parse(hyperLink.url!);
                                                      if (!await launchUrl(url)) {
                                                        throw Exception('Could not launch $url');
                                                      }
                                                    } else {
                                                      final Uri url = Uri.parse("http://${hyperLink.url}");
                                                      if (!await launchUrl(url)) {
                                                        throw Exception('Could not launch $url');
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ),

                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              height: double.infinity,
                                              width: double.infinity,
                                              color: Colors.black,
                                              child: AmityStoryBottomRow(
                                                storyId: stories[index].storyId!,
                                                story: stories[index],
                                                target: state.storyTarget,
                                                state: stories[index].syncState!,
                                                reachCount: stories[index].reach,
                                                commentCount: stories[index].commentCount,
                                                reactionCount: stories[index].reactionCount,
                                                onStoryDelete: () {
                                                  AmityCustomSnackBar.show(context, 'Story deleted', SvgPicture.asset('assets/Icons/ic_check_circled_white.svg', package: 'amity_uikit_beta_service', height: 20, color: Colors.white), textColor: Colors.white);
                                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());

                                                  if (state.stories == null) {
                                                    widget.lastSegmentReached!();
                                                  } else if (state.stories!.length == 1 || state.stories!.isEmpty) {
                                                    widget.lastSegmentReached!();
                                                  }
                                                },
                                                isReactedByMe: stories[index].myReactions.isNotEmpty,
                                                isCreatedByMe: stories[index].creatorId == AmityCoreClient.getUserId(),
                                                hasModeratorRole: state.hasManageStoryPermission,
                                              ),
                                            ),
                                          ),
                                          // Bottom Row
                                        ],
                                      );
                                    },
                                  )
                                : Container()
                            : Container()),
                    stories != null
                        ? (stories.isNotEmpty)
                            ? AmityStoryHeaderRow(
                                totalSegments: stories.length,
                                story: stories[_currentPage],
                                stories: stories,
                                currentSegment: _currentPage,
                                shouldPauseTimer: state.shouldPause ?? false,
                                shouldRestartTimer: true,
                                isSingleTarget: true,
                                onStoryDelete: () {
                                  AmityCustomSnackBar.show(
                                    context,
                                    'Story deleted',
                                    SvgPicture.asset(
                                      'assets/Icons/ic_check_circled_white.svg',
                                      package: 'amity_uikit_beta_service',
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    textColor: Colors.white,
                                  );
                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());

                                  if (state.stories == null) {
                                    widget.lastSegmentReached!();
                                  } else if (state.stories!.length == 1 || state.stories!.isEmpty) {
                                    widget.lastSegmentReached!();
                                  }
                                },
                                moveToNextSegment: () {
                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                  stories[_currentPage].analytics().markAsSeen();
                                  moveSegment(
                                    shouldMoveToNext: true,
                                    totalSegments: stories.length,
                                    firstSegmentReached: () {
                                      widget.firstSegmentReached!();
                                    },
                                    lastSegmentReached: () {
                                      AmityStorySingleSegmentTimerElement.currentValue = -1;
                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                      widget.lastSegmentReached!();
                                    },
                                  );
                                },
                                onCloseClicked: () {
                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                  widget.lastSegmentReached!();
                                },
                                navigateToCreatePage: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                                    return CreateStoryConfigProviderWidget(
                                      targetType: AmityStoryTargetType.COMMUNITY,
                                      targetId: state.storyTarget!.targetId,
                                      pageId: 'create_story_page',
                                    );
                                  }));
                                },
                                navigateToCommunityProfilePage: widget.navigateToCommunityProfilePage ??
                                    (community) {
                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                      AmityStorySingleSegmentTimerElement.currentValue = -1;
                                    })
                            : Container()
                        : Container(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  moveSegment({
    required bool shouldMoveToNext,
    required int totalSegments,
    required Function firstSegmentReached,
    required Function lastSegmentReached,
  }) {
    var currentSegment = _currentPage;

    if (shouldMoveToNext) {
      if (currentSegment == totalSegments - 1) {
        //  last segment
        lastSegmentReached();
      } else {
        //  move to next segment
        AmityStorySingleSegmentTimerElement.currentValue = -1;
        _pageController.jumpToPage(
          currentSegment + 1,
          //duration: const Duration(milliseconds: 500), curve: Curves.easeIn
        );
        AmityStorySingleSegmentTimerElement.currentValue = -1;
      }
    } else {
      if (currentSegment == 0) {
        //  first segment
        firstSegmentReached();
      } else {
        AmityStorySingleSegmentTimerElement.currentValue = -1;
        //  move to previous segment
        _pageController.jumpToPage(
          currentSegment - 1,
          // duration: const Duration(milliseconds: 500), curve: Curves.easeIn
        );
        AmityStorySingleSegmentTimerElement.currentValue = -1;
      }
    }
  }
}

// Widget of the comments tray in the bottomSheet

void openCommentTraySheet(BuildContext context, AmityStory story, bool shouldAllowComments) {
  BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
  if (story.dataType == AmityStoryDataType.VIDEO) {
    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
  }
  showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 10),
            child: DraggableScrollableSheet(
                initialChildSize: 0.95, //set this as you want
                maxChildSize: 0.95, //set this as you want
                minChildSize: 0,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: AmityCommentTrayComponent(
                      scrollController: scrollController,
                      referenceId: story.storyId!,
                      referenceType: AmityCommentReferenceType.STORY,
                      shouldAllowComments: shouldAllowComments,
                    ),
                  );
                }),
          ),
        );
      }).whenComplete(() {
    BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
    if (story.dataType == AmityStoryDataType.VIDEO) {
      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
    }
  });
}

