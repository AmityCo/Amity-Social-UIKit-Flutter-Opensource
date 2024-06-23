import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/edit_community.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/setting_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_post_screenV2.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/view/social/pending_page.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:amity_uikit_beta_service/viewmodel/explore_page_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'edit_community.dart';

class CommunityScreen extends StatefulWidget {
  final AmityCommunity community;
  final bool isFromFeed;

  const CommunityScreen(
      {Key? key, required this.community, this.isFromFeed = false})
      : super(key: key);

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityFeed(widget.community.communityId!);
    Provider.of<CommuFeedVM>(context, listen: false)
        .getPostCount(widget.community);
    Provider.of<CommuFeedVM>(context, listen: false)
        .getReviewingPostCount(widget.community);
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityImageFeed(widget.community.communityId!);
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityCommunityVideoFeed(widget.community.communityId!);
    Provider.of<CommuFeedVM>(context, listen: false)
        .initAmityPendingCommunityFeed(
            widget.community.communityId!, AmityFeedType.REVIEWING);

    super.initState();
    Provider.of<CommuFeedVM>(context, listen: false).userFeedTabController =
        TabController(
      length: 2,
      vsync: this,
    );
  }

  getAvatarImage(String? url) {
    if (url != null) {
      return NetworkImage(url);
    } else {
      return const AssetImage("assets/images/user_placeholder.png",
          package: "amity_uikit_beta_service");
    }
  }

  Widget communityDescription(AmityCommunity community) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          community.description ?? "",
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  void onCommunityOptionTap(
      CommunityFeedMenuOption option, AmityCommunity community) {
    switch (option) {
      case CommunityFeedMenuOption.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditCommunityScreen(community)));
        break;
      case CommunityFeedMenuOption.members:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                MemberManagementPage(communityId: community.communityId!)));
        break;
      default:
    }
  }

  Widget communityInfo(AmityCommunity community) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Text("${Provider.of<CommuFeedVM>(context).postCount}",
                    style: const TextStyle(fontSize: 16)),
                const Text('posts',
                    style: TextStyle(fontSize: 16, color: Color(0xff898E9E)))
              ],
            ),
            Container(
              color: const Color(0xffE5E5E5), // Divider color
              height: 20,
              width: 1,

              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Text(
                    community.membersCount.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(community.membersCount == 1 ? 'member' : 'members',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xff898E9E)))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.chevron_left,
          color: Provider.of<AmityUIConfiguration>(context).appColors.base,
          size: 24,
        ),
      ),
      elevation: 0,
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
    if (true) {
      return StreamBuilder<AmityCommunity>(
          stream: widget.community.listen.stream,
          initialData: widget.community,
          builder: (context, snapshot) {
            return AppScaffold(
              title: '',
              slivers: [
                Consumer<CommuFeedVM>(builder: (context, vm, _) {
                  return _StickyHeaderList(
                      index: 0,
                      theme: theme,
                      bheight: bheight,
                      profileSectionWidget: CommunityDetailComponent(
                        community: snapshot.data!,
                      ));
                }),
                _StickyHeaderList(
                  index: 1,
                  theme: theme,
                  bheight: bheight,
                ),
              ],
              amityCommunity: snapshot.data!,
            );
          });
    } else {
      return Scaffold(
        backgroundColor:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      );
    }
  }
}

class EditProfileButton extends StatefulWidget {
  final AmityCommunity community;

  const EditProfileButton({super.key, required this.community});

  @override
  State<EditProfileButton> createState() => _EditProfileButtonState();
}

