import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/community_member_page.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import 'edit_community.dart';
import 'global_feed.dart';

class PendingFeddScreen extends StatefulWidget {
  final AmityCommunity community;
  final bool isFromFeed;

  const PendingFeddScreen(
      {Key? key, required this.community, this.isFromFeed = false})
      : super(key: key);

  @override
  PendingFeddScreenState createState() => PendingFeddScreenState();
}

class PendingFeddScreenState extends State<PendingFeddScreen> {
  @override
  void initState() {
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
                Text(community.postsCount.toString(),
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
            Column(
              children: [
                Text(
                  community.membersCount.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                const Text('members',
                    style: TextStyle(fontSize: 16, color: Color(0xff898E9E)))
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final mediaQuery = MediaQuery.of(context);
    //final bHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return Consumer<CommuFeedVM>(builder: (__, vm, _) {
      return StreamBuilder<AmityCommunity>(
          stream: widget.community.listen.stream,
          builder: (context, snapshot) {
            var community = snapshot.data ?? widget.community;

            var feedWidget = FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: RefreshIndicator(
                color: Provider.of<AmityUIConfiguration>(context).primaryColor,
                onRefresh: () async {
                  // Call your method to refresh the list here.
                  // For example, you might want to refresh the community feed.
                  await Provider.of<CommuFeedVM>(context, listen: false)
                      .initAmityCommunityFeed(widget.community.communityId!);
                  await Provider.of<CommuFeedVM>(context, listen: false)
                      .initAmityPendingCommunityFeed(
                          widget.community.communityId!,
                          AmityFeedType.REVIEWING);
                },
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.grey[200],
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: vm.getCommunityPendingPosts().length,
                      itemBuilder: (context, index) {
                        return StreamBuilder<AmityPost>(
                            key: Key(
                                vm.getCommunityPendingPosts()[index].postId!),
                            stream: vm
                                .getCommunityPendingPosts()[index]
                                .listen
                                .stream,
                            initialData: vm.getCommunityPendingPosts()[index],
                            builder: (context, snapshot) {
                              return PostWidget(
                                  showCommunity: false,
                                  showlatestComment: true,
                                  isFromFeed: false,
                                  post: snapshot.data!,
                                  theme: theme,
                                  postIndex: index,
                                  feedType: FeedType.pending,
                                  showAcceptOrRejectButton:
                                      community.hasPermission(
                                    AmityPermission.REVIEW_COMMUNITY_POST,
                                  ));
                            });
                      },
                    ),
                  ),
                ),
              ),
            );

            return Scaffold(
                appBar: AppBar(
                  elevation: 0.0,
                  title: Text(
                      "Pending posts (${vm.getCommunityPendingPosts().length})",
                      style: Provider.of<AmityUIConfiguration>(context)
                          .titleTextStyle),
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                ),
                backgroundColor: Colors.grey[200],
                body: feedWidget);
          });
    });
  }
}
