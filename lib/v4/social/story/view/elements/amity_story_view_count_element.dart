import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryViewCountElement extends StatelessWidget {
  final String count;
  final Function onClick;
  const AmityStoryViewCountElement(
      {super.key, required this.count, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/Icons/ic_eye_gray.svg",
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
    );
  }
}
