import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:flutter/material.dart';

enum NavigationEvent {
  showCommunityEdit,
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
      default:
        return;
    }
  }
}
