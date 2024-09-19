import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryCommentCountElement extends StatelessWidget {
  final String count;
  final Function onClick;
  const AmityStoryCommentCountElement({
    super.key,
    required this.onClick,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: const BoxDecoration(
          color: Color(0xff292B32),
          borderRadius: BorderRadius.all(
            Radius.circular(
              100,
            ),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/Icons/ic_message_bubble_gray.svg",
              package: 'amity_uikit_beta_service',
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 8),
            Text(
              count,
              style: const TextStyle(
                fontFamily: "SF Pro Text",
                color: Colors.white,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }
}
