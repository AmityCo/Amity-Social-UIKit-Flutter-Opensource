import 'package:amity_uikit_beta_service/v4/chat/notification_preference/notification_preference_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class GroupNotificationPreferencePageSample {

  /* begin_sample_code
    gist_id: d18cd250e57e540a741279fc99868194
    filename: GroupNotificationPreferencePageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Configure notification preferences for a group chat
    */
  Widget groupNotificationPreferencePage() {
    // Create a channel for this example
    final AmityChannel channel = AmityChannel();
    channel.channelId = 'your-channel-id';
    
    return AmityGroupNotificationPreferencePage(
      channel: channel,
    );
  }
  /* end_sample_code */

}
