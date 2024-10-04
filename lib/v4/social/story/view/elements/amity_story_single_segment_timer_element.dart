import 'package:flutter/material.dart';

class AmityStorySingleSegmentTimerElement extends StatefulWidget {
  final bool shouldStart;
  final bool shouldRestart;
  final bool shouldPauseTimer;
  final bool isAlreadyFinished;
  final int duration;
  final bool isCurrentSegement;
  final Function onTimerFinished;
  static double currentValue = 0.0;
  static int totalValue = 7;

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
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    if (widget.isCurrentSegement) {
      controller.addListener(() {
        setState(() {});
        if (!widget.isAlreadyFinished && widget.isCurrentSegement) {
          if (controller.value > 0.0 && AmityStorySingleSegmentTimerElement.currentValue != -1) {
            AmityStorySingleSegmentTimerElement.currentValue = controller.value;
          }
        }
      });
    }

    if (widget.shouldStart && widget.isCurrentSegement) {
      if (widget.shouldRestart) {
        controller.value = widget.isAlreadyFinished ? 1.0 : 0.0;
        controller.forward(from: AmityStorySingleSegmentTimerElement.currentValue).whenComplete(() {
          AmityStorySingleSegmentTimerElement.currentValue = 0.0;
          widget.onTimerFinished();
        });
      }
      if (widget.shouldPauseTimer) {
        controller.value = AmityStorySingleSegmentTimerElement.currentValue;
        controller.stop();
      } else {
        if (AmityStorySingleSegmentTimerElement.currentValue == -1) {
          AmityStorySingleSegmentTimerElement.currentValue = 0.0;
          controller.forward(from: AmityStorySingleSegmentTimerElement.currentValue).whenComplete(() {
            AmityStorySingleSegmentTimerElement.currentValue = 0.0;
            widget.onTimerFinished();
          });
        } else {
          AmityStorySingleSegmentTimerElement.currentValue = (AmityStorySingleSegmentTimerElement.currentValue == 1.0) ? 0.0 : AmityStorySingleSegmentTimerElement.currentValue;
          controller.forward(from: AmityStorySingleSegmentTimerElement.currentValue).whenComplete(() {
            AmityStorySingleSegmentTimerElement.currentValue = 0.0;
            widget.onTimerFinished();
          });
        }
      }
    } else {
      controller.value = widget.isAlreadyFinished ? 1.0 : 0.0;
    }

    super.initState();
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
