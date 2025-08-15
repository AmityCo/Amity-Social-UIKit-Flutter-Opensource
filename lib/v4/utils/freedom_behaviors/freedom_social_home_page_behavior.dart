import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/social_home_top_navigation_component.dart';
import 'package:flutter/material.dart';

class FreedomSocialHomePageBehavior {
  final bool showTopNavigation = true;
  final bool showExploreTab = true;
  final bool showMyCommunitiesTab = true;
  final bool useCustomTabButton = false;

  Widget buildCustomTabButton(
    AmityThemeColor theme,
    int selectedIndex,
    int index,
    String text,
    void Function() onPressed,
  ) => const SizedBox.shrink();

  Widget? buildCreatePostWidget(AmitySocialHomePageTab currentTab) => null;
}
