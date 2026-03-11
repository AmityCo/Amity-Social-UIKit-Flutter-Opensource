import 'package:amity_uikit_beta_service/v4/utils/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommentTrayBehavior {
  void goToUserProfilePage(
    BuildContext context,
    String userId,
  ) {
    context
        .read<NavigationProvider>()
        .handleNavigation(context, event: AmityNavigationEvent.showUserProfile, params: {'userId': userId});
  }
}
