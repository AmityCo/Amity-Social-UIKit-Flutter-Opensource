import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:flutter/material.dart';

class AmityStorySegmentTimerElement extends StatelessWidget {
  final bool shouldPauseTimer;
  final bool shouldRestart;
  final int totalSegments;
  final int currentSegment;
  final int duration;
  final Function moveToNextSegment;

  const AmityStorySegmentTimerElement({
    super.key,
    required this.shouldPauseTimer,
    required this.shouldRestart,
    required this.totalSegments,
    required this.currentSegment,
    required this.duration,
    required this.moveToNextSegment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: double.infinity,
      child: Row(
        children: List.generate(totalSegments, (index) {
          var uniqueKey = UniqueKey();
          return Expanded(
            child: AmityStorySingleSegmentTimerElement(
              key: uniqueKey,
              shouldStart: index == currentSegment,
              shouldRestart: index == currentSegment && shouldRestart,
              shouldPauseTimer: shouldPauseTimer,
              isCurrentSegement: index == currentSegment,
              isAlreadyFinished: index < currentSegment,
              duration: duration,
              onTimerFinished: () {
                moveToNextSegment();
              },
            ),
          );
        }, growable: true),
      ),
    );
  }
}
