import 'package:flutter/material.dart';

class AmitySocialHomePageBehavior {
  final bool showTopNavigation = true;
  final bool showExploreTab = true;
  final bool showMyCommunitiesTab = true;

  final PreferredSizeWidget topNavigationReplacement = const PreferredSize(
    preferredSize: Size.zero,
    child: SizedBox.shrink(),
  );
}
