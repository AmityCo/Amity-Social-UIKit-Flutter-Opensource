import 'package:flutter/material.dart';

class AmityBodyGestureBox extends StatelessWidget {
  final Function(bool) onTap;
  final Function(bool) onHold;
  final Function onSwipeUp;
  final Function onSwipeDown;
  const AmityBodyGestureBox(
      {super.key,
      required this.onTap,
      required this.onHold,
      required this.onSwipeUp,
      required this.onSwipeDown});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        
      },
    );
  }
}
