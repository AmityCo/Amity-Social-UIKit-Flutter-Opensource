import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_creator/comment_creator_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_item/comment_action.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_list/comment_list_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_body_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_bottom_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/amity_story_header_row.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  final Function(AmityStoryTarget storytarget, AmityStoryMediaType mediaType, AmityStoryImageDisplayMode? imageMode, HyperLink? hyperlionk) createStory;
  final Function(AmityCommunity)? navigateToCommunityProfilePage;
  static VideoPlayerController? videoPlayerController;
  AmityViewCommunityStoryPage({super.key, required this.targetId, required this.targetType, required this.createStory, this.isSingleTarget = true, this.isTargetVisible = true, this.shouldRestartTimer = false, this.firstSegmentReached, this.lastSegmentReached, this.navigateToCommunityProfilePage, required String communityId});

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
    return Scaffold(
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
              AmityCustomSnackBar.show(context, 'Story deleted', SvgPicture.asset('assets/Icons/ic_check_circled_white.svg', package: 'amity_uikit_beta_service', height: 20, color: Colors.white), textColor: Colors.white);
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
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: state.stories != null
                          ? (state.stories!.isNotEmpty)
                              ? PageView.builder(
                                  onPageChanged: ((value) {
                                    BlocProvider.of<ViewStoryBloc>(context).add(NewCurrentStory(currentStroy: state.stories![value]));
                                  }),
                                  controller: _pageController,
                                  itemCount: state.stories!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        Flexible(
                                          flex: 6,
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: double.infinity,
                                            child: AmityStoryBodyRow(
                                                dataType: state.stories![index].dataType!,
                                                data: state.stories![index].data!,
                                                state: state.stories![index].syncState!,
                                                items: state.stories![index].storyItems,
                                                isVisible: _currentPage == index,
                                                onTap: (onTap) {
                                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                                  state.stories![index].analytics().markAsSeen();
                                                  moveSegment(
                                                    shouldMoveToNext: onTap,
                                                    totalSegments: state.stories!.length,
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
                                                  if (state.stories![index].dataType == AmityStoryDataType.VIDEO) {
                                                    if (isHold) {
                                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                                                    } else {
                                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
                                                    }
                                                  }
                                                },
                                                onSwipeUp: () {
                                                  BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
                                                  if (state.stories![index].dataType == AmityStoryDataType.VIDEO) {
                                                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
                                                  }
                                                  var shouldAllowComment = BlocProvider.of<ViewStoryBloc>(context).state.community?.allowCommentInStory ?? false;

                                                  openCommentTraySheet(context, state.stories![index], shouldAllowComment);
                                                },
                                                onSwipeDown: () {
                                                  Navigator.of(context).pop();
                                                },
                                                onHyperlinkClick: (hyperLink) async {
                                                  if (hyperLink.url == null || hyperLink.url!.isEmpty) {
                                                    return;
                                                  }

                                                  state.stories![index].analytics().markLinkAsClicked();

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
                                              storyId: state.stories![index].storyId!,
                                              story: state.stories![index],
                                              target: state.storyTarget,
                                              state: state.stories![index].syncState!,
                                              reachCount: state.stories![index].reach,
                                              commentCount: state.stories![index].commentCount,
                                              reactionCount: state.stories![index].reactionCount,
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
                                              isReactedByMe: state.stories![index].myReactions.isNotEmpty ?? false,
                                              isCreatedByMe: state.stories![index].creatorId == AmityCoreClient.getUserId(),
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
                  state.stories != null
                      ? (state.stories!.isNotEmpty)
                          ? AmityStoryHeaderRow(
                              totalSegments: state.stories!.length,
                              story: state.stories![_currentPage],
                              stories: state.stories!,
                              currentSegment: _currentPage,
                              shouldPauseTimer: state.shouldPause ?? false,
                              shouldRestartTimer: true,
                              isSingleTarget: true,
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
                              moveToNextSegment: () {
                                AmityStorySingleSegmentTimerElement.currentValue = -1;
                                state.stories![_currentPage].analytics().markAsSeen();
                                moveSegment(
                                  shouldMoveToNext: true,
                                  totalSegments: state.stories!.length,
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
                                BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                AmityStorySingleSegmentTimerElement.currentValue = -1;
                                widget.lastSegmentReached!();
                              },
                              navigateToCreatePage: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                                  return CreateStoryConfigProviderWidget(
                                    targetType: AmityStoryTargetType.COMMUNITY,
                                    onStoryCreated: () {
                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                      AmityStorySingleSegmentTimerElement.currentValue = -1;
                                      Navigator.of(context).pop();
                                    },
                                    targetId: state.storyTarget!.targetId,
                                    storyTarget: state.storyTarget!,
                                    pageId: 'create_story_page',
                                    createStory: widget.createStory,
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
                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                      child: CommentTrayWidget(
                        scrollController: scrollController,
                        storyId: story.storyId!,
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


class CommentTrayWidget extends StatefulWidget {
  final String storyId;
  final bool shouldAllowComments;
  final ScrollController scrollController;
  const CommentTrayWidget({super.key, required this.storyId, required this.shouldAllowComments, required this.scrollController});

  @override
  State<CommentTrayWidget> createState() => _CommentTrayWidgetState();
}

class _CommentTrayWidgetState extends State<CommentTrayWidget> {
  AmityComment? replyToComment;
  // ScrollController scrollControllerTwo = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              controller: widget.scrollController,
              slivers: [
                const SliverAppBar(
                  title: Text('Comments'),
                  titleTextStyle: TextStyle(
                    color: Color(0xFF292B32),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: getSectionDivider(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 12, right: 16, top: 7),
                  sliver: AmityCommentTrayComponent(
                    referenceId: widget.storyId,
                    referenceType: AmityCommentReferenceType.STORY,
                    parentScrollController: widget.scrollController,
                    commentAction: CommentAction(onReply: (AmityComment? comment) {
                      setState(() {
                        replyToComment = comment;
                      });
                    }),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                getSectionDivider(),
                (widget.shouldAllowComments)
                    ? AmityCommentCreator(
                        referenceType: AmityCommentReferenceType.STORY,
                        referenceId: widget.storyId,
                        replyTo: replyToComment,
                        action: CommentCreatorAction(onDissmiss: () {
                          removeReplyToComment();
                        }),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/Icons/ic_lock_gray.svg',
                              package: 'amity_uikit_beta_service',
                              height: 16,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "Comments are disabled for this story",
                              style: TextStyle(fontSize: 15, fontFamily: "SF Pro Text", color: Color(0xff898E9E)),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  removeReplyToComment() {
    setState(() {
      replyToComment = null;
    });
  }

  Widget getSectionDivider() {
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFFEBECEF),
    );
  }
}
