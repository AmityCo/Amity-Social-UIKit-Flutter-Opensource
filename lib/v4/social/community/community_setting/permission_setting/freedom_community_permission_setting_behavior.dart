import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/element/setting_radio_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/permission_setting/post/bloc/community_post_permission_page_bloc.dart';
import 'package:flutter/cupertino.dart';

class FreedomCommunityPermissionSettingBehavior {
  String? Function(BuildContext context, String key)? phrase;

  Future<RadioButtonSetting> Function({
    required AmityCommunity community,
    required void Function(CommunityPostPermissionPageState) emit,
    required CommunityPostPermissionPageState state,
  })? initialPostPermissionSetting;

  Future<void> Function(AmityCommunity community, RadioButtonSetting setting)?
      savePostPermission;

  void Function(BuildContext context)? onSaveSuccess;

  Widget Function(BuildContext context, bool isChanged)? buildSaveButton;
}
