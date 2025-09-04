import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/community/bloc/community_feed_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/elements/amity_story_target_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/utils%20/amity_story_target_ext.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../view/amity_view_story_page_type.dart';

class AmityStoryCommunityTabComponent extends NewBaseComponent {
  final String communityId;
  String? pageId;
  AmityStoryCommunityTabComponent({
    super.key,
    required this.communityId,
    this.pageId,
  }) : super(pageId: pageId, componentId: "story_tab_component");

  @override
  Widget buildComponent(BuildContext context) {
    return AmityStoryCommunityTabBuilder(
      theme: theme,
      communityId: communityId,
    );
  }
}

class AmityStoryCommunityTabBuilder extends StatefulWidget {
  final String communityId;
  final AmityThemeColor theme;
  const AmityStoryCommunityTabBuilder({
    super.key,
    required this.theme,
    required this.communityId,
  });

  @override
  State<AmityStoryCommunityTabBuilder> createState() =>
      _AmityStoryCommunityTabBuilderState();
}

class _AmityStoryCommunityTabBuilderState
    extends State<AmityStoryCommunityTabBuilder> {
  @override
  void initState() {
    context
        .read<CommunityFeedStoryBloc>()
        .add(ObserveStoryTargetEvent(communityId: widget.communityId));
    context
        .read<CommunityFeedStoryBloc>()
        .add(CheckMangeStoryPermissionEvent(communityId: widget.communityId));
    context
        .read<CommunityFeedStoryBloc>()
        .add(FetchStories(communityId: widget.communityId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateStoryBloc, CreateStoryState>(
      listener: (context, state) {
        if (state is CreateStorySuccess) {
          context.read<AmityToastBloc>().add(const AmityToastShort(
              message: "Successfully shared story",
              icon: AmityToastIcon.success));
        }
      },
      child: BlocBuilder<CommunityFeedStoryBloc, CommunityFeedStoryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Container(
              color: widget.theme.backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 243, 242, 242),
                    highlightColor: const Color.fromARGB(255, 225, 225, 225),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: widget.theme.baseColor,
                          borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Shimmer.fromColors(
                    baseColor: const Color.fromARGB(255, 243, 242, 242),
                    highlightColor: const Color.fromARGB(255, 225, 225, 225),
                    child: Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                            color: widget.theme.baseColor,
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            );
          }

          if (state.community != null) {
            if (!state.haveStoryPermission &&
                (state.stories == null || state.stories!.isEmpty)) {
              return const SizedBox(
                width: 0,
                height: 0,
              );
            }

            final featureConfig =
                context.read<ConfigProvider>().getFeatureConfig();
            final isStoryCreationEnabled = featureConfig.story.createEnabled;

            return Container(
              color: widget.theme.backgroundColor,
              child: AmityStoryTargetElement(
                avatarUrl: state.community!.avatarImage
                        ?.getUrl(AmityImageSize.LARGE) ??
                    "",
                isCommunityTarget: true,
                communityDisplayName: state.community!.displayName ?? "",
                ringUiState: state.storyTarget!.toRingUiState(),
                isPublicCommunity: state.community!.isPublic ?? false,
                isOfficialCommunity: state.community!.isOfficial ?? false,
                hasManageStoryPermission: state.haveStoryPermission,
                targetId: state.community!.communityId!,
                target: state.storyTarget!,
                onClick: (targetId, storyTarget) {
                  if (state.haveStoryPermission &&
                      isStoryCreationEnabled &&
                      (state.stories == null ||
                          state.stories?.isEmpty == true)) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return CreateStoryConfigProviderWidget(
                            targetType: AmityStoryTargetType.COMMUNITY,
                            targetId: targetId,
                            pageId: 'create_story_page',
                          );
                        },
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AmityViewStoryPage(
                            type: AmityViewStoryCommunityFeed(
                                communityId: widget.communityId),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            );
          }

          return const SizedBox(
            width: 0,
            height: 0,
          );
        },
      ),
    );
  }
}
