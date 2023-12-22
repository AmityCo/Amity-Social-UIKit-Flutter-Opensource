import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/social/user_follow_screen.dart';
import 'package:amity_uikit_beta_service/viewmodel/follower_following_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/amity_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import '../social/global_feed.dart';
import 'edit_profile.dart';

class UserProfileScreen extends StatefulWidget {
  final AmityUser amityUser;
  bool? isEnableAppbar = true;
  UserProfileScreen({Key? key, required this.amityUser, this.isEnableAppbar})
      : super(key: key);
  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    Provider.of<UserFeedVM>(context, listen: false)
        .initUserFeed(widget.amityUser);
  }

  String getFollowingStatusString(AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return "Follow";
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return "Pending";
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return "Following";
    } else {
      return "Miss Type";
    }
  }

  Color getFollowingStatusColor(AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.grey;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Color getFollowingStatusTextColor(AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else {
      return Colors.red;
    }
  }

  AmityUser getAmityUser() {
    if (widget.amityUser.userId == AmityCoreClient.getCurrentUser().userId) {
      return Provider.of<AmityVM>(context).currentamityUser!;
    } else {
      return widget.amityUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    var isCurrentUser =
        AmityCoreClient.getCurrentUser().userId == widget.amityUser.userId;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
      elevation: 0,
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;

    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      return RefreshIndicator(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onRefresh: (() async {
          vm.initUserFeed(widget.amityUser);
        }),
        child: Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: widget.isEnableAppbar ?? true ? myAppBar : null,
            body: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: vm.scrollcontroller,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 10),
                    // height: bheight * 0.4,
                    child: LayoutBuilder(
                      builder: (context, constraints) => Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChangeNotifierProvider(
                                                    create: (context) =>
                                                        FollowerVM(),
                                                    child: FollowScreen(
                                                      key: UniqueKey(),
                                                      user: widget.amityUser,
                                                    ))));
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          vm.amityMyFollowInfo.followerCount
                                              .toString(),
                                          style: theme.textTheme.headline6),
                                      Text(
                                        'Followers',
                                        style:
                                            theme.textTheme.subtitle2!.copyWith(
                                          color: theme.hintColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FadedScaleAnimation(
                                    child: getAvatarImage(
                                        isCurrentUser
                                            ? Provider.of<AmityVM>(
                                                context,
                                              ).currentamityUser?.avatarUrl
                                            : widget.amityUser.avatarUrl,
                                        radius: 50)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        vm.amityMyFollowInfo.followingCount
                                            .toString(),
                                        style: theme.textTheme.headline6),
                                    Text(
                                      "Following",
                                      style:
                                          theme.textTheme.subtitle2!.copyWith(
                                        color: theme.hintColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 10, top: 10),
                            child: Text(
                              getAmityUser().displayName ?? "",
                              style: theme.textTheme.headline6,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 10),
                            child: Text(
                              getAmityUser().description ?? "",
                              style: theme.textTheme.subtitle2!.copyWith(
                                color: theme.hintColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // const SizedBox(
                          //   height: 12,
                          // ),
                          AmityCoreClient.getCurrentUser().userId ==
                                  widget.amityUser.userId
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreen(
                                                          user:
                                                              vm.amityUser!)));
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Provider.of<
                                                              AmityUIConfiguration>(
                                                          context)
                                                      .primaryColor,
                                                  style: BorderStyle.solid,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white),
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: Text(
                                            "Edit Profile",
                                            style: theme.textTheme.subtitle2!
                                                .copyWith(
                                              color: Provider.of<
                                                          AmityUIConfiguration>(
                                                      context)
                                                  .primaryColor,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // GestureDetector(
                                    //   onTap: () {},
                                    //   child: Container(
                                    //     width: constraints.maxWidth * 0.35,
                                    //     decoration: BoxDecoration(
                                    //         border: Border.all(
                                    //             color: Provider.of<
                                    //                         AmityUIConfiguration>(
                                    //                     context)
                                    //                 .primaryColor,
                                    //             style: BorderStyle.solid,
                                    //             width: 1),
                                    //         borderRadius:
                                    //             BorderRadius.circular(10),
                                    //         color: Colors.white),
                                    //     padding: const EdgeInsets.fromLTRB(
                                    //         10, 10, 10, 10),
                                    //     child: Text(
                                    //       "Messages",
                                    //       style: theme.textTheme.subtitle2!
                                    //           .copyWith(
                                    //         color: Provider.of<
                                    //                     AmityUIConfiguration>(
                                    //                 context)
                                    //             .primaryColor,
                                    //         fontSize: 12,
                                    //       ),
                                    //       textAlign: TextAlign.center,
                                    //     ),
                                    //   ),
                                    // ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: vm.amityMyFollowInfo.id == null
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Provider.of<
                                                                  AmityUIConfiguration>(
                                                              context)
                                                          .primaryColor,
                                                      style: BorderStyle.solid,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                child: Text(
                                                  "",
                                                  textAlign: TextAlign.center,
                                                  style: theme
                                                      .textTheme.subtitle2!
                                                      .copyWith(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            : FadeAnimation(
                                                child: StreamBuilder<
                                                        AmityUserFollowInfo>(
                                                    stream: vm.amityMyFollowInfo
                                                        .listen.stream,
                                                    initialData:
                                                        vm.amityMyFollowInfo,
                                                    builder:
                                                        (context, snapshot) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          vm.followButtonAction(
                                                              widget.amityUser,
                                                              snapshot.data!
                                                                  .status);
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: getFollowingStatusTextColor(
                                                                      snapshot
                                                                          .data!
                                                                          .status),
                                                                  style:
                                                                      BorderStyle
                                                                          .solid,
                                                                  width: 1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: getFollowingStatusColor(
                                                                  snapshot.data!
                                                                      .status)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(10,
                                                                  10, 10, 10),
                                                          child: Text(
                                                            getFollowingStatusString(
                                                                snapshot.data!
                                                                    .status),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: theme
                                                                .textTheme
                                                                .subtitle2!
                                                                .copyWith(
                                                              color: getFollowingStatusTextColor(
                                                                  snapshot.data!
                                                                      .status),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                          // const SizedBox(height: 20),
                          // TabBar(
                          //   controller: _tabController,
                          //   isScrollable: true,
                          //   indicatorColor:
                          //       Provider.of<AmityUIConfiguration>(context)
                          //           .primaryColor,
                          //   indicatorSize: TabBarIndicatorSize.label,
                          //   tabs: [
                          //     Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Text(
                          //         "Posts",
                          //         style: theme.textTheme.bodyText1,
                          //       ),
                          //     ),
                          //     Text(
                          //       "Story",
                          //       style: theme.textTheme.bodyText1,
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                  // TabBarView(
                  //   controller: _tabController,
                  //   children: [
                  vm.amityMyFollowInfo.status != AmityFollowStatus.ACCEPTED &&
                          vm.amityUser!.userId != AmityCoreClient.getUserId()
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: bheight * 0.3,
                                    child: const Center(
                                        child: Text("This account is Private")),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : vm.amityPosts.isEmpty
                          ? Container(
                              color: Colors.grey[200],
                              width: 100,
                              height: bheight - 400,
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: vm.amityPosts.length,
                              itemBuilder: (context, index) {
                                // var post = vm.amityPosts[index];
                                return StreamBuilder<AmityPost>(
                                    stream: vm.amityPosts[index].listen.stream,
                                    initialData: vm.amityPosts[index],
                                    builder: (context, snapshot) {
                                      return PostWidget(
                                        showCommunity: false,
                                        showlatestComment: true,
                                        post: snapshot.data!,
                                        theme: theme,
                                        postIndex: index,
                                      );
                                    });
                              },
                            )

                  //   Container(),
                  // ],
                  // ),
                ],
              ),
            )),
      );
    });
  }
}
