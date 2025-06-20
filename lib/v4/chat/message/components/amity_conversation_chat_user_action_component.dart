import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AmityConversationChatUserActionComponent extends NewBaseComponent {
  final AmityUser user;
  final bool isMute;
  final bool isUserBlocked;
  final Function()? onMuteToggleTap;
  final Function()? onReportUserTap;
  final Function()? onBlockToggleTap;

  AmityConversationChatUserActionComponent({
    Key? key,
    required this.user,
    required this.isMute,
    required this.isUserBlocked,
    this.onMuteToggleTap,
    this.onReportUserTap,
    this.onBlockToggleTap,
  }) : super(key: key, componentId: 'chat_user_action');

  @override
  Widget buildComponent(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 32),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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

          // Mute/Unmute option
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              if (onMuteToggleTap != null) {
                onMuteToggleTap!();
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
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      isMute
                          ? 'assets/Icons/amity_ic_chat_unmute.svg'
                          : 'assets/Icons/amity_ic_chat_mute.svg',
                      package: 'amity_uikit_beta_service',
                      width: 24,
                      height: 24,
                      colorFilter:
                          ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isMute
                          ? 'Turn on notifications'
                          : 'Turn off notifications',
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Report user option
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              if (onReportUserTap != null) {
                onReportUserTap!();
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
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                        user.isFlaggedByMe
                            ? 'assets/Icons/amity_ic_unreport_user_button.svg'
                            : 'assets/Icons/amity_ic_report_user_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.isFlaggedByMe ? 'Unreport user' : 'Report user',
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Block/Unblock user option
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              if (onBlockToggleTap != null) {
                onBlockToggleTap!();
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
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/Icons/amity_ic_block_user.svg',
                      package: 'amity_uikit_beta_service',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.baseColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isUserBlocked ? 'Unblock user' : 'Block user',
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
