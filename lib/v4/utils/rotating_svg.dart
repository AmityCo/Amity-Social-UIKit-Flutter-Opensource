import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RotatingSvgPicture extends StatefulWidget {
  final String iconAsset;
  final bool shouldRotate;

  RotatingSvgPicture({required this.iconAsset, required this.shouldRotate});

  @override
  _RotatingSvgPictureState createState() =>
      _RotatingSvgPictureState(shouldRotate: shouldRotate);
}

class _RotatingSvgPictureState extends State<RotatingSvgPicture>
    with SingleTickerProviderStateMixin {
  final bool shouldRotate;

  _RotatingSvgPictureState({required this.shouldRotate});

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Repeat the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldRotate) {
      return RotationTransition(
        turns: _controller,
        child: SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset(
            widget.iconAsset,
            package: 'amity_uikit_beta_service',
            width: 24,
            height: 20,
          ),
        ),
      );
    } else {
      return SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          widget.iconAsset,
          package: 'amity_uikit_beta_service',
          width: 24,
          height: 20,
        ),
      );
    }
  }
}
