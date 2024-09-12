import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/elements/amity_story_target_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/global/bloc/global_story_target_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/utils%20/amity_story_target_ext.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_story_page_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class AmityStoryGlobalTabComponent extends NewBaseComponent {
  String? pageId;
  AmityStoryGlobalTabComponent({
    super.key,
    this.pageId,
  }) : super(pageId: pageId, componentId: "story_tab_component");
  @override
  Widget buildComponent(BuildContext context) {
    return AmityStoryGlobalTabBuilder(
      theme: theme,
    );
  }
}

class AmityStoryGlobalTabBuilder extends StatefulWidget {
  final AmityThemeColor theme;
  const AmityStoryGlobalTabBuilder({
    super.key,
    required this.theme,
  });

  @override
  State<AmityStoryGlobalTabBuilder> createState() => _AmityStoryGlobalTabBuilderState();
}

class _AmityStoryGlobalTabBuilderState extends State<AmityStoryGlobalTabBuilder> {
  final scrollcontroller = ScrollController();

  @override
  void initState() {
    BlocProvider.of<GlobalStoryTargetBloc>(context).add(ObserverGlobalStoryTarget());
    scrollcontroller.addListener(pagination);
    super.initState();
  }

  void pagination() {
    if ((scrollcontroller.position.pixels == (scrollcontroller.position.maxScrollExtent))) {
      BlocProvider.of<GlobalStoryTargetBloc>(context).add(LoadNextTargetStoriesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateStoryBloc, CreateStoryState>(
      listener: (context, state) {
        if (state is CreateStorySuccess) {
          context.read<AmityToastBloc>().add(const AmityToastShort(message: "Successfully shared story", icon: AmityToastIcon.success));
        }
      },
      child: BlocBuilder<GlobalStoryTargetBloc, GlobalStoryTargetState>(
        builder: (context, state) {
          if (state is GlobalStoryTargetFetchedState) {
            if (state.storyTargets.isEmpty) {
              return Container();
            }
            return Container(
              height: 95,
              color: widget.theme.backgroundColor,
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 15),
              child: ListView.builder(
                controller: scrollcontroller,
                scrollDirection: Axis.horizontal,
                itemCount: state.storyTargets.length,
                itemBuilder: (context, index) {
                  var target = state.storyTargets[index];
                  AmityCommunity? community;
                  if (target is AmityStoryTargetCommunity) {
                    community = target.community;
                  }
                  if (target == null || community == null) {
                    return const SizedBox();
                  }
                  return AmityStoryTargetElement(
                    avatarUrl: community.avatarImage?.getUrl(AmityImageSize.LARGE) ?? "",
                    isCommunityTarget: false,
                    communityDisplayName: community.displayName ?? "",
                    ringUiState: target.toRingUiState(),
                    isPublicCommunity: community.isPublic ?? false,
                    isOfficialCommunity: community.isOfficial ?? false,
                    hasManageStoryPermission: false,
                    targetId: community.communityId!,
                    target: target,
                    onClick: (targetId, storyTarget) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return AmityViewStoryPage(
                            targets: state.storyTargets,
                            selectedTarget: target,
                            type: AmityViewStoryGlobalFeed(communityId: community!.communityId!),
                          );
                        }),
                      );
                      // }
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget loadingSkeleton() {
    return Container(
        width: double.infinity,
        height: 90,
        color: Colors.white,
        child: Row(
          children: [
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
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
                    child: Container(width: 100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
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
                    child: Container(width: 100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
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
                    child: Container(width: 100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
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
                    child: Container(width: 100, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
