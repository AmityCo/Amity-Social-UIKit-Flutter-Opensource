import 'package:amity_uikit_beta_service/v4/chat/group_setting/amity_group_setting_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class GroupSettingPageSample {

  /* begin_sample_code
    gist_id: 4505e481f1cd0c72b49b23bd1a3b67cb
    filename: GroupSettingPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Display and manage group chat settings
    */
  Widget groupSettingPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityGroupSettingPage(
      channel: channel,
      isModerator: false,
    );
  }
  /* end_sample_code */

}
