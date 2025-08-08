import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_community_categories_component.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_explore_category_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_state.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/recommended_communities/amity_recommended_communities_component.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/recommended_communities/amity_recommended_community_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/trending_communities/amity_trending_communities_component.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/trending_communities/amity_trending_community_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityExploreComponent extends NewBaseComponent {
  final ExploreComponentRefreshController _refreshController =
      ExploreComponentRefreshController();

  AmityExploreComponent({
    super.key,
    super.pageId,
  }) : super(componentId: 'explore_component');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreComponentCubit(),
      child: BlocBuilder<ExploreComponentCubit, ExploreComponentState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExploreComponentCubit>().setRefreshing();
            },
            child: state.isRefreshing
                ? _buildLoadingState()
                : _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _getDivider(),
        AmityExploreCategoryShimmer(),
        AmityRecommendedCommunityShimmer(),
        AmityTrendingCommunityShimmer()
      ],
    );
  }

  Widget _buildContent(BuildContext context, ExploreComponentState state) {
    if (state.isEmpty) {
      return _buildEmptyState(context, state);
    } else if (state.isError) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _getDivider(),
          AmityCommunityCategoriesComponent(
            pageId: pageId,
            onStateChanged: (state) {
              context.read<ExploreComponentCubit>().setCategoryState(state);
            },
          ),
          AmityRecommendedCommunitiesComponent(
            pageId: pageId,
            refreshController: _refreshController,
            onStateChanged: (state) {
              context.read<ExploreComponentCubit>().setRecommendedState(state);
            },
          ),
          AmityTrendingCommunitiesComponent(
            pageId: pageId,
            refreshController: _refreshController,
            onStateChanged: (state) {
              context.read<ExploreComponentCubit>().setTrendingState(state);
            },
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExploreComponentState state) {
    final String title = state.categoryState == CategoryListState.empty
        ? "Your explore is empty"
        : "No community yet";
    final String caption = state.categoryState == CategoryListState.empty
        ? "Find community or create your own"
        : "Let's create your own communities..";

    Widget emptyWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      SvgPicture.asset(
          'assets/Icons/amity_ic_global_feed_empty.svg',
          width: 160,
          height: 160,
          package: 'amity_uikit_beta_service',
        ),
        const SizedBox(height: 16),
        Text(title, style: AmityTextStyle.titleBold(theme.baseColorShade3)),
        const SizedBox(height: 4),
        Text(caption, style: AmityTextStyle.caption(theme.baseColorShade3)),
        const SizedBox(height: 26),
        _buildCreateCommunityButton(context),
        const SizedBox(height: 40)
    ]);

    return Column(
      children: [
        _getDivider(),
        if (state.categoryState != CategoryListState.empty)...[
           AmityCommunityCategoriesComponent(
            onStateChanged: (state) {
              context.read<ExploreComponentCubit>().setCategoryState(state);
            },
          ),
        ],
        Expanded(child: emptyWidget)
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/Icons/amity_ic_explore_error.svg',
          width: 60,
          height: 40,
          package: 'amity_uikit_beta_service',
        ),
        const SizedBox(height: 16),
        Text("Something went wrong",
            style: AmityTextStyle.titleBold(theme.baseColorShade3)),
        const SizedBox(height: 2),
        Text("Please try again.",
            style: AmityTextStyle.caption(theme.baseColorShade3)),
        const SizedBox(height: 40)
      ],
    );
  }

  Widget _buildCreateCommunityButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityCommunitySetupPage(
              mode: const CreateMode(),
            ),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: Text("Create community", style: AmityTextStyle.body(Colors.white)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _getDivider() {
    return Container(
      color: theme.baseColorShade4,
      height: 8,
    );
  }
}
