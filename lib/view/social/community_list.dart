import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import 'community_feed.dart';

class CommunityList extends StatefulWidget {
  final CommunityListType communityType;

  const CommunityList(this.communityType, {super.key});
  @override
  CommunityListState createState() => CommunityListState();
}

class CommunityListState extends State<CommunityList> {
  CommunityListType communityType = CommunityListType.recommend;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    communityType = widget.communityType;
    Future.delayed(Duration.zero, () {
      switch (communityType) {
        case CommunityListType.my:
          Provider.of<CommunityVM>(context, listen: false)
              .initAmityMyCommunityList();
          break;
        case CommunityListType.recommend:
          Provider.of<CommunityVM>(context, listen: false)
              .initAmityRecommendCommunityList();
          break;
        case CommunityListType.trending:
          Provider.of<CommunityVM>(context, listen: false)
              .initAmityTrendingCommunityList();
          break;
        default:
          Provider.of<CommunityVM>(context, listen: false)
              .initAmityMyCommunityList();
          break;
      }
    });
    super.initState();
  }

  List<AmityCommunity> getList() {
    switch (communityType) {
      case CommunityListType.my:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityMyCommunities();

      case CommunityListType.recommend:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityRecommendCommunities();

      case CommunityListType.trending:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityTrendingCommunities();

      default:
        return [];
    }
  }

  int getLength() {
    switch (communityType) {
      case CommunityListType.my:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityMyCommunities()
            .length;

      case CommunityListType.recommend:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityRecommendCommunities()
            .length;

      case CommunityListType.trending:
        return Provider.of<CommunityVM>(context, listen: false)
            .getAmityTrendingCommunities()
            .length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        AppBar().preferredSize.height;

    final theme = Theme.of(context);
    return Consumer<CommunityVM>(builder: (context, vm, _) {
      return Column(
        children: [
          Expanded(
            child: Container(
              height: bHeight,
              color: Colors.grey[200],
              child: FadedSlideAnimation(
                // ignore: sort_child_properties_last
                child: getLength() < 1
                    ? const Center()
                    // Center(
                    //     child: CircularProgressIndicator(
                    //       color: Provider.of<AmityUIConfiguration>(context)
                    //           .primaryColor,
                    //     ),
                    //   )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: getLength(),
                        itemBuilder: (context, index) {
                          return StreamBuilder<AmityCommunity>(
                              stream: getList()[index].listen.stream,
                              initialData: getList()[index],
                              builder: (context, snapshot) {
                                return CommunityWidget(
                                  community: snapshot.data!,
                                  theme: theme,
                                  communityType: communityType,
                                );
                              });
                        },
                      ),
                beginOffset: const Offset(0, 0.3),
                endOffset: const Offset(0, 0),
                slideCurve: Curves.linearToEaseOut,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class CommunityWidget extends StatelessWidget {
  const CommunityWidget(
      {Key? key,
      required this.community,
      required this.theme,
      required this.communityType})
      : super(key: key);

  final AmityCommunity community;
  final ThemeData theme;
  final CommunityListType communityType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) => CommuFeedVM(),
                  child: Builder(builder: (context) {
                    return CommunityScreen(
                      community: community,
                    );
                  }),
                )));
        switch (communityType) {
          case CommunityListType.my:
            // ignore: use_build_context_synchronously
            Provider.of<CommunityVM>(context, listen: false)
                .initAmityMyCommunityList();
            break;
          case CommunityListType.recommend:
            // ignore: use_build_context_synchronously
            Provider.of<CommunityVM>(context, listen: false)
                .initAmityRecommendCommunityList();
            break;
          case CommunityListType.trending:
            // ignore: use_build_context_synchronously
            Provider.of<CommunityVM>(context, listen: false)
                .initAmityTrendingCommunityList();
            break;
          default:
            // ignore: use_build_context_synchronously
            Provider.of<CommunityVM>(context, listen: false)
                .initAmityMyCommunityList();
            break;
        }
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: FadeAnimation(
                    child: (community.avatarImage?.fileUrl != null)
                        ? CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                (NetworkImage(community.avatarImage!.fileUrl!)))
                        : const CircleAvatar(
                            backgroundImage: AssetImage(
                                "assets/images/user_placeholder.png",
                                package: "amity_uikit_beta_service")),
                  ),
                  title: Text(
                    community.displayName ?? "Community",
                    style: theme.textTheme.bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    " ${community.membersCount} members",
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: Colors.grey, fontSize: 11),
                  ),
                  trailing: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                    )),
                    onPressed: () async {
                      if (community.isJoined != null) {
                        if (community.isJoined!) {
                          Provider.of<CommunityVM>(context, listen: false)
                              .leaveCommunity(community.communityId ?? "",
                                  type: communityType,
                                  callback: (bool isSuccess) {});
                        } else {
                          Provider.of<CommunityVM>(context, listen: false)
                              .joinCommunity(community.communityId ?? "",
                                  type: communityType);
                        }
                      }
                    },
                    child: Text(community.isJoined != null
                        ? (community.isJoined! ? "Leave" : "Join")
                        : "Join"),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
