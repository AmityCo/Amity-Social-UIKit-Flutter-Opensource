import 'package:flutter/material.dart';

class AmityCommunitySettingPageBehavior {
   String? Function(BuildContext context, String key)? settingItemTitle;

  void Function(
    BuildContext context, {
    required void Function(BuildContext context) onGoBack,
    required void Function(BuildContext context) onLeave,
    required String? communityName,
  })? showLeaveCommunityDialog;

  void backToSocialHomePage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
