import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/social/community_feedV2.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchCommunitiesScreen extends StatefulWidget {
  const SearchCommunitiesScreen({super.key});

  @override
  _SearchCommunitiesScreenState createState() =>
      _SearchCommunitiesScreenState();
}

class _SearchCommunitiesScreenState extends State<SearchCommunitiesScreen> {
  @override
  void initState() {
    super.initState();

    Provider.of<SearchCommunityVM>(context, listen: false).clearSearch();
    Provider.of<UserVM>(context, listen: false).clearUserList();
  }

  var textcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchCommunityVM, UserVM>(
        builder: (context, vm, userVM, _) {
      var searchBar = Container(
        color:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textcontroller,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  hintText: 'Search',
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  fillColor: Colors.grey[3],
                  focusColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  Provider.of<SearchCommunityVM>(context, listen: false)
                      .initSearchCommunity(value.trim());
                  Provider.of<UserVM>(context, listen: false)
                      .initUserList(value.trim());
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "cancel",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base,
                  ),
                ),
              ),
            )
          ],
        ),
      );
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground,
          body: SafeArea(
            child: Stack(
              children: [
                textcontroller.text.isEmpty
                    ? const SizedBox()
                    : TabBarView(
                        children: [
                          vm.amityCommunities.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .primary,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  controller: vm.scrollcontroller,
                                  itemCount: vm.amityCommunities.length + 1,
                                  itemBuilder: (context, index) {
                                    // If it's the first item in the list, return the search bar
                                    if (index == 0) {
                                      return const SizedBox(height: 120);
                                    }
                                    // Otherwise, return the community widget
                                    return CommunityWidget(
                                      community: vm.amityCommunities[index - 1],
                                    );
                                  },
                                ),
                          userVM.getUserList().isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .primary,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  controller: userVM.scrollcontroller,
                                  itemCount: userVM.getUserList().length + 1,
                                  itemBuilder: (context, index) {
                                    // If it's the first item in the list, return the search bar
                                    if (index == 0) {
                                      return const SizedBox(height: 120);
                                    }
                                    // Otherwise, return the community widget
                                    return UserWidget(
                                        amityUser:
                                            userVM.getUserList()[index - 1]);
                                  },
                                ),
                        ],
                      ),
                Column(
                  children: [
                    searchBar,
                    textcontroller.text.isEmpty
                        ? const SizedBox()
                        : Container(
                            color: Colors.white,
                            child: TabBar(
                              dividerColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .baseBackground,
                              tabAlignment: TabAlignment.start,
                              isScrollable:
                                  true, // Ensure that the TabBar is scrollable

                              labelColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .primary,

                              indicatorColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .primary,

                              labelStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Text',
                              ),
                              tabs: const [
                                Tab(
                                  text: "Community",
                                ),
                                Tab(
                                  text: "User",
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CommunityWidget extends StatelessWidget {
  final AmityCommunity community;

  const CommunityWidget({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityCommunity>(
        stream: community.listen.stream,
        builder: (context, snapshot) {
          var communityStream = snapshot.data ?? community;
          return Card(
            color: Provider.of<AmityUIConfiguration>(context)
                .appColors
                .baseBackground,
            elevation: 0,
            child: ListTile(
              leading: (communityStream.avatarFileId != null)
                  ? CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          NetworkImage(communityStream.avatarImage!.fileUrl!),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .primaryShade3,
                          shape: BoxShape.circle),
                      child: const Icon(
                        Icons.group,
                        color: Colors.white,
                      ),
                    ),
              title: Row(
                children: [
                  if (!community.isPublic!) const Icon(Icons.lock, size: 16.0),
                  const SizedBox(width: 4.0),
                  Text(
                    communityStream.displayName ?? "Community",
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .base,
                        fontWeight: FontWeight.bold),
                  ),
                  community.isOfficial!
                      ? Padding(
                          padding: const EdgeInsets.only(left: 7.0),
                          child: Provider.of<AmityUIConfiguration>(context)
                              .iconConfig
                              .officialIcon(
                                  iconSize: 17,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor),
                        )
                      : const SizedBox(),
                ],
              ),
              subtitle: Text(
                communityStream.categories == null ||
                        communityStream.categories!.isEmpty
                    ? ""
                    : "${communityStream.categories![0]!.name}" ?? "Community",
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                          create: (context) => CommuFeedVM(),
                          child: CommunityScreen(
                            isFromFeed: true,
                            community: communityStream,
                          ),
                        )));
              },
            ),
          );
        });
  }
}

class UserWidget extends StatelessWidget {
  final AmityUser amityUser;

  const UserWidget({super.key, required this.amityUser});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityUser>(
        stream: amityUser.listen.stream,
        builder: (context, snapshot) {
          var userStream = snapshot.data ?? amityUser;
          return Card(
            color: Provider.of<AmityUIConfiguration>(context)
                .appColors
                .baseBackground,
            elevation: 0,
            child: ListTile(
              leading: (userStream.avatarFileId != null)
                  ? CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(userStream.avatarUrl!),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .primaryShade3,
                          shape: BoxShape.circle),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
              title: Row(
                children: [
                  // if (!amityUser.isPublic!) const Icon(Icons.lock, size: 16.0),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      userStream.displayName ?? "Community",
                      style: TextStyle(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .base,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => UserFeedVM(),
                        child: UserProfileScreen(
                          amityUser: amityUser,
                          amityUserId: amityUser.userId!,
                        ))));
              },
            ),
          );
        });
  }
}

class CommunityIconList extends StatelessWidget {
  final List<AmityCommunity> amityCommunites;

  const CommunityIconList({super.key, required this.amityCommunites});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Community',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            const Scaffold(body: MyCommunityPage()),
                      ));
                    },
                    child: Container(child: const Icon(Icons.chevron_right))),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            height: 90.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: amityCommunites.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.only(left: index != 0 ? 0 : 16),
                  child: CommunityIconWidget(
                      amityCommunity: amityCommunites[index]),
                );
              },
            ),
          ),
          Divider(
            color:
                Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          )
        ],
      ),
    );
  }
}

class CommunityIconWidget extends StatelessWidget {
  final AmityCommunity amityCommunity;

  const CommunityIconWidget({super.key, required this.amityCommunity});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityCommunity>(
        stream: amityCommunity.listen.stream,
        builder: (context, snapshot) {
          var communityStream = snapshot.data ?? amityCommunity;
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      CommunityScreen(community: communityStream)));
            },
            child: Container(
              width: 62,
              margin: const EdgeInsets.only(right: 4, bottom: 10),
              child: Column(
                children: [
                  Expanded(
                    child: (amityCommunity.avatarImage != null)
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(amityCommunity
                                .avatarImage!
                                .getUrl(AmityImageSize.SMALL)),
                          )
                        : Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .primaryShade3,
                                shape: BoxShape.circle),
                            child: const Icon(
                              Icons.group,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      !amityCommunity.isPublic!
                          ? const Icon(
                              Icons.lock,
                              size: 12,
                            )
                          : const SizedBox(),
                      Expanded(
                        child: Text(amityCommunity.displayName ?? "",
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
