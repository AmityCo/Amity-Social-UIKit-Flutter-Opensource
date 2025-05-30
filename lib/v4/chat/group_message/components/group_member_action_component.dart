import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A component that displays action options for group members.
/// 
/// This component is displayed when a user taps on a member's action button
/// in the group members list. It provides options to manage member roles
/// (promote/demote moderator), ban users, and remove members from the group.
class GroupMemberActionComponent extends NewBaseComponent {
  final AmityUser user;
  final bool isCurrentUserModerator;
  final bool isUserModerator;
  final bool isBannedUser;
  final Function()? onRemoveTap;
  final Function()? onModeratorToggleTap;
  final Function()? onBanUserTap;
  final Function()? onUnbanUserTap;

  GroupMemberActionComponent({
    Key? key,
    required this.user,
    required this.isCurrentUserModerator,
    required this.isUserModerator,
    this.isBannedUser = false,
    this.onRemoveTap,
    this.onModeratorToggleTap,
    this.onBanUserTap,
    this.onUnbanUserTap,
  }) : super(key: key, componentId: 'group_member_action');

  @override
  Widget buildComponent(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 32),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Handle bar at the top
          Container(
            width: double.infinity,
            height: 36,
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: theme.baseColorShade3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // If user is banned, only show the unban option
          if (isBannedUser)
            // Unban user option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onUnbanUserTap != null) {
                  onUnbanUserTap!();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_ban_group_member_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Unban user',
                      style: AmityTextStyle.bodyBold(theme.baseColor),

                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Moderator toggle option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onModeratorToggleTap != null) {
                  onModeratorToggleTap!();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_promote_group_member_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isUserModerator ? 'Demote from moderator' : 'Promote to moderator',
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                  ],
                ),
              ),
            ),
            
            // Ban user option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onBanUserTap != null) {
                  onBanUserTap!();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_ban_group_member_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ban user',
                      style: AmityTextStyle.bodyBold(theme.baseColor),

                    ),
                  ],
                ),
              ),
            ),
            
            // Remove from group option
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (onRemoveTap != null) {
                  onRemoveTap!();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_remove_member_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(theme.alertColor, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Remove from group',
                      style: AmityTextStyle.bodyBold(theme.alertColor),

                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}