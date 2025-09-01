import 'package:amity_uikit_beta_service/v4/chat/group_message/components/amity_group_member_action_component.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class GroupMemberActionComponentSample {

  /* begin_sample_code
    gist_id: 6ff090b5438ce1b806ec135f3c9311af
    filename: GroupMemberActionComponentSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Display action options for a group member
    */
  Widget groupMemberActionComponent() {
    // Create a user for this example
    final AmityUser user = AmityUser();
    
    return AmityGroupMemberActionComponent(
      user: user,
      isCurrentUserModerator: true,
      isSelectedUserModerator: false,
    );
  }
  /* end_sample_code */

}
