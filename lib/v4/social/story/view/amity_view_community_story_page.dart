import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_cache.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_preloader.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
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

class AmityViewCommunityStoryPage extends NewBasePage {
  final String targetId;
  final AmityStoryTargetType targetType;
  final bool isSingleTarget;
  final bool isTargetVisible;
  final bool shouldRestartTimer;
  final Function? firstSegmentReached;
  final Function? lastSegmentReached;
  final Function(AmityCommunity)? navigateToCommunityProfilePage;
  
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
  }) : super(pageId: 'view_community_story_page');

  @override
  Widget buildPage(BuildContext context) {
    return AmityViewCommunityStoryPageBuilder(
      targetId: targetId,
      targetType: targetType,
      isSingleTarget: isSingleTarget,
      isTargetVisible: isTargetVisible,
      shouldRestartTimer: shouldRestartTimer,
      firstSegmentReached: firstSegmentReached,
      lastSegmentReached: lastSegmentReached,
      navigateToCommunityProfilePage: navigateToCommunityProfilePage,
      theme: theme,
    );
  }
}

class AmityViewCommunityStoryPageBuilder extends StatefulWidget {
  final String targetId;
  final AmityStoryTargetType targetType;
  final bool isSingleTarget;
  final bool isTargetVisible;
  final bool shouldRestartTimer;
  final Function? firstSegmentReached;
  final Function? lastSegmentReached;
  final Function(AmityCommunity)? navigateToCommunityProfilePage;
  final AmityThemeColor? theme;
  
  const AmityViewCommunityStoryPageBuilder({
    super.key,
    required this.targetId,
    required this.targetType,
    this.isSingleTarget = true,
    this.isTargetVisible = true,
    this.shouldRestartTimer = false,
    this.firstSegmentReached,
    this.lastSegmentReached,
    this.navigateToCommunityProfilePage,
    this.theme,
  });

  @override
  State<AmityViewCommunityStoryPageBuilder> createState() => _AmityViewCommunityStoryPageBuilderState();
}

class _AmityViewCommunityStoryPageBuilderState extends State<AmityViewCommunityStoryPageBuilder> {
  final PageController _pageController = PageController(
    keepPage: false, // Don't keep page state to reduce memory
  );
  AmityComment? replyToComment;

