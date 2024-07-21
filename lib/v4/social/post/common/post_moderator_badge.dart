import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommunityModeratorBadge extends StatelessWidget {
  const CommunityModeratorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.only(left: 4, right: 6),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFFD9E5FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            padding: const EdgeInsets.symmetric(vertical: 1.50),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 9,
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_community_moderator.svg',
                    package: 'amity_uikit_beta_service',
                    width: 16,
                    height: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Moderator',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF1054DE),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
