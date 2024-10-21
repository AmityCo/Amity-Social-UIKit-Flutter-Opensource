import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/edit_community.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/post_review_settimg_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/story_comment_setting_page.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/explore_page_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
          return ThemeConfig(
            child: Scaffold(
              backgroundColor: Provider.of<AmityUIConfiguration>(context)
                  .appColors
                  .baseBackground,
              appBar: AppBar(
                backgroundColor: Provider.of<AmityUIConfiguration>(context)
                    .appColors
                    .baseBackground,
                elevation: 0.0,
                title: Text(
                    snapshot.data?.displayName ?? community.displayName!,
                    style: Provider.of<AmityUIConfiguration>(context)
                        .titleTextStyle
                        .copyWith(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base)),
                iconTheme: IconThemeData(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base),
              ),
              body: ListView(
                children: [
                  // Section 1: Basic Info
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Basic Info",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .base,
                        )),
                  ),
                  (!Provider.of<AmityUIConfiguration>(context)
                              .widgetConfig
                              .showEditProfile ||
                          !community
                              .hasPermission(AmityPermission.EDIT_COMMUNITY))
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
                              child: Icon(
                                Icons.edit,
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .base,
                              )),
                          title: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base),
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
                          child: Icon(Icons.people,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base)),
                      title: Text(
                        "Members",
                        style: TextStyle(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .base,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .base),
                      onTap: () {
                        // Navigate to Members Page or perform an action
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MemberManagementPage(
                                communityId: livecommunity.communityId!)));
                      }),
                  // ListTile(
                  //   leading: Container(
                  //       padding: const EdgeInsets.all(5),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(
                  //             4), // Adjust radius to your need
                  //         color: const Color(
                  //             0xfff1f1f1), // Choose the color to fit your design
                  //       ),
                  //       child: Icon(Icons.notifications,
                  //           color: Provider.of<AmityUIConfiguration>(context)
                  //               .appColors
                  //               .base)),
                  //   title: Text("Notifications",
                  //       style: TextStyle(
                  //         color: Provider.of<AmityUIConfiguration>(context)
                  //             .appColors
                  //             .base,
                  //       )),
                  //   trailing: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text("On",
                  //           style: TextStyle(
                  //             color: Provider.of<AmityUIConfiguration>(context)
                  //                 .appColors
                  //                 .base,
                  //           )), // Replace with dynamic text
                  //       Icon(Icons.chevron_right,
                  //           color: Provider.of<AmityUIConfiguration>(context)
                  //               .appColors
                  //               .base),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     // Navigate to Notifications Page or perform an action
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (context) =>
                  //             NotificationSettingPage(community: livecommunity)));
                  //   },
                  // ),
                  (!Provider.of<AmityUIConfiguration>(context)
                              .widgetConfig
                              .showPostReview ||
                          !community
                              .hasPermission(AmityPermission.EDIT_COMMUNITY))
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Divider(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .baseShade4,
                            thickness: 1,
                          ),
                        ),

                  // Section 2: Community Permission
                  (!Provider.of<AmityUIConfiguration>(context)
                              .widgetConfig
                              .showPostReview ||
                          !community
                              .hasPermission(AmityPermission.EDIT_COMMUNITY))
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Community Permission",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base)),
                        ),
                  (!Provider.of<AmityUIConfiguration>(context)
                              .widgetConfig
                              .showPostReview ||
                          !community
                              .hasPermission(AmityPermission.EDIT_COMMUNITY))
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
                              child: Icon(Icons.fact_check,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base)),
                          title: Text("Post Review",
                              style: TextStyle(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .base,
                              )),
                          trailing: Icon(Icons.chevron_right,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base),
                          onTap: () {
                            // Navigate to Post Review Page or perform an action
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    PostReviewPage(community: livecommunity)));
                          },
                        ),
                  !community.isJoined!
                      ? const SizedBox()
                      : ListTile(
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
                                  final communityVm = Provider.of<CommunityVM>(
                                      context,
                                      listen: false);
                                  communityVm
                                      .leaveCommunity(community.communityId!,
                                          callback: (bool isSuccess) {
                                    if (isSuccess) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Provider.of<MyCommunityVM>(context,
                                              listen: false)
                                          .initMyCommunity();

                                      Provider.of<ExplorePageVM>(context,
                                              listen: false)
                                          .getRecommendedCommunities();
                                    }
                                  });
                                });
                          },
                        ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Divider(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .baseShade4,
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
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Divider(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .baseShade4,
                            thickness: 1,
                          ),
                        ),
                ],
              ),
            ),
          );
        });
  }
}
