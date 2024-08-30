import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ShareStoryToPage extends StatefulWidget {
  final Function?  storyCreated;
  const ShareStoryToPage({super.key , this.storyCreated});

  @override
  State<ShareStoryToPage> createState() => _ShareStoryToPageState();
}

class _ShareStoryToPageState extends State<ShareStoryToPage> {
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
      backgroundColor: Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0.0, // Add this line to remove the shadow
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Provider.of<AmityUIConfiguration>(context).appColors.base,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Share to",
          style: Provider.of<AmityUIConfiguration>(context).titleTextStyle.copyWith(color: Provider.of<AmityUIConfiguration>(context).appColors.base),
        ),
        backgroundColor: Colors.transparent,
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "My community",
                    style: TextStyle(fontSize: 15, color: Provider.of<AmityUIConfiguration>(context).appColors.userProfileTextColor),
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
                                  backgroundImage: NetworkImage(communityStream.avatarImage!.fileUrl!),
                                )
                              : Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(color: Provider.of<AmityUIConfiguration>(context).appColors.primaryShade3, shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.group,
                                    color: Colors.white,
                                  ),
                                ),
                          title: Row(
                            children: [
                              !community.isPublic!
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 7.0),
                                      child: Icon(
                                        Icons.lock,
                                        color: Provider.of<AmityUIConfiguration>(context).appColors.base,
                                        size: 17,
                                      ))
                                  : const SizedBox(),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                community.displayName ?? '',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Provider.of<AmityUIConfiguration>(context).appColors.base),
                              ),
                              community.isOfficial!
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 7.0),
                                      child: Provider.of<AmityUIConfiguration>(context).iconConfig.officialIcon(iconSize: 17, color: Provider.of<AmityUIConfiguration>(context).primaryColor),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          onTap: () {
                            // Navigate or perform action based on 'Newsfeed' tap
                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                              return CreateStoryConfigProviderWidget(
                                targetType: AmityStoryTargetType.COMMUNITY,
                                onStoryCreated: () {
                                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                                  AmityStorySingleSegmentTimerElement.currentValue = -1;
                                  Navigator.of(context).pop();
                                },
                                targetId: community.communityId!,
                                storyTarget: AmityStoryTargetCommunity(
                                  targetId: community.communityId!,
                                ),
                                pageId: 'create_story_page',
                                createStory: (storytarget, mediaType, imageMode, hyperlionk) {
                                  if (mediaType is AmityStoryMediaTypeImage) {
                                    AmitySocialClient.newStoryRepository()
                                        .createImageStory(
                                      targetType: storytarget.targetType,
                                      targetId: storytarget.targetId,
                                      imageFile: (mediaType).file,
                                      storyItems: hyperlionk != null ? [hyperlionk] : [],
                                      imageDisplayMode: imageMode!,
                                    )
                                        .then((value) {
                                          if(widget.storyCreated != null){
                                            widget.storyCreated!();
                                          }
                                    }).onError((error, stackTrace) => null);
                                  } else if (mediaType is AmityStoryMediaTypeVideo) {
                                    AmitySocialClient.newStoryRepository()
                                        .createVideoStory(
                                      targetType: storytarget.targetType,
                                      targetId: storytarget.targetId,
                                      storyItems: hyperlionk != null ? [hyperlionk!] : [],
                                      videoFile: (mediaType).file,
                                    )
                                        .then((value) {
                                          if(widget.storyCreated != null){
                                            widget.storyCreated!();
                                          }
                                    }).onError((error, stackTrace) => null);
                                  }

                                  // Navigator.of(context).pop();
                                },
                              );
                            }));
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