class _EditProfileButtonState extends State<EditProfileButton> {
  @override
  Widget build(BuildContext context) {
    final hideEditProfile = !Provider.of<AmityUIConfiguration>(context)
            .widgetConfig
            .showEditProfile ||
        !widget.community.hasPermission(AmityPermission.EDIT_COMMUNITY);
    final hideJoinButton = !Provider.of<AmityUIConfiguration>(context)
            .widgetConfig
            .showJoinButton ||
        widget.community.isJoined!;

    return (hideEditProfile)
        ? (hideJoinButton)
            ? const SizedBox()
            : InkWell(
                onTap: () {
                  // Navigate to Edit Profile Page or perform an action
                  if (widget.community.isJoined != null) {
                    if (widget.community.isJoined!) {
                      AmitySocialClient.newCommunityRepository()
                          .leaveCommunity(widget.community.communityId!)
                          .then((value) {
                        setState(() {
                          widget.community.isJoined =
                              !(widget.community.isJoined!);
                          var explorePageVM = Provider.of<ExplorePageVM>(
                              context,
                              listen: false);
                          explorePageVM.getRecommendedCommunities();
                          explorePageVM.getTrendingCommunities();
                        });
                      }).onError((error, stackTrace) {
                        //handle error
                        log(error.toString());
                      });
                    } else {
                      AmitySocialClient.newCommunityRepository()
                          .joinCommunity(widget.community.communityId!)
                          .then((value) {
                        setState(() {
                          widget.community.isJoined =
                              !(widget.community.isJoined!);
                          var explorePageVM = Provider.of<ExplorePageVM>(
                              context,
                              listen: false);
                          explorePageVM.getRecommendedCommunities();
                          explorePageVM.getTrendingCommunities();
                          print(">>>>>>>>>>>>>>>callback");

                          var myCommunityList = Provider.of<MyCommunityVM>(
                              context,
                              listen: false);
                          myCommunityList.initMyCommunity();

                          for (var i in myCommunityList.amityCommunities) {
                            print(">>>>>>>>>>>>>>>${i.displayName}");
                          }
                          print(myCommunityList.amityCommunities);
                        });
                      }).onError((error, stackTrace) {
                        log(error.toString());
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color:
                        Provider.of<AmityUIConfiguration>(context).primaryColor,
                    border: Border.all(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .primaryColor), // Grey border color
                    borderRadius: BorderRadius.circular(4), // Rounded corners
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize:
                        MainAxisSize.min, // To wrap the content of the row
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.0), // Space between icon and text
                      Text(
                        "Join",
                        style: TextStyle(
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              )
        : InkWell(
            onTap: () {
              // Navigate to Edit Profile Page or perform an action
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      AmityEditCommunityScreen(widget.community)));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xffA5A9B5),
                ), // Grey border color
                borderRadius: BorderRadius.circular(4), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // To wrap the content of the row
                children: <Widget>[
                  Provider.of<AmityUIConfiguration>(context)
                      .iconConfig
                      .editIcon(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .base,
                      ),
                  const SizedBox(width: 8.0), // Space between icon and text
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base, // Text color
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class PedindingButton extends StatelessWidget {
  final AmityCommunity community;

  const PedindingButton({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return
        // Provider.of<CommuFeedVM>(context).getCommunityPendingPosts().isEmpty
        InkWell(
      onTap: () {
        // Navigate to Edit Profile Page or perform an action
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PendingFeddScreen(
                  community: community,
                )));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          border: Border.all(
            color:
                Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          ), // Grey border color
          borderRadius: BorderRadius.circular(4), // Rounded corners
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              // To wrap the content of the row
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 6,
                  color:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                ),
                const SizedBox(width: 8.0), // Space between icon and text
                Text(
                  "Pending posts",
                  style: TextStyle(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base, // Text color
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              // To wrap the content of the row
              children: <Widget>[
                Text(
                  !community
                          .hasPermission(AmityPermission.REVIEW_COMMUNITY_POST)
                      ? "Your posts are pending for review"
                      : "${Provider.of<CommuFeedVM>(context).reviewingPostCount} posts need approval",
                  style: TextStyle(
                    fontSize: 13,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base, // Text color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityDetailComponent extends StatefulWidget {
  final AmityCommunity community;

  const CommunityDetailComponent({super.key, required this.community});

  @override
  State<CommunityDetailComponent> createState() =>
      _CommunityDetailComponentState();
}

class _CommunityDetailComponentState extends State<CommunityDetailComponent> {
  Widget communityDescription(AmityCommunity community) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        Text(
          community.description ?? "",
          style: TextStyle(
            fontSize: 15,
            color: Provider.of<AmityUIConfiguration>(context).appColors.base,
          ),
        ),
      ],
    );
  }

  void onCommunityOptionTap(
      CommunityFeedMenuOption option, AmityCommunity community) {
    switch (option) {
      case CommunityFeedMenuOption.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditCommunityScreen(community)));
        break;
      case CommunityFeedMenuOption.members:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                MemberManagementPage(communityId: community.communityId!)));
        break;
      default:
    }
  }

  Widget communityInfo(AmityCommunity community) {
    late final Widget chatButton;
    if (community.metadata == null ||
        community.metadata!['communityId'] == null ||
        community.metadata!['communityId'] is! int) {
      chatButton = const SizedBox.shrink();
    } else {
      chatButton = Provider.of<AmityUIConfiguration>(context)
          .buildChatButton(community.metadata!['communityId'] as int);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Text(
                  "${Provider.of<CommuFeedVM>(context).postCount}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base,
                  ),
                ),
                const Text(
                  'posts',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff898E9E),
                  ),
                ),
              ],
            ),
            Container(
              color: const Color(0xffE5E5E5), // Divider color
              height: 20,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to Members Page or perform an action
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemberManagementPage(
                      communityId: widget.community.communityId!,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    community.membersCount.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                  ),
                  Text(
                    community.membersCount == 1 ? 'member' : 'members',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff898E9E),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            chatButton,
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      child: Wrap(
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .primaryShade3,
                        image: widget.community.avatarImage != null
                            ? DecorationImage(
                                image: NetworkImage(widget
                                    .community.avatarImage!
                                    .getUrl(AmityImageSize.LARGE)),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage("assets/images/IMG_5637.JPG",
                                    package: 'amity_uikit_beta_service'),
                                fit: BoxFit.cover),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              0.4), // Applying a 40% dark filter to the entire container
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        widget.community.isPublic!
                            ? const SizedBox()
                            : const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                        widget.community.isPublic!
                            ? const SizedBox()
                            : const SizedBox(
                                width: 7,
                              ),
                        Text(
                            widget.community.displayName != null
                                ? widget.community.displayName!
                                : "Community",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(
                          width: 7,
                        ),
                        widget.community.isOfficial!
                            ? Provider.of<AmityUIConfiguration>(context)
                                .iconConfig
                                .officialIcon(iconSize: 17, color: Colors.white)
                            : const SizedBox(),
                      ],
                    ),
                    widget.community.categories == null
                        ? const SizedBox()
                        : Text(
                            widget.community.displayName != null
                                ? widget.community.categories!.isEmpty
                                    ? "no category"
                                    : widget.community.categories![0]?.name ??
                                        ""
                                : "",
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                color: Colors.white)),
                    const SizedBox(
                      height: 16,
                    )
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                communityInfo(widget.community),
                const SizedBox(
                  height: 16,
                ),
                communityDescription(widget.community),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: EditProfileButton(
                      community: widget.community,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                !widget.community.isJoined!
                    ? const SizedBox()
                    : !widget.community.isPostReviewEnabled!
                        ? const SizedBox()
                        : Provider.of<CommuFeedVM>(context)
                                .getCommunityPendingPosts()
                                .isEmpty
                            ? const SizedBox(
                                height: 60,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: PedindingButton(
                                    community: widget.community,
                                  )),
                                ],
                              )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.text,
    required this.builder,
  }) : super(key: key);

  final String text;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: builder)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderList extends StatelessWidget {
  const _StickyHeaderList({
    Key? key,
    this.index,
    this.profileSectionWidget,
    required this.theme,
    required this.bheight,
  }) : super(key: key);

  final int? index;
  final Widget? profileSectionWidget;
  final ThemeData theme;
  final double bheight;
  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Header(
        index: index,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            if (index == 0) {
              return profileSectionWidget;
            } else {
              return Consumer<CommuFeedVM>(
                builder: (context, vm, _) {
                  Widget buildPrivateAccountWidget(double bheight) {
                    return SingleChildScrollView(
                      child: Container(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseShade4,
                        width: MediaQuery.of(context).size.width,
                        height: bheight - 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/privateIcon.png",
                              package: "amity_uikit_beta_service",
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "This account is private",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff292B32)),
                            ),
                            const Text(
                              "Follow this user to see all posts",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffA5A9B5)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  Widget buildNoPostsWidget(
                      double bheight, BuildContext context) {
                    return SingleChildScrollView(
                      child: Container(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseShade4,
                        width: MediaQuery.of(context).size.width,
                        height: bheight - 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/noPostYet.png",
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
                      ),
                    );
                  }

                  Widget buildContent(BuildContext context, double bheight) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: vm.getCommunityPosts().length,
                      itemBuilder: (context, index) {
                        return StreamBuilder<AmityPost>(
                            key: Key(vm.getCommunityPosts()[index].postId!),
                            stream: vm.getCommunityPosts()[index].listen.stream,
                            initialData: vm.getCommunityPosts()[index],
                            builder: (context, snapshot) {
                              return PostWidget(
                                isPostDetail: false,
                                showCommunity: false,
                                showlatestComment: true,
                                isFromFeed: true,
                                post: snapshot.data!,
                                theme: theme,
                                postIndex: index,
                                feedType: FeedType.community,
                              );
                            });
                      },
                    );
                  }

                  if (vm.userFeedTabController!.index == 0) {
                    return buildContent(context, bheight);
                  } else {
                    return MediaGalleryPage(
                      galleryFeed: GalleryFeed.community,
                      onRefresh: () {},
                    );
                  }
                },
              );
            }
          },
          childCount: 1,
        ),
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.title,
    required this.slivers,
    this.reverse = false,
    required this.amityCommunity,
  }) : super(key: key);

  final String title;
  final List<Widget> slivers;
  final bool reverse;
  final AmityCommunity amityCommunity;

  @override
  Widget build(BuildContext context) {
    return DefaultStickyHeaderController(
      child: ThemeConfig(
        child: Scaffold(
          backgroundColor:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          floatingActionButton: (Provider.of<AmityUIConfiguration>(context)
                      .widgetConfig
                      .showCommunityPostButton &&
                  (amityCommunity.onlyAdminCanPost == false) &&
                  amityCommunity.isJoined!)
              ? FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context2) => AmityCreatePostV2Screen(
                              community: amityCommunity,
                              feedType: FeedType.community,
                            )));
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .getPostCount(amityCommunity);
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .getReviewingPostCount(amityCommunity);
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .initAmityCommunityFeed(amityCommunity.communityId!);
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .initAmityCommunityImageFeed(
                            amityCommunity.communityId!);
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .initAmityCommunityVideoFeed(
                            amityCommunity.communityId!);
                    Provider.of<CommuFeedVM>(context, listen: false)
                        .initAmityPendingCommunityFeed(
                            amityCommunity.communityId!,
                            AmityFeedType.REVIEWING);
                  },
                  backgroundColor:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                  child: Provider.of<AmityUIConfiguration>(context)
                      .iconConfig
                      .postIcon(iconSize: 28, color: Colors.white),
                )
              : null,
          appBar: AppBar(
            backgroundColor: Provider.of<AmityUIConfiguration>(context)
                .appColors
                .baseBackground,
            scrolledUnderElevation: 0,
            title: Text(title),
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color:
                    Provider.of<AmityUIConfiguration>(context).appColors.base,
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Text(
              //     "${sizeVM.getCommunityDetailSectionSize()}"),
              if (Provider.of<AmityUIConfiguration>(context)
                  .widgetConfig
                  .showCommunityMoreButton)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context2) => CommunitySettingPage(
                          community: amityCommunity,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base,
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
            color: Provider.of<AmityUIConfiguration>(context).primaryColor,
            onRefresh: () async {
              // Call your method to refresh the list here.
              // For example, you might want to refresh the community feed.
              Provider.of<CommuFeedVM>(context, listen: false)
                  .getPostCount(amityCommunity);
              Provider.of<CommuFeedVM>(context, listen: false)
                  .getReviewingPostCount(amityCommunity);
              await Provider.of<CommuFeedVM>(context, listen: false)
                  .initAmityCommunityFeed(amityCommunity.communityId!);
              await Provider.of<CommuFeedVM>(context, listen: false)
                  .initAmityPendingCommunityFeed(
                      amityCommunity.communityId!, AmityFeedType.REVIEWING);
            },
            child: CustomScrollView(
              controller: Provider.of<CommuFeedVM>(context).scrollcontroller,
              slivers: slivers,
              reverse: reverse,
            ),
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    Key? key,
    this.index,
    this.title,
    this.color = Colors.lightBlue,
  }) : super(key: key);

  final String? title;
  final int? index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Consumer<CommuFeedVM>(builder: (context, vm, _) {
      return index == 0
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .baseBackground,
                      child: TabBar(
                        onTap: ((value) {
                          vm.changeTab();
                        }),
                        dividerColor: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseBackground,
                        tabAlignment: TabAlignment.start,
                        controller: vm.userFeedTabController,
                        isScrollable: true,
                        labelColor: Provider.of<AmityUIConfiguration>(context)
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
                          Tab(text: "Timeline"),
                          Tab(text: "Gallery"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
    });
  }
}
