import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatListEmptyState extends StatelessWidget {
  final AmityThemeColor theme;
  final bool isGroupChatList;

  const ChatListEmptyState({
    super.key,
    required this.theme,
    this.isGroupChatList = false,
  });

  @override
  Widget build(BuildContext context) {
    // Multi-tone artwork, so it cannot be tinted: the atom swaps the whole
    // illustration by mode.
    return AmityEmptyState(
      asset: 'assets/Icons/amity_ic_chat_empty_state.svg',
      assetDark: 'assets/Icons/amity_ic_chat_empty_state_dark.svg',
      title: context.l10n.chat_empty_title,
      description: context.l10n.chat_empty_description,
      action: newChatButton(context),
    );
  }

  Widget newChatButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isGroupChatList) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmitySelectGroupMemberPage()),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmityChannelCreateConversationPage()),
          );
        }
      },
      icon: SvgPicture.asset(
        'assets/Icons/amity_ic_plus_button.svg',
        package: 'amity_uikit_beta_service',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          context.amityToken(
              AmityColorToken.iconMainButtonDefaultFilledPrimaryEnabled),
          BlendMode.srcIn,
        ),
      ),
      label: Text(context.l10n.chat_create_new,
        style: AmityTextStyle.bodyBold(context.amityToken(
            AmityColorToken.textMainButtonDefaultFilledPrimaryEnabled)),
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: context.amityToken(
            AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled),
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
