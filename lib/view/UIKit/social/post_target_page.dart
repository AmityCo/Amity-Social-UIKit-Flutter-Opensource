import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_post_screenV2.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostToPage extends StatefulWidget {
  const PostToPage({super.key});

  @override
  State<PostToPage> createState() => _PostToPageState();
}

class _PostToPageState extends State<PostToPage> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<MyCommunityVM>(context, listen: false).initMyCommunity();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0, // Add this line to remove the shadow
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Post to",
          style: Provider.of<AmityUIConfiguration>(context).titleTextStyle,
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<MyCommunityVM>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            controller: viewModel.scrollcontroller,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: (AmityCoreClient.getCurrentUser().avatarUrl != null)
                      ? CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                              AmityCoreClient.getCurrentUser().avatarUrl!),
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
                  title: const Text(
                    "My Timeline",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    // Adjust as needed),
                  ),
                  onTap: () {
                    // Navigate or perform action based on 'Newsfeed' tap
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AmityCreatePostV2Screen(
                        isFromPostToPage: true,
                      ),
                    ));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "My community",
                    style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xff292B32).withOpacity(0.4)),
                  ),
                ),
                ...viewModel.amityCommunities.map((community) {
                  return StreamBuilder<AmityCommunity>(
                      stream: community.listen.stream,
                      builder: (context, snapshot) {
                        var communityStream = snapshot.data ?? community;
                        return ListTile(
                          leading: (communityStream.avatarFileId != null)
                              ? CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(
                                      communityStream.avatarImage!.fileUrl!),
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
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
                              !community.isPublic!
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 7.0),
                                      child: Icon(
                                        Icons.lock,
                                        size: 17,
                                      ))
                                  : const SizedBox(),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                community.displayName ?? '',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              community.isOfficial!
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 7.0),
                                      child: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .iconConfig
                                          .officialIcon(
                                              iconSize: 17,
                                              color: Provider.of<
                                                          AmityUIConfiguration>(
                                                      context)
                                                  .primaryColor),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          onTap: () {
                            // Navigate or perform action based on 'Newsfeed' tap
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AmityCreatePostV2Screen(
                                community: community,
                                isFromPostToPage: true,
                              ),
                            ));
                          },
                        );
                      });
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
