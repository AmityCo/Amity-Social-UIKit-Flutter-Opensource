import 'package:flutter/widgets.dart';

class BounceAnimator {
  final TickerProvider vsync;
  final Duration duration;
  late AnimationController controller;
  final ValueNotifier<int?> animatedIndex = ValueNotifier<int?>(null);

  BounceAnimator(this.vsync,
      {this.duration = const Duration(milliseconds: 200)}) {
    controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
        animatedIndex.value = null;
      }
    });
  }

  Animation<double> get animation => controller;

  void animateItem(int index) {
    animatedIndex.value = index;
    controller.forward(from: 0.0);
  }

  void dispose() {
    controller.dispose();
    animatedIndex.dispose();
  }
}
