import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_create_group_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class CreateGroupChatPageSample {

  /* begin_sample_code
    gist_id: d4673ca431a1e9283312c0fbe6a70088
    filename: CreateGroupChatPageSample.dart
    asc_page: https://docs.social.plus/social-plus-uikit/uikit-v4/chat
    description: Create a new group chat with selected users
    */
  Widget createGroupChatPage() {
    // Create a list of users for this example
    final List<AmityUser> selectedUsers = [];

    return AmityCreateGroupChatPage(
      selectedUsers: selectedUsers,
    );
  }
  /* end_sample_code */

}
