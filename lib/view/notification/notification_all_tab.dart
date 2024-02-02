import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/view/social/user_pending_request_component.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/notification_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/pending_request_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/configuration_viewmodel.dart';

class NotificationAllTabScreen extends StatefulWidget {
  const NotificationAllTabScreen({super.key});

  @override
  State<NotificationAllTabScreen> createState() =>
      _NotificationAllTabScreenState();
}

class _NotificationAllTabScreenState extends State<NotificationAllTabScreen> {
  @override
  void initState() {
    log("init NotificationVM");
    Provider.of<NotificationVM>(context, listen: false).initVM();
    Provider.of<PendingVM>(context, listen: false).getMyPendingRequestList();
    super.initState();
  }

  String followRequestStringBuilder(List<AmityFollowRelationship> pendingList) {
    var emptyDisplayname = "Empty Name";
    var suffix = " request to follow you";
    var prefixString = "";
    if (pendingList.length == 1) {
      prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname;
    } else if (pendingList.length == 2) {
      prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname;
      prefixString +=
          " and ${prefixString = pendingList[1].sourceUser?.displayName ?? emptyDisplayname}";
    } else if (pendingList.length == 3) {
      prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname;
      prefixString +=
          ", ${prefixString = pendingList[1].sourceUser?.displayName ?? emptyDisplayname}";
      prefixString +=
          ", and ${prefixString = pendingList[2].sourceUser?.displayName ?? emptyDisplayname}";
    } else if (pendingList.length > 3) {
      prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname;
      prefixString +=
          ", ${prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname}";
      prefixString = pendingList[0].sourceUser?.displayName ?? emptyDisplayname;
      prefixString += ", and ${pendingList.length - 2} others";
    } else {
      prefixString = "${pendingList.length}";
    }
    return prefixString + suffix;
  }

  String getDateTime(int epochTime) {
    var dateTime = DateTime.fromMicrosecondsSinceEpoch(epochTime * 1000);

    var result = GetTimeAgo.parse(
      dateTime,
    );

    if (result == "0 seconds ago") {
      return "just now";
    } else {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<NotificationVM>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await vm.updateNotification();
                },
                child: vm.notificationsObject == null
                    ? Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Expanded(
                                  child: Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor,
                                ),
                              ))
                            ],
                          ))
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Provider.of<PendingVM>(context, listen: true)
                                    .pendingRequestList
                                    .isEmpty
                                ? const SizedBox()
                                : FadeAnimation(
                                    child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const AmityPendingScreen()));
                                    },
                                    child: Card(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.only(
                                            left: 16, right: 10),
                                        // leading: GestureDetector(
                                        //   onTap: () {
                                        //     Navigator.of(context).push(MaterialPageRoute(
                                        //         builder: (_) =>
                                        //             const AmityPendingScreen()));
                                        //   },
                                        //   child: FadedScaleAnimation(
                                        //       child: getAvatarImage(
                                        //           notificationItem!.actors![0].imageUrl)),
                                        // ),
                                        title: RichText(
                                          text: TextSpan(
                                            style: theme.textTheme.titleMedium!
                                                .copyWith(
                                              letterSpacing: 0.5,
                                            ),
                                            children: [
                                              TextSpan(
                                                  text: "Follow Request",
                                                  style: theme
                                                      .textTheme.titleSmall!
                                                      .copyWith(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(
                                          followRequestStringBuilder(
                                              Provider.of<PendingVM>(context,
                                                      listen: true)
                                                  .pendingRequestList),
                                          style: theme.textTheme.titleSmall!
                                              .copyWith(
                                            fontSize: 9,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                      ),
                                    ),
                                  )),
                            Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  vm.notificationsObject?.data?.isEmpty ?? false
                                      ? ""
                                      : "This month",
                                  style: theme.textTheme.titleLarge,
                                )),
                            vm.notificationsObject?.data?.isEmpty ?? false
                                ? const Center(
                                    child: Text("Notification box is empty!"))
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        vm.notificationsObject?.data?.length ??
                                            0,
                                    itemBuilder: (context, index) {
                                      var notificationItem =
                                          vm.notificationsObject?.data?[index];
                                      return FadeAnimation(
                                        child: Card(
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 16, right: 10),
                                            leading: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            UserProfileScreen(
                                                              amityUser:
                                                                  AmityCoreClient
                                                                      .getCurrentUser(),
                                                              amityUserId:
                                                                  AmityCoreClient
                                                                      .getUserId(),
                                                            )));
                                              },
                                              child: FadedScaleAnimation(
                                                  child: getAvatarImage(
                                                      notificationItem!
                                                          .actors![0]
                                                          .imageUrl)),
                                            ),
                                            title: RichText(
                                              text: TextSpan(
                                                style: theme
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                  letterSpacing: 0.5,
                                                ),
                                                children: [
                                                  TextSpan(
                                                      text: vm
                                                          .prefixStringBuilder(
                                                              notificationItem
                                                                      .actors ??
                                                                  []),
                                                      style: theme
                                                          .textTheme.titleSmall!
                                                          .copyWith(
                                                              fontSize: 12)),
                                                  TextSpan(
                                                      text:
                                                          " ${vm.verbStringBuilder(
                                                        notificationItem.verb!,
                                                      )} ",
                                                      style: TextStyle(
                                                          color: theme
                                                              .primaryColor,
                                                          fontSize: 12)),
                                                  TextSpan(
                                                      text: vm.suffixStringBuilder(
                                                          notificationItem
                                                              .verb!,
                                                          notificationItem
                                                              .targetDisplayName),
                                                      style: theme
                                                          .textTheme.titleSmall!
                                                          .copyWith(
                                                        fontSize: 12,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            subtitle: Text(
                                              getDateTime(vm
                                                  .notificationsObject!
                                                  .data![index]
                                                  .lastUpdate!),
                                              style: theme.textTheme.titleSmall!
                                                  .copyWith(
                                                fontSize: 9,
                                                color: theme.hintColor,
                                              ),
                                            ),
                                            trailing: notificationItem
                                                        .targetImageUrl ==
                                                    null
                                                ? null
                                                : Container(
                                                    margin:
                                                        const EdgeInsets.all(0),
                                                    child: AspectRatio(
                                                      aspectRatio: 1 / 1,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7),
                                                        child: FadeInImage(
                                                          image: NetworkImage(
                                                            notificationItem
                                                                    .targetImageUrl ??
                                                                "",
                                                          ),
                                                          placeholder:
                                                              const AssetImage(
                                                                  "assets/images/placeholder_image.png"), // Update with your local asset
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
