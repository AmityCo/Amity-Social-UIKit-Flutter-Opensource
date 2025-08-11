import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AmitySocialHomePageBehavior {
  final bool showTopNavigation = true;
  final bool showExploreTab = true;
  final bool showMyCommunitiesTab = true;

  final PreferredSizeWidget topNavigationReplacement = const PreferredSize(
    preferredSize: Size.zero,
    child: SizedBox.shrink(),
  );

  final Widget Function(
    AmityThemeColor theme,
    int selectedIndex,
    int index,
    String text,
    void Function() onPressed,
  )? buildCustomTabButton = null;
}
