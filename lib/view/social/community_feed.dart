import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/utils/dynamicSilverAppBar.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/edit_community.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/setting_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_post_screenV2.dart';
import 'package:amity_uikit_beta_service/view/social/pending_page.dart';
import 'package:amity_uikit_beta_service/view/user/medie_component.dart';
import 'package:amity_uikit_beta_service/viewmodel/component_size_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/explore_page_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intrinsic_dimension/intrinsic_dimension.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'edit_community.dart';
import 'global_feed.dart';

class CommunityScreen extends StatefulWidget {
  final AmityCommunity community;
  final bool isFromFeed;

  const CommunityScreen(
      {Key? key, required this.community, this.isFromFeed = false})
      : super(key: key);

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
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
  }

  @override
  void dispose() {
    super.dispose();
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

  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final mediaQuery = MediaQuery.of(context);
    //final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer2<CommuFeedVM, CompoentSizeVM>(builder: (__, vm, sizeVM, _) {
      return StreamBuilder<AmityCommunity>(
          stream: widget.community.listen.stream,
          initialData: widget.community,
          builder: (context, snapshot) {
            var feedWidget = Container(
              color: Provider.of<AmityUIConfiguration>(context)
                  .appColors
                  .baseShade4,
              child: RefreshIndicator(
                color: Provider.of<AmityUIConfiguration>(context).primaryColor,
                onRefresh: () async {
                  // Call your method to refresh the list here.
                  // For example, you might want to refresh the community feed.
                  Provider.of<CommuFeedVM>(context, listen: false)
                      .getPostCount(widget.community);
                  Provider.of<CommuFeedVM>(context, listen: false)
                      .getReviewingPostCount(widget.community);
                  await Provider.of<CommuFeedVM>(context, listen: false)
                      .initAmityCommunityFeed(widget.community.communityId!);
                  await Provider.of<CommuFeedVM>(context, listen: false)
                      .initAmityPendingCommunityFeed(
                          widget.community.communityId!,
                          AmityFeedType.REVIEWING);
                },
                child: ListView.builder(
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
                ),
              ),
            );

            var tablist = [
              feedWidget,
              MediaGalleryPage(
                galleryFeed: GalleryFeed.community,
                onRefresh: () async {},
              )
            ];
            return Scaffold(
                floatingActionButton: (snapshot.data!.isJoined!)
                    ? FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context2) => AmityCreatePostV2Screen(
                                    community: snapshot.data!,
                                  )));
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .getPostCount(widget.community);
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .getReviewingPostCount(widget.community);
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .initAmityCommunityFeed(
                                  widget.community.communityId!);
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .initAmityCommunityImageFeed(
                                  widget.community.communityId!);
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .initAmityCommunityVideoFeed(
                                  widget.community.communityId!);
                          Provider.of<CommuFeedVM>(context, listen: false)
                              .initAmityPendingCommunityFeed(
                                  widget.community.communityId!,
                                  AmityFeedType.REVIEWING);
                        },
                        backgroundColor:
                            Provider.of<AmityUIConfiguration>(context)
                                .primaryColor,
                        child: Provider.of<AmityUIConfiguration>(context)
                            .iconConfig
                            .postIcon(iconSize: 28, color: Colors.white),
                      )
                    : null,
                backgroundColor: Provider.of<AmityUIConfiguration>(context)
                    .appColors
                    .baseBackground,
                body: Stack(
                  children: [
                    IntrinsicDimension(
                        listener: (context, width, height, startOffset) {
                      Provider.of<CompoentSizeVM>(context, listen: false)
                          .setCommunityDetailSectionSize(height);
                    }, builder: (_, __, ___, ____) {
                      return CommunityDetailComponent(
                        community: snapshot.data!,
                      );
                    }),
                    DefaultTabController(
                      length: 2,
                      child: NestedScrollView(
                        controller: vm.scrollcontroller,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            DynamicSliverAppBar(
                              // expandedHeight:
                              //     sizeVM.getCommunityDetailSectionSize(),
                              shadowColor: Colors.white,
                              elevation: 0,
                              surfaceTintColor: Colors.transparent,
                              backgroundColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .baseBackground,
                              floating: false,
                              pinned: true,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .appColors
                                          .base,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              flexibleSpace: CommunityDetailComponent(
                                community: snapshot.data!,
                              ),

                              actions: [
                                // Text(
                                //     "${sizeVM.getCommunityDetailSectionSize()}"),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context2) =>
                                                  CommunitySettingPage(
                                                    community: snapshot.data!,
                                                  )));
                                    },
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .base,
                                    ))
                              ],
                              bottom: PreferredSize(
                                preferredSize: const Size.fromHeight(25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .baseBackground,
                                        child: TabBar(
                                          tabAlignment: TabAlignment.start,
                                          controller: _tabController,
                                          isScrollable: true,
                                          dividerColor:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .appColors
                                                  .baseBackground,
                                          labelColor:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .appColors
                                                  .primary,
                                          indicatorColor:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
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
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                            controller: _tabController, children: tablist),
                      ),
                    ),
                  ],
                ));
          });
    });
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
    return !widget.community.hasPermission(AmityPermission.EDIT_COMMUNITY)
        ? widget.community.isJoined!
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
              mainAxisSize: MainAxisSize.min, // To wrap the content of the row
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
              mainAxisSize: MainAxisSize.min, // To wrap the content of the row
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Text("${Provider.of<CommuFeedVM>(context).postCount}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    )),
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
              onTap: () {
                // Navigate to Members Page or perform an action
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MemberManagementPage(
                        communityId: widget.community.communityId!)));
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          color: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground,
          height: 120,
        ),
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
                              image: NetworkImage(widget.community.avatarImage!
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
                                  : widget.community.categories![0]?.name ?? ""
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
                      ? const SizedBox(
                          height: 60,
                        )
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
    );
  }
}
