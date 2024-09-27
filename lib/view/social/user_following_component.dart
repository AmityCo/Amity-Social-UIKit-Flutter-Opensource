import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/bottom_sheet.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/follower_following_viewmodel.dart';

class AmityFollowingScreen extends StatefulWidget {
  final String userId;

  const AmityFollowingScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AmityFollowingScreen> createState() =>
      _AmityFollowingScreenScreenState();
}

class _AmityFollowingScreenScreenState extends State<AmityFollowingScreen> {
  @override
  void initState() {
    Provider.of<FollowerVM>(context, listen: false)
        .getFollowingListof(userId: widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowerVM>(builder: (context, vm, _) {
      final theme = Theme.of(context);
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowingListof(userId: widget.userId);
          },
          child: ListView.builder(
            controller: vm.followingScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: vm.getFollowingList.length,
            itemBuilder: (context, index) {
              return StreamBuilder<AmityFollowRelationship>(
                  // key: Key(vm.getFollowRelationships[index].targetUserId! +
                  //     vm.getFollowRelationships[index].targetUserId!),
                  stream: vm.getFollowingList[index].listen.stream,
                  initialData: vm.getFollowingList[index],
                  builder: (context, snapshot) {
                    if (widget.userId ==
                        AmityCoreClient.getCurrentUser().userId) {
                      return ListTile(
                        onTap: () async {
                          if (snapshot.data!.targetUserId! ==
                                  AmityCoreClient.getCurrentUser().userId &&
                              Provider.of<AmityUIConfiguration>(context,
                                      listen: false)
                                  .customUserProfileNavigate) {
                            Provider.of<AmityUIConfiguration>(context,
                                    listen: false)
                                .onUserProfile(context);
                          } else {
                            if (snapshot.data!.targetUserId! ==
                                    AmityCoreClient.getCurrentUser().userId &&
                                Provider.of<AmityUIConfiguration>(context,
                                        listen: false)
                                    .customUserProfileNavigate) {
                              Provider.of<AmityUIConfiguration>(context,
                                      listen: false)
                                  .onUserProfile(context);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                      create: (context) => UserFeedVM(),
                                      child: UserProfileScreen(
                                        amityUser: snapshot.data!.targetUser,
                                        amityUserId:
                                            snapshot.data!.targetUserId!,
                                      ))));
                            }
                          }
                        },
                        trailing: GestureDetector(
                            onTap: () {
                              showOptionsBottomSheet(
                                  context, snapshot.data!.targetUser!);
                              Provider.of<FollowerVM>(context, listen: false)
                                  .getFollowingListof(userId: widget.userId);
                            },
                            child: const Icon(Icons.more_horiz)),
                        title: Row(
                          children: [
                            GestureDetector(
                              child: getAvatarImage(vm
                                          .getFollowingList[index]
                                          .targetUser!
                                          .metadata?['profilePublicImageUrl'] ==
                                      null
                                  ? vm.getFollowingList[index].targetUser
                                      ?.avatarUrl
                                  : vm.getFollowingList[index].targetUser
                                              ?.metadata?[
                                          'profilePublicImageUrl'] ??
                                      ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.getFollowingList[index].targetUser!
                                            .displayName ??
                                        "displayname not found",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListTile(
                        onTap: () async {
                          if (snapshot.data!.targetUserId! ==
                                  AmityCoreClient.getCurrentUser().userId &&
                              Provider.of<AmityUIConfiguration>(context,
                                      listen: false)
                                  .customUserProfileNavigate) {
                            Provider.of<AmityUIConfiguration>(context,
                                    listen: false)
                                .onUserProfile(context);
                          } else {
                            if (snapshot.data!.targetUserId! ==
                                    AmityCoreClient.getCurrentUser().userId &&
                                Provider.of<AmityUIConfiguration>(context,
                                        listen: false)
                                    .customUserProfileNavigate) {
                              Provider.of<AmityUIConfiguration>(context,
                                      listen: false)
                                  .onUserProfile(context);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                      create: (context) => UserFeedVM(),
                                      child: UserProfileScreen(
                                        amityUser: snapshot.data!.targetUser,
                                        amityUserId:
                                            snapshot.data!.targetUserId!,
                                      ))));
                            }
                          }
                        },
                        trailing: GestureDetector(
                            onTap: () {
                              showOptionsBottomSheet(
                                  context, snapshot.data!.targetUser!);
                              Provider.of<FollowerVM>(context, listen: false)
                                  .getFollowingListof(userId: widget.userId);
                            },
                            child: const Icon(Icons.more_horiz)),
                        title: Row(
                          children: [
                            GestureDetector(
                              child: FutureBuilder<bool>(
                                future: AmityUIConfiguration.isFollowing(vm
                                        .getFollowingList[index]
                                        .targetUser!
                                        .userId ??
                                    ''),
                                builder: (BuildContext context,
                                    AsyncSnapshot<bool> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return getAvatarImage(
                                        ''); // You can display a loading placeholder or empty avatarUrl
                                  } else if (vm.getFollowingList[index]
                                              .targetUser!.userId ==
                                          AmityCoreClient.getCurrentUser()
                                              .userId &&
                                      vm.getFollowingList[index].targetUser
                                                  ?.metadata?[
                                              'profilePublicImageUrl'] !=
                                          null) {
                                    return getAvatarImage(vm
                                        .getFollowingList[index]
                                        .targetUser
                                        ?.metadata?['profilePublicImageUrl']);
                                  } else if (vm.getFollowingList[index]
                                              .targetUser!.userId ==
                                          AmityCoreClient.getCurrentUser()
                                              .userId &&
                                      vm.getFollowingList[index].targetUser
                                                  ?.metadata?[
                                              'profilePublicImageUrl'] ==
                                          null) {
                                    return getAvatarImage(vm
                                        .getFollowingList[index]
                                        .targetUser
                                        ?.avatarUrl);
                                  } else if (snapshot.hasError) {
                                    return getAvatarImage(
                                        ''); // Handle error case, possibly by showing a default avatar
                                  } else {
                                    final isFollowing = snapshot.data ?? false;
                                    final avatarUrl = isFollowing
                                        ? vm.getFollowingList[index].targetUser
                                            ?.avatarUrl
                                        : vm.getFollowingList[index].targetUser
                                                    ?.metadata?[
                                                'profilePublicImageUrl'] ??
                                            '';

                                    return getAvatarImage(avatarUrl);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.getFollowingList[index].targetUser!
                                            .displayName ??
                                        "displayname not found",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // return Text(snapshot.data!.status.toString());
                  });
            },
          ),
        ),
      );
    });
  }
}
