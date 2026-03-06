import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

enum NavigationEvent {
  showCommunityEdit,
  showUserProfile,
}

class NavigationProvider extends ChangeNotifier {
  void handleNavigation(BuildContext context, {required NavigationEvent event, Map<String, dynamic>? params}) {
    switch (event) {
      case NavigationEvent.showCommunityEdit:
        // Default implementation does not handle this event
        var mode = params?['mode'] as EditMode;
        Navigator.of(context)
            .push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => AmityCommunitySetupPage(mode: mode)));
        return;
      case NavigationEvent.showUserProfile:
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
      default:
        return;
    }
  }
}
