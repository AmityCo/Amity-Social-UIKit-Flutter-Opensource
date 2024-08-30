import 'package:flutter/material.dart';

class AmityStoryGradientRingElement extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final bool isIndeterminate;
  const AmityStoryGradientRingElement(
      {super.key, required this.colors, required this.child , required this.isIndeterminate});

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
    )..repeat();
    if(!widget.isIndeterminate){
      _controller.stop();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
