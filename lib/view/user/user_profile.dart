import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/dynamicSilverAppBar.dart';
import 'package:amity_uikit_beta_service/view/social/user_follow_screen.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:amity_uikit_beta_service/view/user/user_setting.dart';
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
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.black,
          size: 24,
        ),
      ),
      elevation: 0,
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;

    return Consumer<UserFeedVM>(builder: (context, vm, _) {
      Widget buildPrivateAccountWidget(double bheight) {
        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: bheight * 0.3,
                    child: const Center(
                      child: Text(
                        "This account is Private",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffA5A9B5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      Widget buildNoPostsWidget(double bheight, BuildContext context) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: bheight - 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/Icon name.png",
                package: "amity_uikit_beta_service",
              ),
              const SizedBox(height: 12),
              const Text(
                "No post yet",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffA5A9B5)),
              ),
            ],
          ),
        );
      }

      Widget buildPostsList(BuildContext context) {
        return Container(
          color: Colors.grey[200],
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: vm.amityPosts.length,
            itemBuilder: (context, index) {
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
                },
              );
            },
          ),
        );
      }

      Widget buildContent(BuildContext context, double bheight) {
        if (vm.amityMyFollowInfo.status != AmityFollowStatus.ACCEPTED &&
            vm.amityUser!.userId != AmityCoreClient.getUserId()) {
          return buildPrivateAccountWidget(bheight);
        } else if (vm.amityPosts.isEmpty) {
          return buildNoPostsWidget(bheight, context);
        } else {
          return buildPostsList(
              context); // Placeholder for tab bar can be integrated here
        }
      }

      var tablist = [buildContent(context, bheight), const MediaGalleryPage()];
      return Scaffold(
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: Colors.white,
        //   leading: IconButton(
        //     icon: Icon(Icons.chevron_left, color: Colors.black),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ),
        backgroundColor: Colors.white,
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              var followWidget = Row(
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
                      padding: const EdgeInsets.only(),
                      child: vm.amityMyFollowInfo.id == null
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Provider.of<AmityUIConfiguration>(
                                            context)
                                        .primaryColor,
                                    style: BorderStyle.solid,
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Text(
                                "",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : StreamBuilder<AmityUserFollowInfo>(
                              stream: vm.amityMyFollowInfo.listen.stream,
                              initialData: vm.amityMyFollowInfo,
                              builder: (context, snapshot) {
                                return FadeAnimation(
                                    child: snapshot.data!.status ==
                                            AmityFollowStatus.ACCEPTED
                                        ? const SizedBox()
                                        : GestureDetector(
                                            onTap: () {
                                              vm.followButtonAction(
                                                  widget.amityUser,
                                                  snapshot.data!.status);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          getFollowingStatusTextColor(
                                                              snapshot.data!
                                                                  .status),
                                                      style: BorderStyle.solid,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color:
                                                      getFollowingStatusColor(
                                                          snapshot
                                                              .data!.status)),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Colors.white,
                                                    weight: 4,
                                                  ),
                                                  const SizedBox(
                                                    width: 2,
                                                  ),
                                                  Text(
                                                    getFollowingStatusString(
                                                        snapshot.data!.status),
                                                    textAlign: TextAlign.center,
                                                    style: theme
                                                        .textTheme.titleSmall!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          getFollowingStatusTextColor(
                                                              snapshot.data!
                                                                  .status),
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                              }),
                    ),
                  ),
                ],
              );
              return <Widget>[
                DynamicSliverAppBar(
                  shadowColor: Colors.white,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  floating: false,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: Column(
                    children: [
                      const SizedBox(height: 120),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 64,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FadedScaleAnimation(
                                      child: getAvatarImage(
                                          isCurrentUser
                                              ? Provider.of<AmityVM>(
                                                  context,
                                                ).currentamityUser?.avatarUrl
                                              : widget.amityUser.avatarUrl,
                                          radius: 32)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            getAmityUser().displayName ?? "",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.4),
                                          ),
                                          Row(
                                            children: [
                                              // Text('${  vm.amityMyFollowInfo.followerCount
                                              //     .toString()} Posts  '),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChangeNotifierProvider(
                                                                  create: (context) =>
                                                                      FollowerVM(),
                                                                  child:
                                                                      FollowScreen(
                                                                    key:
                                                                        UniqueKey(),
                                                                    user: widget
                                                                        .amityUser,
                                                                  ))));
                                                },
                                                child: Text(
                                                    '${vm.amityMyFollowInfo.followingCount.toString()} Following  '),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChangeNotifierProvider(
                                                                  create: (context) =>
                                                                      FollowerVM(),
                                                                  child:
                                                                      FollowScreen(
                                                                    key:
                                                                        UniqueKey(),
                                                                    user: widget
                                                                        .amityUser,
                                                                  ))));
                                                },
                                                child: Text(
                                                    '${vm.amityMyFollowInfo.followerCount.toString()} Followers'),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  Text(
                                    getAmityUser().description ?? "",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            AmityCoreClient.getCurrentUser().userId ==
                                    widget.amityUser.userId
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScreen(
                                                            user: vm
                                                                .amityUser!)));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        const Color(0xffA5A9B5),
                                                    style: BorderStyle.solid,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: Colors.white),
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.edit_outlined),
                                                Text(
                                                  "Edit Profile",
                                                  style: theme
                                                      .textTheme.titleSmall!
                                                      .copyWith(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : followWidget,
                          ],
                        ),
                      )
                    ],
                  ),
                  actions: [
                    vm.amityMyFollowInfo.id == null
                        ? const SizedBox()
                        : StreamBuilder<AmityUserFollowInfo>(
                            stream: vm.amityMyFollowInfo.listen.stream,
                            initialData: vm.amityMyFollowInfo,
                            builder: (context, snapshot) {
                              return IconButton(
                                icon: const Icon(Icons.more_horiz,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => UserSettingPage(
                                            amityMyFollowInfo: snapshot.data!,
                                            amityUser: widget.amityUser,
                                          )));
                                },
                              );
                            }),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: TabBar(
                              tabAlignment: TabAlignment.start,
                              controller: _tabController,
                              isScrollable: true,
                              labelColor: const Color(0xFF1054DE),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: const Color(0xFF1054DE),
                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Text',
                              ),
                              tabs: const [
                                Tab(text: "Timeline"),
                                Tab(text: "Gallery"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(controller: _tabController, children: tablist),
          ),
        ),
      );
    });
  }
}

    // TabBarView(
    //               controller: _tabController,
    //               children: tablist,
    //             ),