import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityViewGlobalStoryPage extends NewBasePage {
  final AmityStoryTarget selectedTarget;
  final List<AmityStoryTarget> targets;

  AmityViewGlobalStoryPage({
    super.key,
    required this.selectedTarget,
    required this.targets,
  }) : super(pageId: 'view_global_story_page');

  @override
  Widget buildPage(BuildContext context) {
    return AmityViewGlobalStoryPageBuilder(
      selectedTarget: selectedTarget,
      targets: targets,
      theme: theme,
    );
  }
}

class AmityViewGlobalStoryPageBuilder extends StatefulWidget {
  final AmityStoryTarget selectedTarget;
  final List<AmityStoryTarget> targets;
  final AmityThemeColor? theme;

  const AmityViewGlobalStoryPageBuilder({
    super.key,
    required this.selectedTarget,
    required this.targets,
    this.theme,
  });

  @override
  State<AmityViewGlobalStoryPageBuilder> createState() => _AmityViewGlobalStoryPageBuilderState();
}

class _AmityViewGlobalStoryPageBuilderState extends State<AmityViewGlobalStoryPageBuilder> {
  int currentPage = 0;
  final PageController _pageController = PageController(
    keepPage: false, // Don't keep page state to reduce memory
  );
  final Map<int, ViewStoryBloc> _storyBlocs = {};

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentPage = widget.targets.indexOf(widget.selectedTarget);
      if (mounted) {
        _pageController.jumpToPage(currentPage);
      }
    });
  }

  void _onPageChanged() {
    if (!mounted) return;
    setState(() {
      currentPage = _pageController.page?.toInt() ?? 0;
      StoryTimerStateManager.currentValue = -1;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    // Dispose all created blocs
    for (var bloc in _storyBlocs.values) {
      bloc.close();
    }
    _storyBlocs.clear();
    super.dispose();
  }

  ViewStoryBloc _getBlocForIndex(int index) {
    if (!_storyBlocs.containsKey(index)) {
      _storyBlocs[index] = ViewStoryBloc();
    }
    return _storyBlocs[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.targets.length,
        physics: const PageScrollPhysics(), // Smooth physics for better feel
        pageSnapping: true, // Ensure pages snap properly
        allowImplicitScrolling: false, // Disable preemptive loading
        itemBuilder: (BuildContext context, int index) {
          // Use RepaintBoundary to isolate repaints
          return RepaintBoundary(
            child: BlocProvider.value(
              value: _getBlocForIndex(index),
              child: AmityViewCommunityStoryPage(
              communityId: '',
              targetId: widget.targets[index].targetId,
              targetType: AmityStoryTargetType.COMMUNITY,
              isSingleTarget: false,
              // createStory: widget.createStory,
              firstSegmentReached: () {
                StoryTimerStateManager.currentValue = -1;
                BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                moveTarget(
                  shouldMoveToNext: false,
                  totalTargets: widget.targets.length,
                  firstTargetReached: () {
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                    StoryTimerStateManager.currentValue = -1;
                  },
                  lastTargetReached: () {
                    StoryTimerStateManager.currentValue = -1;
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                  },
                );
              },
              lastSegmentReached: () {
                moveTarget(
                  shouldMoveToNext: true,
                  totalTargets: widget.targets.length,
                  firstTargetReached: () {
                    StoryTimerStateManager.currentValue = -1;
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                  },
                  lastTargetReached: () {
                    Navigator.of(context).pop();
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                    StoryTimerStateManager.currentValue = -1;
                  },
                );
              },
            ),
            ),
          );
        },
      ),
    );
  }

  void moveTarget({
    required bool shouldMoveToNext,
    required int totalTargets,
    required Function firstTargetReached,
    required Function lastTargetReached,
  }) {
    // var currentTarget = widget.targets[_pageController.page!.toInt()];
    if (shouldMoveToNext) {
      if (currentPage == totalTargets - 1) {
        //  last target
        lastTargetReached();
      } else {
        currentPage = currentPage + 1;
        StoryTimerStateManager.currentValue = -1;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else {
      if (currentPage == 0) {
        //  first target
        firstTargetReached();
      } else {
        StoryTimerStateManager.currentValue = -1;
        //  move to previous segment
        currentPage = currentPage - 1;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }
}
