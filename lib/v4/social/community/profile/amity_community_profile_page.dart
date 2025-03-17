import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_feed/community_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_pin/community_pin_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/community_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/component/community_header_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_cover_view.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_join_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_pending_post.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_tab.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../post_poll_composer_page/post_poll_composer_page.dart';

class AmityCommunityProfilePage extends NewBasePage {
  final String communityId;
  AmityCommunityProfilePage({super.key, required this.communityId})
      : super(pageId: 'community_profile');

  final ScrollController _scrollController = ScrollController();

  @override
  Widget buildPage(BuildContext context) {
    final statusBarHeight = Platform.isIOS
        ? 44.0
        : 24.0; // iOS status bar height is 44 and android status bar height is 34
    final appBarHeight = statusBarHeight + 56;
    return BlocProvider(
      create: (context) => CommunityProfileBloc(communityId, _scrollController),
      child: Builder(builder: (context) {
        return BlocBuilder<CommunityProfileBloc, CommunityProfileState>(
          builder: (context, state) {
            state.scrollController.addListener(() {
              if (state.scrollController.hasClients &&
                  state.scrollController.offset > 330) {
                context
                    .read<CommunityProfileBloc>()
                    .add(CommunityProfileEventCollapsed());
              } else {
                context
                    .read<CommunityProfileBloc>()
                    .add(CommunityProfileEventExpanded());
              }
            });
            return Scaffold(
              backgroundColor: theme.baseColorShade4,
              body: CustomScrollView(
                controller: state.scrollController,
                slivers: <Widget>[
                  !(state.isExpanded)
                      ? SliverAppBar(
                          floating: false,
                          pinned: true,
                          stretch: true,
                          elevation: 0,
                          leadingWidth: 48,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: GestureDetector(
                              onTap: () => {Navigator.pop(context)},
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/Icons/amity_ic_back_button.svg",
                                    package: 'amity_uikit_beta_service',
                                    height: 18,
                                    width: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          title: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (state.community?.isPublic == false)
                                  Container(
                                    width: 28,
                                    height: 28,
                                    margin: const EdgeInsets.only(top: 1),
                                    child: AmityPrivateBadgeElement(
                                      colorFilter: ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: Text(
                                    state.community?.displayName ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (state.community?.isOfficial == true)
                                  Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.only(top: 2),
                                      child: AmityOfficialBadgeElement()),
                              ],
                            ),
                          ),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () => {
                                  if (state.community != null)
                                    {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context2) =>
                                              AmityCommunitySettingPage(community: state.community!)
                                          ))
                                    }
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/Icons/amity_ic_post_item_option.svg",
                                      package: 'amity_uikit_beta_service',
                                      height: 18,
                                      width: 18,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          flexibleSpace: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: appBarHeight,
                                child: (state.community != null)
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          AmityCommunityCoverView(
                                            community: state.community!,
                                            style: AmityCommunityHeaderStyle
                                                .COLLAPSE,
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ),
                            ],
                          ),
                        )
                      : SliverToBoxAdapter(child: Container()),
                  SliverToBoxAdapter(
                    child: Container(
                        child: AmityCommunityHeaderComponent(
                      community: state.community,
                    )),
                  ),
                  SliverToBoxAdapter(
                    child: (state.community != null && state.isJoined == false)
                        ? Container(
                            width: double.infinity,
                            color: theme.backgroundColor,
                            padding: const EdgeInsets.all(16),
                            child: AmityCommunityJoinButton(
                              community: state.community!,
                            ),
                          )
                        : Container(),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: theme.backgroundColor,
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AmityStoryTabComponent(
                            type:
                                CommunityFeedStoryTab(communityId: communityId),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: (state.community != null &&
                            state.isJoined &&
                            state.pendingPostCount > 0 && (state.community!.isPostReviewEnabled ?? false))
                        ? Container(
                            color: theme.backgroundColor,
                            padding: const EdgeInsets.all(16),
                            child: AmityCommunityPendingPost(
                              community: state.community!,
                              pendingPostCount: state.pendingPostCount,
                              isModerator: state.isModerator,
                            ),
                          )
                        : Container(),
                  ),
                  SliverToBoxAdapter(
                    child: CommunityProfileTab(
                      selectedIndex: state.selectedIndex,
                      onTabSelected: (index) {
                        context
                            .read<CommunityProfileBloc>()
                            .add(CommunityProfileEventTabSelected(tab: index));
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child:
                        (state.selectedIndex == CommunityProfileTabIndex.feed)
                            ? Container(
                                color: theme.baseColorShade4,
                                width: double.infinity,
                                child: CommunityFeedComponent(
                                  communityId: state.communityId,
                                  scrollController: _scrollController,
                                ),
                              )
                            : Container(),
                  ),
                  SliverToBoxAdapter(
                    child: (state.selectedIndex == CommunityProfileTabIndex.pin)
                        ? Container(
                            color: theme.baseColorShade4,
                            width: double.infinity,
                            child: CommunityPinComponent(
                              communityId: state.communityId,
                              scrollController: _scrollController,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: (state.isJoined)
                  ? GestureDetector(
                      onTap: () {
                        showCommunityProfileAction(context, theme,
                            state.canManageStory, state.community);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: ShapeDecoration(
                                  color: theme.primaryColor,
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Container(
                                width: 32,
                                height: 32,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_plus_button.svg',
                                        package: 'amity_uikit_beta_service',
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            );
          },
        );
      }),
    );
  }

  void showCommunityProfileAction(
    BuildContext context,
    AmityThemeColor theme,
    bool canManageStory,
    AmityCommunity? community,
  ) {
    double height = 0;
    double baseHeight = 80;
    double itemHeight = 48;
    double itemCount = 3;
    height = baseHeight + (itemHeight * itemCount);

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return SizedBox(
            height: height,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final createOptions =
                        AmityPostComposerOptions.createOptions(
                            targetId: communityId,
                            community: community,
                            targetType: AmityPostTargetType.COMMUNITY);
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );

                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PopScope(
                          canPop: true,
                          child: AmityPostComposerPage(
                            options: createOptions,
                            onPopRequested: (shouldPopCaller) {
                              if (shouldPopCaller) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_create_post_button.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Post',
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (canManageStory)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return CreateStoryConfigProviderWidget(
                              targetType: AmityStoryTargetType.COMMUNITY,
                              targetId: communityId,
                              pageId: 'create_story_page',
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: SvgPicture.asset(
                              'assets/Icons/ic_create_stroy_black.svg',
                              package: 'amity_uikit_beta_service',
                              width: 24,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Story',
                            style: TextStyle(
                              color: theme.baseColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );

                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PopScope(
                              canPop: true,
                              child: AmityPollPostComposerPage(
                                targetId: communityId,
                                targetType: AmityPostTargetType.COMMUNITY,
                                targetCommunityName: community?.displayName ?? '',
                                onPopRequested: (shouldPopCaller) {
                                  if (shouldPopCaller) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_create_poll_button.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Poll',
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
