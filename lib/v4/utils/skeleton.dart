import 'package:flutter/material.dart';

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonText(
      {Key? key,
      required this.width,
      this.height = 8,
      this.borderRadius = const BorderRadius.all(Radius.circular(16))})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class SkeletonImage extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonImage(
      {Key? key,
      required this.width,
      required this.height,
      required this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
