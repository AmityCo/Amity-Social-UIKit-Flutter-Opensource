import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/social/community_feed.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCommunityPage extends StatefulWidget {
  const MyCommunityPage({
    super.key,
    this.canCreateCommunity = true,
  });

  final bool canCreateCommunity;

  @override
  _MyCommunityPageState createState() => _MyCommunityPageState();
}

class _MyCommunityPageState extends State<MyCommunityPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<MyCommunityVM>(context, listen: false)
          .textEditingController
          .clear();
      Provider.of<MyCommunityVM>(context, listen: false).initMyCommunity();
      Provider.of<UserVM>(context, listen: false).clearselectedCommunityUsers();
    });
  }

  // @override
  // dispose() {
  //   Provider.of<MyCommunityVM>(context, listen: false)
  //       .textEditingController
  //       .clear();
  //   Provider.of<MyCommunityVM>(context, listen: false).initMyCommunity();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyCommunityVM>(builder: (context, vm, _) {
      return Scaffold(
        backgroundColor:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0.0,
          backgroundColor: Provider.of<AmityUIConfiguration>(context)
              .appColors
              .baseBackground,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Provider.of<AmityUIConfiguration>(context).appColors.base,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'My Community',
            style: Provider.of<AmityUIConfiguration>(context)
                .titleTextStyle
                .copyWith(
                  color:
                      Provider.of<AmityUIConfiguration>(context).appColors.base,
                ), // Adjust as needed
          ),
          actions: [
            if (widget.canCreateCommunity)
              IconButton(
                icon: Icon(
                  Icons.add,
                  color:
                      Provider.of<AmityUIConfiguration>(context).appColors.base,
                ),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const CreateCommunityPage())); // Replace with your CreateCommunityPage
                  await Provider.of<MyCommunityVM>(context, listen: false)
                      .initMyCommunity();
                },
              ),
          ],
        ),
        body: ListView.builder(
          controller: vm.scrollcontroller,
          itemCount: vm.amityCommunities.length + 1,
          itemBuilder: (context, index) {
            // If it's the first item in the list, return the search bar
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: vm.textEditingController,
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
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    Provider.of<MyCommunityVM>(context, listen: false)
                        .initMyCommunity(value);
                  },
                ),
              );
            }
            // Otherwise, return the community widget
            return CommunityWidget(
              community: vm.amityCommunities[index - 1],
            );
          },
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
                  if (!community.isPublic!)
                    Icon(
                      Icons.lock,
                      size: 16.0,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                  const SizedBox(width: 4.0),
                  Text(
                    communityStream.displayName ?? "Community ",
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  communityStream.isOfficial!
                      ? Provider.of<AmityUIConfiguration>(context)
                          .iconConfig
                          .officialIcon(
                              iconSize: 17,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .primaryColor)
                      : const SizedBox(),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      CommunityScreen(community: communityStream),
                  settings:
                      const RouteSettings(name: CommunityScreen.routeName),
                ));
              },
            ),
          );
        });
  }
}

class CommunityIconList extends StatelessWidget {
  final List<AmityCommunity> amityCommunites;
  final bool canCreateCommunity;

  const CommunityIconList({
    super.key,
    required this.amityCommunites,
    this.canCreateCommunity = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Community',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base,
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            body: MyCommunityPage(
                              canCreateCommunity: canCreateCommunity,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(child: const Icon(Icons.chevron_right))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 0),
            height: 70.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: amityCommunites.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(left: index != 0 ? 0 : 16),
                  child: CommunityIconWidget(
                      amityCommunity: amityCommunites[index]),
                );
              },
            ),
          ),
          Divider(
            height: 1,
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
              color: Colors.transparent,
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
                          ? Icon(
                              Icons.lock,
                              size: 12,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base,
                            )
                          : const SizedBox(),
                      Expanded(
                        child: Text(amityCommunity.displayName ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .base,
                                overflow: TextOverflow.ellipsis)),
                      ),
                      amityCommunity.isOfficial!
                          ? Provider.of<AmityUIConfiguration>(context)
                              .iconConfig
                              .officialIcon(
                                  iconSize: 12,
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .primaryColor)
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
