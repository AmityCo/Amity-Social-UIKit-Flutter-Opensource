import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:flutter/material.dart';

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color? color;

  const SkeletonText(
      {Key? key,
      required this.width,
      this.color = Colors.black,
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
  final Color? color;

  const SkeletonImage(
      {Key? key,
      required this.width,
      required this.height,
      this.color = Colors.black,
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

// Note:
// Refactor SkeletonImage & SkeletonText with this SkeletonCircle & SkeletonRectangle in codebase.
class SkeletonCircle extends BaseElement {
  final double size;

  SkeletonCircle({Key? key, this.size = 56})
      : super(key: key, elementId: "skeleton_circle");

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: theme.baseColorShade4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size),
        ),
      ),
    );
  }
}

class SkeletonRectangle extends BaseElement {
  final double width;
  final double height;

  SkeletonRectangle({Key? key, this.width = 200, this.height = 12})
      : super(key: key, elementId: "skeleton_rectangle");

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: theme.baseColorShade4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height),
        ),
      ),
    );
  }
}
