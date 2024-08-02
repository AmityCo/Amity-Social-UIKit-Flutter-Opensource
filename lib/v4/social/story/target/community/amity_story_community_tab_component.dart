import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/community/bloc/community_feed_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/elements/amity_story_target_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/utils%20/amity_story_target_ext.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../view/amity_view_story_page_type.dart';

class AmityStoryCommunityTabComponent extends StatefulWidget {
  final String communityId;
  final Function(AmityStoryTarget storytarget, AmityStoryMediaType mediaType, AmityStoryImageDisplayMode? imageMode, HyperLink? hyperlionk) createStory;
  const AmityStoryCommunityTabComponent({super.key, required this.communityId, required this.createStory});

  @override
  State<AmityStoryCommunityTabComponent> createState() => _AmityStoryCommunityTabComponentState();
}

class _AmityStoryCommunityTabComponentState extends State<AmityStoryCommunityTabComponent> {
  @override
  void initState() {
    context.read<CommunityFeedStoryBloc>().add(ObserveStoryTargetEvent(communityId: widget.communityId));
    context.read<CommunityFeedStoryBloc>().add(CheckMangeStoryPermissionEvent(communityId: widget.communityId));
    context.read<CommunityFeedStoryBloc>().add(FetchStories(communityId: widget.communityId));

    // add(SubscribeToCommunityEvent( community: storyTarget.community!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityFeedStoryBloc, CommunityFeedStoryState>(builder: (context, state) {
      if (state.isLoading) {
        return SizedBox(
          width:  80 ,
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 243, 242, 242),
                highlightColor: const Color.fromARGB(255, 225, 225, 225),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                ),
              ),
              const SizedBox(height: 5),
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 243, 242, 242),
                highlightColor: const Color.fromARGB(255, 225, 225, 225),
                child: Container( width:  100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)) ),
              ),
            ],
          ),
        );
      }

      if (state.community != null) {
        if (!state.haveStoryPermission && (state.stories == null || state.stories!.isEmpty)) {
          return const SizedBox(
            width: 0,
            height: 0,
          );
        }

        return AmityStoryTargetElement(
          avatarUrl: state.community!.avatarImage?.getUrl(AmityImageSize.LARGE) ?? "",
          isCommunityTarget: true,
          communityDisplayName: state.community!.displayName ?? "",
          ringUiState: state.storyTarget!.toRingUiState(),
          isPublicCommunity: state.community!.isPublic ?? false,
          isOfficialCommunity: state.community!.isOfficial ?? false,
          hasManageStoryPermission: state.haveStoryPermission,
          targetId: state.community!.communityId!,
          target: state.storyTarget!,
          onClick: (targetId, storyTarget) {
            if (state.haveStoryPermission && (state.stories == null || state.stories?.isEmpty == true)) {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return CreateStoryConfigProviderWidget(
                  targetType: AmityStoryTargetType.COMMUNITY,
                  onStoryCreated: () {},
                  targetId: targetId,
                  storyTarget: storyTarget,
                  pageId: 'create_story_page',
                  createStory: widget.createStory,
                );
              }));
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                return AmityViewStoryPage(
                  createStory: widget.createStory,
                  type: AmityViewStoryCommunityFeed(communityId: widget.communityId),
                );
              }));
            }
          },
        );
      }

      return const SizedBox();
    });
  }
}
