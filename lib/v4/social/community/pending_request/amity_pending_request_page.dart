import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/freedom_uikit_behavior.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/amity_pending_post_list_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_pending_request_state.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_request/amity_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

enum AmityPendingRequestPageTab {
  pendingPosts(0);

  final int rawValue;
  const AmityPendingRequestPageTab(this.rawValue);
}

class AmityPendingRequestPage extends NewBasePage {
  final AmityCommunity community;
  final AmityPendingRequestPageTab initialTab;

  AmityPendingRequestPage({
    Key? key,
    required this.community,
    this.initialTab = AmityPendingRequestPageTab.pendingPosts,
  }) : super(key: key, pageId: 'pendingRequestPage');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => AmityPendingRequestCubit(
        community: community,
        initialTab: initialTab,
      ),
      child: BlocBuilder<AmityPendingRequestCubit, AmityPendingRequestState>(
        builder: (context, state) {
          final List<String> tabs = state.availableTabs;
          final initialTabIndex = state.initialTabIndex;

          return DefaultTabController(
            length: tabs.isEmpty ? 1 : tabs.length,
            initialIndex: initialTabIndex,
            child: Builder(builder: (context) {
              if (tabs.isNotEmpty) {
                final tabController = DefaultTabController.of(context);
                tabController.addListener(() {
                  if (!tabController.indexIsChanging) {
                    final currentIndex = tabController.index;
                    final newTab = AmityPendingRequestPageTab.pendingPosts;

                    context.read<AmityPendingRequestCubit>().changeTab(newTab);
                  }
                });
              }

              return Scaffold(
                backgroundColor: theme.backgroundColor,
                appBar: AppBar(
                  backgroundColor: theme.backgroundColor,
                  foregroundColor: theme.baseColor,
                  title: FreedomUIKitBehavior
                          .instance.pendingRequestPageBehavior.buildTitle
                          ?.call() ??
                      Text("Pending Requests",
                          style: AmityTextStyle.titleBold(theme.baseColor)),
                  flexibleSpace: FreedomUIKitBehavior.instance
                      .pendingRequestPageBehavior.buildHeaderFlexibleSpace
                      ?.call(FreedomUIKitBehavior
                          .instance
                          .pendingRequestPageBehavior
                          .postReviewScrollerController),
                  leading: IconButton(
                    icon: SvgPicture.asset(
                      'assets/Icons/amity_ic_back_button.svg',
                      package: 'amity_uikit_beta_service',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.baseColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  elevation: 0,
                  bottom: tabs.isEmpty
                      ? null
                      : PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: theme.baseColorShade4,
                                ),
                              ),
                            ),
                            child: TabBar(
                              tabs: _buildTabIndicators(context, tabs),
                              labelColor: theme.primaryColor,
                              unselectedLabelColor: theme.baseColor,
                              // indicatorColor: theme.primaryColor,
                              isScrollable: true,
                              padding: EdgeInsets.zero,
                              tabAlignment: TabAlignment.start,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Colors.transparent,
                              indicator: UnderlineTabIndicator(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                body: tabs.isEmpty
                    ? _buildEmptyStateView(context)
                    : TabBarView(
                        children: _buildTabContent(context),
                      ),
              );
            }),
          );
        },
      ),
    );
  }

  List<Widget> _buildTabIndicators(BuildContext context, List<String> tabs) {
    final state = context.watch<AmityPendingRequestCubit>().state;
    final tabController = DefaultTabController.of(context);

    return [
      if (state.community.isPostReviewEnabled ?? false)
        AmityTabIndicator(
          title: "Posts",
          count: state.pendingPostCount,
          selected: tabController.index == 0,
          selectedColor: theme.primaryColor,
          unselectedColor: theme.baseColor,
        ),
    ];
  }

  List<Widget> _buildTabContent(BuildContext context) {
    final state = context.read<AmityPendingRequestCubit>().state;
    final List<Widget> tabContents = [];

    // Add pending posts tab content if enabled
    if (state.community.isPostReviewEnabled ?? false) {
      tabContents.add(
        AmityPendingPostListComponent(
          community: state.community,
          pageId: pageId,
          onPendingPostsLoaded: (posts) {
            // Update count when posts are loaded
            context
                .read<AmityPendingRequestCubit>()
                .updatePendingPostCount(posts.length);
          },
        ),
      );
    }

    // Add join requests tab content if enabled
    // We'll skip this implementation for now, but add a placeholder
    if (state.community.isPublic == false) {
      // Change to requiresJoinApproval when available
      tabContents.add(
        Center(
          child: Text(
            "Join requests feature coming soon",
            style: TextStyle(color: theme.baseColor), // Using baseColor
          ),
        ),
      );
    }

    // If no tabs are enabled, show empty state
    if (tabContents.isEmpty) {
      tabContents.add(_buildEmptyStateView(context));
    }

    return tabContents;
  }

  Widget _buildEmptyStateView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 60,
            color: theme.baseColor.withOpacity(0.6), // Using baseColor
          ),
          const SizedBox(height: 16),
          Text(
            'No pending requests available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.baseColor, // Using baseColor
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Enable post review or join approval in community settings to manage requests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.baseColor.withOpacity(0.6), // Using baseColor
              ),
            ),
          ),
        ],
      ),
    );
  }
}
