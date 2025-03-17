import 'package:flutter/widgets.dart';

class BottomToTopAnimatedRoute extends PageRouteBuilder {
  final Widget widget;

  BottomToTopAnimatedRoute(this.widget)
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var tween = Tween(begin: begin, end: end);
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}