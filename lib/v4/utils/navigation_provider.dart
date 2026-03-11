import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

enum AmityNavigationEvent {
  showCommunityEdit,
  showUserProfile,
  showCreateChat,
}

class NavigationProvider extends ChangeNotifier {
  Future<void> handleNavigation(BuildContext context,
      {required AmityNavigationEvent event, Map<String, dynamic>? params}) async {
    switch (event) {
      case AmityNavigationEvent.showCommunityEdit:
        // Default implementation does not handle this event
        var mode = params?['mode'] as EditMode;
        Navigator.of(context)
            .push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => AmityCommunitySetupPage(mode: mode)));
        return;
      case AmityNavigationEvent.showUserProfile:
        var userId = params?['userId'] as String;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmityUserProfilePage(
              userId: userId,
            ),
          ),
        );
        return;
      case AmityNavigationEvent.showCreateChat:
        final isGroupChat = params?['isGroupChat'] as bool? ?? false;
        if (isGroupChat) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmitySelectGroupMemberPage()),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmityChannelCreateConversationPage()),
          );
        }
        return;
      default:
        return;
    }
  }
}
