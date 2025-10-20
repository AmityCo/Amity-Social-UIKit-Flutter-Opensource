import 'package:flutter/widgets.dart';

class BounceAnimator {
  final TickerProvider vsync;
  final Duration duration;
  late AnimationController controller;
  final ValueNotifier<int?> animatedIndex = ValueNotifier<int?>(null);
  int _bounceCount = 0;
  static const int _maxBounces = 4; // 2 times back and forth = 4 bounces total

  BounceAnimator(this.vsync,
      {this.duration = const Duration(milliseconds: 80)}) {
    controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bounceCount++;
        if (_bounceCount < _maxBounces) {
          controller.reverse();
        } else {
          // Animation sequence complete, reset state
          _bounceCount = 0;
          animatedIndex.value = null;
        }
      } else if (status == AnimationStatus.dismissed) {
        _bounceCount++;
        if (_bounceCount < _maxBounces) {
          controller.forward();
        } else {
          // Animation sequence complete, reset state
          _bounceCount = 0;
          animatedIndex.value = null;
        }
      }
    });
  }

  Animation<double> get animation => controller;

  void animateItem(int index) {
    _bounceCount = 0; // Reset bounce count
    animatedIndex.value = index;
    controller.forward(from: 0.0);
  }

  void dispose() {
    controller.dispose();
    animatedIndex.dispose();
  }
}
