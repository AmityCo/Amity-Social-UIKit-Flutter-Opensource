import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryReactionCountElement extends StatelessWidget {
  final String count;
  final bool isReactedByMe;
  final bool isCommunityJoined;
  final Function (bool) onClick;
  const AmityStoryReactionCountElement({
    super.key,
    required this.count,
    required this.onClick,
    required this.isReactedByMe,
    required this.isCommunityJoined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isCommunityJoined) {
          if(isReactedByMe){
            onClick(false);
          }else{
            onClick(true);
          }
          
        }
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
              isReactedByMe
                  ? "assets/Icons/ic_reaction_liked.svg"
                  : "assets/Icons/like.svg",
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
