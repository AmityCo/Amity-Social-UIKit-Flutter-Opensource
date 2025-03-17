import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunityJoinButton extends BaseElement {
  final AmityCommunity community;

  AmityCommunityJoinButton({Key? key, required this.community})
      : super(elementId: 'community_join_button', key: key);

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 10,
        left: 12,
        right: 16,
        bottom: 10,
      ),
      decoration: ShapeDecoration(
        color: theme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: GestureDetector(
        onTap: () {
          context
            .read<CommunityProfileBloc>()
            .add(CommunityProfileEventJoining(communityId: community.communityId!));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_plus_button.svg',
                      package: 'amity_uikit_beta_service',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Join',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
