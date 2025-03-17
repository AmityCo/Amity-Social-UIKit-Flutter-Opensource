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

class AmityFollowerScreen extends StatefulWidget {
  final String userId;

  const AmityFollowerScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AmityFollowerScreen> createState() => _AmityFollowerScreenState();
}

class _AmityFollowerScreenState extends State<AmityFollowerScreen> {
  @override
  void initState() {
    Provider.of<FollowerVM>(context, listen: false)
        .getFollowerListOf(userId: widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowerVM>(builder: (context, vm, _) {
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowerListOf(userId: widget.userId);
          },
          child: vm.getFollowerList.isEmpty
              ? const Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // CircularProgressIndicator(
                          //   color: Provider.of<AmityUIConfiguration>(context)
                          //       .primaryColor,
                          // )
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: vm.followerScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.getFollowerList.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<AmityFollowRelationship>(
                        // key: Key(vm.getFollowRelationships[index].sourceUserId! +
                        //     vm.getFollowRelationships[index].targetUserId!),
                        stream: vm.getFollowerList[index].listen.stream,
                        initialData: vm.getFollowerList[index],
                        builder: (context, snapshot) {
                          return StreamBuilder<AmityFollowRelationship>(
                              stream: vm.getFollowerList[index].listen.stream,
                              initialData: vm.getFollowerList[index],
                              builder: (context, snapshot) {
                                return ListTile(
                                  onTap: () async {
                                    if (snapshot.data!.sourceUserId! ==
                                            AmityCoreClient.getCurrentUser()
                                                .userId &&
                                        Provider.of<AmityUIConfiguration>(
                                                context,
                                                listen: false)
                                            .customUserProfileNavigate) {
                                      Provider.of<AmityUIConfiguration>(context,
                                              listen: false)
                                          .onUserProfile(context);
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                      create: (context) =>
                                                          UserFeedVM(),
                                                      child: UserProfileScreen(
                                                          amityUser:
                                                              snapshot.data!
                                                                  .sourceUser!,
                                                          amityUserId: snapshot
                                                              .data!
                                                              .sourceUserId!))));
                                    }
                                  },
                                  trailing: GestureDetector(
                                      onTap: () {
                                        showOptionsBottomSheet(context,
                                            snapshot.data!.sourceUser!);
                                        Provider.of<FollowerVM>(context,
                                                listen: false)
                                            .getFollowerListOf(
                                                userId: widget.userId);
                                      },
                                      child: const Icon(Icons.more_horiz)),
                                  title: Row(
                                    children: [
                                      GestureDetector(
                                          child: GestureDetector(
                                        child: FutureBuilder<bool>(
                                          future:
                                              AmityUIConfiguration.isFollowing(
                                                  vm.getFollowerList[index]
                                                          .sourceUser!.userId ??
                                                      ''),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<bool> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return getAvatarImage(
                                                  ''); // You can display a loading placeholder or empty avatarUrl
                                            } else if (vm.getFollowerList[index]
                                                        .sourceUser!.userId ==
                                                    AmityCoreClient
                                                            .getCurrentUser()
                                                        .userId &&
                                                vm.getFollowerList[index]
                                                            .sourceUser?.metadata?[
                                                        'profilePublicImageUrl'] ==
                                                    null) {
                                              return getAvatarImage(vm
                                                  .getFollowerList[index]
                                                  .sourceUser
                                                  ?.avatarUrl);
                                            } else if (snapshot.hasError) {
                                              return getAvatarImage(
                                                  ''); // Handle error case, possibly by showing a default avatar
                                            } else {
                                              final isFollowing =
                                                  snapshot.data ?? false;
                                              final avatarUrl = isFollowing
                                                  ? (vm.getFollowerList[index].sourceUser?.avatarUrl ??
                                                  (vm.getFollowerList[index].sourceUser?.metadata?['profilePublicImageUrl'] ?? ''))
                                                  : (vm.getFollowerList[index].sourceUser?.metadata?['profilePublicImageUrl'] ?? '');


                                              return getAvatarImage(avatarUrl);
                                            }
                                          },
                                        ),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vm
                                                      .getFollowerList[index]
                                                      .sourceUser!
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
                              });
                          // return Text(snapshot.data!.status.toString());
                        });
                  },
                ),
        ),
      );
    });
  }
}
