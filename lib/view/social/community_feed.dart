import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/edit_community.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/setting_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_post_screenV2.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'create_post_screen.dart';
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
      return const AssetImage("assets/images/user_placeholder.png");
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
          style: TextStyle(fontSize: 15),
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
                Text(community.postsCount.toString(),
                    style: TextStyle(fontSize: 16)),
                Text('posts',
                    style: TextStyle(fontSize: 16, color: Color(0xff898E9E)))
              ],
            ),
            Container(
              color: Color(0xffE5E5E5), // Divider color
              height: 20,
              width: 1,

              margin: EdgeInsets.symmetric(horizontal: 8),
            ),
            Column(
              children: [
                Text(
                  community.membersCount.toString(),
                  style: TextStyle(fontSize: 16),
                ),
                Text('members',
                    style: TextStyle(fontSize: 16, color: Color(0xff898E9E)))
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget communityDetailSection(AmityCommunity community) {
    return Column(
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
                      color: const Color(0xFFD9E5FC),
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
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                          community.displayName != null
                              ? community.displayName!
                              : "Community",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                  community.categories == null
                      ? SizedBox()
                      : Text(
                          community.displayName != null
                              ? community.categories!.isEmpty
                                  ? "no category"
                                  : community.categories![0]?.name ?? ""
                              : "",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                  SizedBox(
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
              communityInfo(community),
              SizedBox(
                height: 16,
              ),
              communityDescription(community),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: EditProfileButton(
                    community: community,
                  )),
                ],
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context2) => CommunitySettingPage(
                        community: widget.community,
                      )));
            },
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.black))
      ],
      elevation: 0,
    );
    final theme = Theme.of(context);
    //final mediaQuery = MediaQuery.of(context);
    //final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer<CommuFeedVM>(builder: (__, vm, _) {
      return StreamBuilder<AmityCommunity>(
          stream: widget.community.listen.stream,
          builder: (context, snapshot) {
            var community = snapshot.data ?? widget.community;
            return Scaffold(
              appBar: myAppBar,
              floatingActionButton: (community.isJoined!)
                  ? FloatingActionButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context2) => AmityCreatePostV2Screen(
                                  community: community,
                                )));
                      },
                      backgroundColor:
                          Provider.of<AmityUIConfiguration>(context)
                              .primaryColor,
                      child: Provider.of<AmityUIConfiguration>(context)
                          .iconConfig
                          .postIcon(iconSize: 28, color: Colors.white),
                    )
                  : null,
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                color: Provider.of<AmityUIConfiguration>(context).primaryColor,
                onRefresh: () async {
                  Provider.of<CommuFeedVM>(context, listen: false)
                      .initAmityCommunityFeed(community.communityId!);
                },
                child: FadedSlideAnimation(
                  beginOffset: const Offset(0, 0.3),
                  endOffset: const Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      controller: vm.scrollcontroller,
                      child: Column(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              // height: (bHeight - 120) * 0.4,
                              child: communityDetailSection(
                                  community ?? community)),
                          FadedSlideAnimation(
                            beginOffset: const Offset(0, 0.3),
                            endOffset: const Offset(0, 0),
                            slideCurve: Curves.linearToEaseOut,
                            child: Container(
                              color: Colors.grey[200],
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: vm.getCommunityPosts().length,
                                itemBuilder: (context, index) {
                                  return StreamBuilder<AmityPost>(
                                      key: Key(vm
                                          .getCommunityPosts()[index]
                                          .postId!),
                                      stream: vm
                                          .getCommunityPosts()[index]
                                          .listen
                                          .stream,
                                      initialData:
                                          vm.getCommunityPosts()[index],
                                      builder: (context, snapshot) {
                                        return PostWidget(
                                          showCommunity: false,
                                          showlatestComment: true,
                                          isFromFeed: true,
                                          post: snapshot.data!,
                                          theme: theme,
                                          postIndex: index,
                                          isCommunity: true,
                                        );
                                      });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
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
            ? SizedBox()
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
                        });
                      }).onError((error, stackTrace) {
                        log(error.toString());
                      });
                    }
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color:
                        Provider.of<AmityUIConfiguration>(context).primaryColor,
                    border: Border.all(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .primaryColor), // Grey border color
                    borderRadius: BorderRadius.circular(4), // Rounded corners
                  ),
                  child: Row(
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
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Color(0xffA5A9B5),
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
                      .editIcon(color: Colors.black),
                  SizedBox(width: 8.0), // Space between icon and text
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.black, // Text color
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
