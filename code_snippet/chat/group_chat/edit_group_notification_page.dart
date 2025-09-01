import 'package:amity_uikit_beta_service/v4/chat/edit_group_notification/amity_edit_group_notification_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class EditGroupNotificationPageSample {

  /* begin_sample_code
    gist_id: d24187561d91e880d3f999d1d9db4eb4
    filename: EditGroupNotificationPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Edit notification settings for a group chat
    */
  Widget editGroupNotificationPage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';

    return AmityEditGroupNotificationPage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
