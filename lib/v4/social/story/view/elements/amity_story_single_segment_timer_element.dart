import 'package:flutter/material.dart';

// Timer state manager - provides thread-safe access to timer state
class StoryTimerStateManager {
  static double _currentValue = 0.0;
  static int _totalValue = 7;
  
  static double get currentValue => _currentValue;
  static set currentValue(double value) => _currentValue = value;
  
  static int get totalValue => _totalValue;
  static set totalValue(int value) => _totalValue = value;
  
  static void reset() {
    _currentValue = 0.0;
    _totalValue = 7;
  }
}

class AmityStorySingleSegmentTimerElement extends StatefulWidget {
  final bool shouldStart;
  final bool shouldRestart;
  final bool shouldPauseTimer;
  final bool isAlreadyFinished;
  final int duration;
  final bool isCurrentSegement;
  final Function onTimerFinished;

  const AmityStorySingleSegmentTimerElement({
    super.key,
    required this.shouldStart,
    required this.shouldRestart,
    required this.isCurrentSegement,
    required this.shouldPauseTimer,
    required this.isAlreadyFinished,
    required this.duration,
    required this.onTimerFinished,
  });

  @override
  State<AmityStorySingleSegmentTimerElement> createState() => _AmityStorySingleSegmentTimerElementState();
}

class _AmityStorySingleSegmentTimerElementState extends State<AmityStorySingleSegmentTimerElement> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    if (widget.isCurrentSegement) {
      controller.addListener(() {
        if (!mounted) return;
        setState(() {});
        if (!widget.isAlreadyFinished && widget.isCurrentSegement) {
          if (controller.value > 0.0 && StoryTimerStateManager.currentValue != -1) {
            StoryTimerStateManager.currentValue = controller.value;
          }
        }
      });
    }

    if (widget.shouldStart && widget.isCurrentSegement) {
      if (widget.shouldRestart) {
        controller.value = widget.isAlreadyFinished ? 1.0 : 0.0;
        controller.forward(from: StoryTimerStateManager.currentValue).whenComplete(() {
          if (!mounted) return;
          StoryTimerStateManager.currentValue = 0.0;
          widget.onTimerFinished();
        });
      }
      if (widget.shouldPauseTimer) {
        controller.value = StoryTimerStateManager.currentValue;
        controller.stop();
      } else {
        if (StoryTimerStateManager.currentValue == -1) {
          StoryTimerStateManager.currentValue = 0.0;
          controller.forward(from: StoryTimerStateManager.currentValue).whenComplete(() {
            if (!mounted) return;
            StoryTimerStateManager.currentValue = 0.0;
            widget.onTimerFinished();
          });
        } else {
          StoryTimerStateManager.currentValue = (StoryTimerStateManager.currentValue == 1.0) ? 0.0 : StoryTimerStateManager.currentValue;
          controller.forward(from: StoryTimerStateManager.currentValue).whenComplete(() {
            if (!mounted) return;
            StoryTimerStateManager.currentValue = 0.0;
            widget.onTimerFinished();
          });
        }
      }
    } else {
      controller.value = widget.isAlreadyFinished ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: LinearProgressIndicator(
          value: controller.value,
          valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 253, 253, 253)),
          backgroundColor: const Color.fromARGB(152, 214, 214, 214),
        ),
      ),
    );
  }
}
