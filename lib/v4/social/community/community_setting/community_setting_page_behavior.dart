import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class AmityCommunitySettingPageBehavior {
   String? Function(BuildContext context, String key)? settingItemTitle;

  void Function(
    BuildContext context, {
    required AmityCommunity community,
  })? showLeaveCommunityDialog;

  void backToSocialHomePage(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  bool shouldShowLeave(AmityCommunity community) {
    return true;
  }
}
