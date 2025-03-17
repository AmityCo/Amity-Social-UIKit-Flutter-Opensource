import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:amity_uikit_beta_service/view/user/edit_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSettingPage extends StatelessWidget {
  final AmityUser amityUser;
  final AmityUserFollowInfo amityMyFollowInfo;
  const UserSettingPage({
    Key? key,
    required this.amityUser,
    required this.amityMyFollowInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityUserFollowInfo>(
        stream: amityMyFollowInfo.listen.stream,
        initialData: amityMyFollowInfo,
        builder: (context, snapshot) {
          return ThemeConfig(
            child: Scaffold(
              backgroundColor: Provider.of<AmityUIConfiguration>(context)
                  .appColors
                  .baseBackground,
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                elevation: 0.0,
                title: Text("Setting",
                    style: Provider.of<AmityUIConfiguration>(context)
                        .titleTextStyle
                        .copyWith(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base)),
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              body: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Basic info",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base)),
                  ),
                  amityUser.userId == AmityCoreClient.getCurrentUser().userId
                      ? ListTile(
                          trailing: const Icon(Icons.chevron_right),
                          leading: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    4), // Adjust radius to your need
                                color: const Color(
                                    0xfff1f1f1), // Choose the color to fit your design
                              ),
                              child: Icon(Icons.edit,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base)),
                          title: Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(user: amityUser)));
                          },
                        )
                      : const SizedBox(),
                  amityUser.userId == AmityCoreClient.getUserId()
                      ? const SizedBox()
                      : snapshot.data!.status == AmityFollowStatus.BLOCKED
                          ? const SizedBox()
                          : snapshot.data!.status == AmityFollowStatus.NONE
                              ? ListTile(
                                  leading: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            4), // Adjust radius to your need
                                        color: const Color(
                                            0xfff1f1f1), // Choose the color to fit your design
                                      ),
                                      child: const Icon(Icons.person_remove,
                                          color: Color(0xff292B32))),
                                  title: const Text(
                                    "Follow",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<UserFeedVM>(context,
                                            listen: false)
                                        .followButtonAction(
                                            amityUser,
                                            Provider.of<UserFeedVM>(context,
                                                    listen: false)
                                                .amityMyFollowInfo
                                                .status);
                                  })
                              : ListTile(
                                  leading: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            4), // Adjust radius to your need
                                        color: const Color(
                                            0xfff1f1f1), // Choose the color to fit your design
                                      ),
                                      child: Icon(Icons.person_remove,
                                          color:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .appColors
                                                  .base)),
                                  title: Text(
                                    "Unfollow",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .base,
                                    ),
                                  ),
                                  onTap: () {
                                    Provider.of<UserFeedVM>(context,
                                            listen: false)
                                        .unfollowUser(
                                      amityUser,
                                    );
                                  }),
                  amityUser.userId == AmityCoreClient.getCurrentUser().userId
                      ? const SizedBox()
                      : amityUser.isFlaggedByMe
                          ? ListTile(
                              leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        4), // Adjust radius to your need
                                    color: const Color(
                                        0xfff1f1f1), // Choose the color to fit your design
                                  ),
                                  child: const Icon(Icons.flag,
                                      color: Color(0xff292B32))),
                              title: Text(
                                "Unreport User",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base,
                                ),
                              ),
                              onTap: () {
                                // Navigate to Members Page or perform an action
                                Provider.of<UserVM>(context, listen: false)
                                    .reportOrUnReportUser(amityUser);
                              })
                          : ListTile(
                              leading: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        4), // Adjust radius to your need
                                    color: const Color(
                                        0xfff1f1f1), // Choose the color to fit your design
                                  ),
                                  child: Icon(Icons.flag,
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .base)),
                              title: Text(
                                "Report User",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base,
                                ),
                              ),
                              onTap: () {
                                // Navigate to Members Page or perform an action
                                Provider.of<UserVM>(context, listen: false)
                                    .reportOrUnReportUser(
                                  amityUser,
                                );
                              }),
                  amityUser.userId == AmityCoreClient.getCurrentUser().userId
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
                              child: Icon(Icons.person_off,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base)),
                          title: Text(
                            snapshot.data!.status == AmityFollowStatus.BLOCKED
                                ? "Unblock"
                                : "Block User",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base,
                            ),
                          ),
                          onTap: () {
                            // Navigate to Members Page or perform an action
                            if (snapshot.data!.status !=
                                AmityFollowStatus.BLOCKED) {
                              Provider.of<UserFeedVM>(context, listen: false)
                                  .blockUser(amityUser.userId!, () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              });
                            } else {
                              Provider.of<UserFeedVM>(context, listen: false)
                                  .unBlockUser(
                                amityUser.userId!,
                              );
                            }
                          }),
                  const Divider()
                ],
              ),
            ),
          );
        });
  }
}
