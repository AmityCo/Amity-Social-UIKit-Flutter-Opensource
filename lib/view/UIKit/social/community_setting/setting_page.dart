import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/edit_community.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/notification_setting_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/post_review_settimg_page.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunitySettingPage extends StatelessWidget {
  final AmityCommunity community;

  const CommunitySettingPage({Key? key, required this.community})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityCommunity>(
        stream: community.listen.stream,
        builder: (context, snapshot) {
          var livecommunity = snapshot.data ?? community;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              title: Text(snapshot.data?.displayName ?? community.displayName!,
                  style: Provider.of<AmityUIConfiguration>(context)
                      .titleTextStyle),
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: ListView(
              children: [
                // Section 1: Basic Info
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Basic Info",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                ),
                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  4), // Adjust radius to your need
                              color: const Color(
                                  0xfff1f1f1), // Choose the color to fit your design
                            ),
                            child: const Icon(Icons.edit,
                                color: Color(0xff292B32))),
                        title: const Text("Edit Profile"),
                        trailing: const Icon(Icons.chevron_right,
                            color: Color(0xff292B32)),
                        onTap: () {
                          // Navigate to Edit Profile Page or perform an action
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  AmityEditCommunityScreen(livecommunity)));
                        },
                      ),
                ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              4), // Adjust radius to your need
                          color: const Color(
                              0xfff1f1f1), // Choose the color to fit your design
                        ),
                        child:
                            const Icon(Icons.people, color: Color(0xff292B32))),
                    title: const Text("Members"),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xff292B32)),
                    onTap: () {
                      // Navigate to Members Page or perform an action
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MemberManagementPage(
                              communityId: livecommunity.communityId!)));
                    }),
                ListTile(
                  leading: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            4), // Adjust radius to your need
                        color: const Color(
                            0xfff1f1f1), // Choose the color to fit your design
                      ),
                      child: const Icon(Icons.notifications,
                          color: Color(0xff292B32))),
                  title: const Text("Notifications"),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("On"), // Replace with dynamic text
                      Icon(Icons.chevron_right, color: Color(0xff292B32)),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Notifications Page or perform an action
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            NotificationSettingPage(community: livecommunity)));
                  },
                ),
                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Divider(
                          color: Color(0xffEBECEF),
                          thickness: 1,
                        ),
                      ),

                // Section 2: Community Permission
                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Community Permission",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 17)),
                      ),
                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  4), // Adjust radius to your need
                              color: const Color(
                                  0xfff1f1f1), // Choose the color to fit your design
                            ),
                            child: const Icon(Icons.fact_check,
                                color: Color(0xff292B32))),
                        title: const Text("Post Review"),
                        trailing: const Icon(Icons.chevron_right,
                            color: Color(0xff292B32)),
                        onTap: () {
                          // Navigate to Post Review Page or perform an action
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PostReviewPage(community: livecommunity)));
                        },
                      ),
                ListTile(
                  title: const Text(
                    "Leave Community",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.red),
                  ),
                  onTap: () async {
                    await ConfirmationDialog().show(
                        context: context,
                        title: "Leave community",
                        detailText:
                            "You won't no longer be able to post and interact in this community after leaving.",
                        onConfirm: () async {
                          // Perform Leave Community action
                          final communityVm =
                              Provider.of<CommunityVM>(context, listen: false);
                          communityVm.leaveCommunity(community.communityId!,
                              callback: (bool isSuccess) {
                            if (isSuccess) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Provider.of<MyCommunityVM>(context, listen: false)
                                  .initMyCommunity();
                            }
                          });
                        });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Divider(
                    color: Color(0xffEBECEF),
                    thickness: 1,
                  ),
                ),

                // Section 3: Close Community
                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : ListTile(
                        title: const Text(
                          "Close Community",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Closing this community will remove the community page and all its content and comments.",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff636878),
                            ),
                          ),
                        ),
                        onTap: () {
                          // handle tap

                          ConfirmationDialog().show(
                            context: context,
                            title: 'Close community?',
                            detailText:
                                'All members will be removed from the community. All posts, messages, reactions, and media shared in community will be deleted. This cannot be undone.',
                            leftButtonText: 'Cancel',
                            rightButtonText: 'Close',
                            onConfirm: () {
                              final communityVm = Provider.of<CommunityVM>(
                                  context,
                                  listen: false);
                              communityVm
                                  .deleteCommunity(community.communityId!,
                                      callback: (bool isSuccess) {
                                log("onConfirm");
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Provider.of<MyCommunityVM>(context,
                                        listen: false)
                                    .initMyCommunity();
                              });
                            },
                          );
                        },
                      ),

                !community.hasPermission(AmityPermission.EDIT_COMMUNITY)
                    ? const SizedBox()
                    : const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Divider(
                          color: Color(0xffEBECEF),
                          thickness: 1,
                        ),
                      ),
              ],
            ),
          );
        });
  }
}
