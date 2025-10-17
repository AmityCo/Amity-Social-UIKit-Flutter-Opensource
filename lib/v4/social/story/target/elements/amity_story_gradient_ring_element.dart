import 'package:flutter/material.dart';

class AmityStoryGradientRingElement extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final bool isIndeterminate;
  final Color backgoundColor;
  const AmityStoryGradientRingElement(
      {super.key, required this.colors, required this.backgoundColor ,required this.child , required this.isIndeterminate});

  @override
  State<AmityStoryGradientRingElement> createState() =>
      _AmityStoryGradientRingElementState();
}

class _AmityStoryGradientRingElementState
    extends State<AmityStoryGradientRingElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _updateAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AmityStoryGradientRingElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isIndeterminate != widget.isIndeterminate) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    if (widget.isIndeterminate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 49,
      height: 49,
      child: Stack(
        children: [
          Center(
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: (widget.colors.length >= 2)
                      ? LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: widget.colors,
                        )
                      : null,
                  color: (widget.colors.length == 1)? widget.colors[0] : null,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 45,
              height: 45,
              padding: const EdgeInsets.all(2),
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgoundColor,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