  int _currentPage = 0;
  // Track preloaded pages to avoid duplicate work
  final Set<int> _preloadedPages = {};
  // Global cache singleton for palettes (persists across communities)
  final _globalPaletteCache = StoryPaletteCache();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    
    // Use addPostFrameCallback for safe bloc access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      context.read<ViewStoryBloc>().add(FetchStoryTarget(communityId: widget.targetId));
      context.read<ViewStoryBloc>().add(FetchActiveStories(communityId: widget.targetId));
      context.read<ViewStoryBloc>().add(FetchManageStoryPermission(communityId: widget.targetId));
    });
  }

  void _onPageChanged() {
    if (!mounted) return;
    setState(() {
      StoryTimerStateManager.currentValue = -1;
      _currentPage = _pageController.page?.toInt() ?? 0;
      StoryTimerStateManager.currentValue = -1;
    });
    
    // Trigger preloading for adjacent pages
    _preloadAdjacentPages();
  }

  // Preload next and previous pages intelligently
  void _preloadAdjacentPages() {
    final state = context.read<ViewStoryBloc>().state;
    final stories = state.stories;
    
    if (stories == null || stories.isEmpty) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Preload next page (priority)
      if (_currentPage + 1 < stories.length) {
        _preloadStoryPage(_currentPage + 1, stories);
      }
      
      // Preload previous page (lower priority)
      if (_currentPage - 1 >= 0) {
        _preloadStoryPage(_currentPage - 1, stories);
      }
      
      // Clean up pages that are far away (keep memory optimized)
      _cleanupDistantPages();
    });
  }

  // Eagerly calculate palette for initial story (first-time load optimization)
  // Now uses global cache for cross-community persistence
  void _preCalculateInitialPalette(int index, List<AmityStory> stories) async {
    if (index < 0 || index >= stories.length) return;
    
    final story = stories[index];
    final storyId = story.storyId ?? '';
    
    // Check global cache first
    if (_globalPaletteCache.has(storyId)) return; // Already calculated globally
    
    // Only process image stories
    if (story.dataType != AmityStoryDataType.IMAGE) return;
    if (story.data == null) return;
    
    try {
      // Cast to ImageStoryData to access image property
      final imageData = story.data as ImageStoryData;

      // Delegate actual generation to shared preloader queue
      StoryPalettePreloader().ensurePaletteForImageData(
        storyId: storyId,
        imageData: imageData,
      );
    } catch (e) {
      // Silently fail - palette is nice-to-have
    }
  }

  void _preloadStoryPage(int index, List<AmityStory> stories) {
    if (_preloadedPages.contains(index)) return; // Already preloaded
    if (index < 0 || index >= stories.length) return;
    
  final story = stories[index];
    
    // Only preload image stories
    if (story.dataType != AmityStoryDataType.IMAGE) return;
    if (story.data == null) return;
    
    _preloadedPages.add(index);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final imageData = story.data as ImageStoryData;
        
        final ImageProvider baseProvider;
        if (imageData.image.hasLocalPreview != null && imageData.image.hasLocalPreview!) {
          baseProvider = FileImage(File(imageData.image.getFilePath!));
        } else {
          baseProvider = NetworkImage(imageData.image.getUrl(AmityImageSize.MEDIUM));
        }
        
        // Downsample to reduce decode cost while keeping acceptable quality
        final resizedProvider = ResizeImage(
          baseProvider,
          width: 720,
          height: 1280,
          allowUpscaling: false,
        );
        
        precacheImage(
          resizedProvider,
          context,
          onError: (_, __) {},
        );
      } catch (_) {
        // Silently fail - not critical
      }
      
      // Queue palette generation using throttled preloader
      StoryPalettePreloader().preloadStory(story);
    });
  }

  void _cleanupDistantPages() {
    // Remove pages that are more than 2 away from current
    _preloadedPages.removeWhere((page) => (page - _currentPage).abs() > 2);
    // Note: Global palette cache is NOT cleaned up here to maintain cross-community cache
  }

  // Refresh global story targets by triggering a datasource subscription
  // This will push updates to all existing subscribers without needing the bloc
  void _refreshGlobalStoryTargets() {
    // Create a temporary subscription to trigger datasource update
    final tempCollection = GlobalStoryTargetLiveCollection(
      queryOption: AmityGlobalStoryTargetsQueryOption.SMART,
    );
    
    // Subscribe briefly to trigger the datasource
    final tempSubscription = tempCollection.getStreamController().stream.listen((_) {});
    
    // Trigger initial load - this will cause datasource to push to all subscribers
    tempCollection.getFirstPageRequest();
    
    // Clean up after a short delay to ensure datasource has pushed updates
    Future.delayed(const Duration(milliseconds: 800), () {
      tempSubscription.cancel();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    // Note: Global palette cache persists for cross-community instant display
    super.dispose();
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
                
                // Use post-frame callback to ensure PageView is built before jumping
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(_currentPage);
                    BlocProvider.of<ViewStoryBloc>(context).add(
                      NewCurrentStory(currentStroy: state.stories![_currentPage]),
                    );
                  }
                });
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
                  // Trigger datasource refresh by creating a subscription to global targets
                  // This will push updates to all existing subscribers
                  _refreshGlobalStoryTargets();
                  
                  if (widget.isSingleTarget) {
                    Navigator.of(context).pop();
                  } else {
                    // Move to next target when there are no stories
                    widget.lastSegmentReached?.call();
                  }
                } else if (_currentPage >= state.stories!.length) {
                  _currentPage = _currentPage - 1;
                  _pageController.jumpToPage(_currentPage);
                } else {
                  // Eagerly calculate palette for first story (current page)
                  // This ensures palette is ready before the page is displayed
                  _preCalculateInitialPalette(_currentPage, state.stories!);
                  
                  // Warm up palette cache for the next couple of stories
                  StoryPalettePreloader().preloadStories(
                    state.stories!,
                    limit: 3,
                  );
                  
                  // Defer adjacent image preloading until the current frame is settled
                  Future.microtask(_preloadAdjacentPages);
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
                                      // Preload adjacent pages on page change
                                      Future.microtask(() => _preloadAdjacentPages());
                                    }),
                                    physics: const NeverScrollableScrollPhysics(),
                                    controller: _pageController,
                                    itemCount: stories.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              width: double.infinity,
                                              // Isolate repaints for better performance
                                              child: RepaintBoundary(
                                                child: AmityStoryBodyRow(
                                                  dataType: stories[index].dataType!,
                                                  data: stories[index].data!,
                                                  state: stories[index].syncState!,
                                                  items: stories[index].storyItems,
                                                  isVisible: _currentPage == index,
                                                  storyId: stories[index].storyId ?? '', // Pass story ID for global cache lookup
                                                  onTap: (onTap) {
                                                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                                    StoryTimerStateManager.currentValue = -1;
                                                    stories[index].analytics().markAsSeen();
                                                    moveSegment(
                                                      shouldMoveToNext: onTap,
                                                      totalSegments: stories.length,
                                                      firstSegmentReached: () {
                                                        widget.firstSegmentReached!();
                                                      },
                                                      lastSegmentReached: () {
                                                        BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                                        StoryTimerStateManager.currentValue = -1;
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

                                                    var shouldAllowComment = (BlocProvider.of<ViewStoryBloc>(context).state.community?.allowCommentInStory ?? false) && (state.isCommunityJoined ?? true);

                                                    openCommentTraySheet(context, stories[index], state.isCommunityJoined ?? true, shouldAllowComment);
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
                                          ),
                                          SafeArea(
                                            top: false,
                                            child: Container(
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
                                                  StoryTimerStateManager.currentValue = -1;
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
                                theme: widget.theme,
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
                                  StoryTimerStateManager.currentValue = -1;
                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());

                                  if (state.stories == null) {
                                    widget.lastSegmentReached!();
                                  } else if (state.stories!.length == 1 || state.stories!.isEmpty) {
                                    widget.lastSegmentReached!();
                                  }
                                },
                                moveToNextSegment: () {
                                  StoryTimerStateManager.currentValue = -1;
                                  stories[_currentPage].analytics().markAsSeen();
                                  moveSegment(
                                    shouldMoveToNext: true,
                                    totalSegments: stories.length,
                                    firstSegmentReached: () {
                                      widget.firstSegmentReached!();
                                    },
                                    lastSegmentReached: () {
                                      StoryTimerStateManager.currentValue = -1;
                                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                      widget.lastSegmentReached!();
                                    },
                                  );
                                },
                                onCloseClicked: () {
                                  StoryTimerStateManager.currentValue = -1;
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
                                      StoryTimerStateManager.currentValue = -1;
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
        StoryTimerStateManager.currentValue = -1;
        _pageController.jumpToPage(
          currentSegment + 1,
          //duration: const Duration(milliseconds: 500), curve: Curves.easeIn
        );
        StoryTimerStateManager.currentValue = -1;
      }
    } else {
      if (currentSegment == 0) {
        //  first segment
        firstSegmentReached();
      } else {
        StoryTimerStateManager.currentValue = -1;
        //  move to previous segment
        _pageController.jumpToPage(
          currentSegment - 1,
          // duration: const Duration(milliseconds: 500), curve: Curves.easeIn
        );
        StoryTimerStateManager.currentValue = -1;
      }
    }
  }
}

// Widget of the comments tray in the bottomSheet

void openCommentTraySheet(
    BuildContext context,
    AmityStory story,
    bool shouldAllowInteraction,
    bool shouldAllowComments) {
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
                      community: story.target is AmityStoryTargetCommunity ? (story.target as AmityStoryTargetCommunity).community : null,
                      shouldAllowInteraction: shouldAllowInteraction,
                      shouldAllowComments: shouldAllowComments,
                    ),
                  );
                }),
          ),
        );
      }).whenComplete(() {
    // Check if context is still valid before using it
    if (context.mounted) {
      BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
      if (story.dataType == AmityStoryDataType.VIDEO) {
        BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PlayStoryVideoEvent());
      }
    }
  });
}

