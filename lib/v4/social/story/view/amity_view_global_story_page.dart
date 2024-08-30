import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityViewGlobalStoryPage extends StatefulWidget {
  final AmityStoryTarget selectedTarget;
  final List<AmityStoryTarget> targets;
  final Function(AmityStoryTarget storytarget, AmityStoryMediaType mediaType, AmityStoryImageDisplayMode? imageMode, HyperLink? hyperlionk) createStory;

  AmityViewGlobalStoryPage({super.key, required this.selectedTarget, required this.targets, required this.createStory});

  @override
  State<AmityViewGlobalStoryPage> createState() => _AmityViewGlobalStoryPageState();
}

class _AmityViewGlobalStoryPageState extends State<AmityViewGlobalStoryPage> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.toInt() ?? 0;
        AmityStorySingleSegmentTimerElement.currentValue = -1;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentPage = widget.targets.indexOf(widget.selectedTarget);
      _pageController.jumpToPage(currentPage);
    });
    // currentPage = widget.targets.indexOf(widget.selectedTarget);
    // _pageController.jumpToPage(currentPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.targets.length,
        itemBuilder: (BuildContext context, int index) {
          return BlocProvider(
            create: (context) => ViewStoryBloc(),
            child: AmityViewCommunityStoryPage(
              communityId: '',
              targetId: widget.targets[index].targetId,
              targetType: AmityStoryTargetType.COMMUNITY,
              isSingleTarget: false,
              createStory: widget.createStory,
              firstSegmentReached: () {
                AmityStorySingleSegmentTimerElement.currentValue = -1;
                BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                moveTarget(
                  shouldMoveToNext: false,
                  totalTargets: widget.targets.length,
                  firstTargetReached: () {
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                    AmityStorySingleSegmentTimerElement.currentValue = -1;
                  },
                  lastTargetReached: () {
                    AmityStorySingleSegmentTimerElement.currentValue = -1;
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());

                  },
                );
              },
              lastSegmentReached: () {
                moveTarget(
                  shouldMoveToNext: true,
                  totalTargets: widget.targets.length,
                  firstTargetReached: () {
                    AmityStorySingleSegmentTimerElement.currentValue = -1;
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());

                  },
                  lastTargetReached: () {
                    Navigator.of(context).pop();
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                    AmityStorySingleSegmentTimerElement.currentValue = -1;
                  },
                );
              },
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

    var currentTarget = widget.targets[_pageController.page!.toInt()];
    if (shouldMoveToNext) {
      if (currentPage == totalTargets - 1) {
        //  last target
        lastTargetReached();
      } else {
        currentPage = currentPage + 1;
        AmityStorySingleSegmentTimerElement.currentValue = -1;
        _pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    } else {
      if (currentPage == 0) {
        //  first target
        firstTargetReached();
      } else {
        AmityStorySingleSegmentTimerElement.currentValue = -1;
        //  move to previous segment
        currentPage = currentPage - 1;
        _pageController.animateToPage(currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }
  }
}
