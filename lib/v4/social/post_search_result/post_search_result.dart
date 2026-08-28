import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/bloc/global_search_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/amity_post_detail_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityPostSearchResultComponent extends NewBaseComponent {
  final AmityGlobalSearchViewModel viewModel;

  AmityPostSearchResultComponent({
    Key? key,
    String? pageId,
    required this.viewModel,
  }) : super(key: key, pageId: pageId, componentId: 'post_search_result');

  @override
  Widget buildComponent(BuildContext context) {
    if (!viewModel.hasSearched) {
      return const SizedBox.expand();
    }
    if (viewModel.posts.isEmpty) {
      if (viewModel.isPostsFetching) {
        return _postSkeletonList(theme, configProvider);
      } else {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_search_not_found.svg',
                package: 'amity_uikit_beta_service',
                colorFilter:
                    ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
                width: 47,
                height: 47,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.search_no_results,
                style: AmityTextStyle.titleBold(theme.baseColorShade3),
              ),
            ],
          ),
        );
      }
    } else {
      return Container(
        color: theme.backgroundColor,
        child: _postList(context),
      );
    }
  }

  // The keyword the user searched for, used to highlight matches within the
  // post text of each result. Falls back to the view model's stored
  // keyword (if any) when the bloc state isn't available.
  String _currentSearchKeyword(BuildContext context) {
    final state = context.watch<GlobalSearchBloc>().state;
    if (state is GlobalPostSearchLoaded && state.searchText.isNotEmpty) {
      return state.searchText;
    }
    return viewModel.postSearchKeyword;
  }

  Widget _postList(BuildContext context) {
    final searchKeyword = _currentSearchKeyword(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            viewModel.isPostsFetching == false &&
            viewModel.posts.isNotEmpty) {
          viewModel.onLoadMore?.call();
        }
        return false;
      },
      child: ListView.separated(
        controller: viewModel.scrollController,
        separatorBuilder: (context, index) => Divider(
          color: theme.baseColorShade4,
          thickness: 8,
          height: 8,
        ),
        itemCount: viewModel.posts.length +
            (viewModel.isPostsFetching && viewModel.posts.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.posts.length) {
            return _loadingIndicator();
          }
          final post = viewModel.posts[index];
          final uniqueKey = UniqueKey();
          return GestureDetector(
            onTap: () => _goToPostDetail(context, post),
            child: AmityPostContentComponent(
              key: uniqueKey,
              pageId: pageId,
              post: post,
              style: AmityPostContentComponentStyle.feed,
              category: AmityPostCategory.general,
              highlightKeyword: searchKeyword,
            ),
          );
        },
      ),
    );
  }

  void _goToPostDetail(BuildContext context, AmityPost post) {
    final postId = post.postId;
    if (postId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityPostDetailPage(
          postId: postId,
          post: post,
        ),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.primaryColor,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

Widget _postSkeletonList(
    AmityThemeColor theme, ConfigProvider configProvider) {
  return Container(
    color: theme.backgroundColor,
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Shimmer(
            linearGradient: configProvider.getShimmerGradient(),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(
                color: theme.baseColorShade4,
                thickness: 8,
                height: 8,
              ),
              itemBuilder: (context, index) => ShimmerLoading(
                isLoading: true,
                child: _postSkeletonItem(),
              ),
              itemCount: 4,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _postSkeletonItem() {
  return Container(
    height: 200,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 32),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonRectangle(height: 8, width: 180),
                  const SizedBox(height: 8),
                  SkeletonRectangle(height: 8, width: 64),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SkeletonRectangle(height: 8, width: 240),
          const SizedBox(height: 12),
          SkeletonRectangle(height: 8, width: 180),
          const SizedBox(height: 12),
          SkeletonRectangle(height: 8, width: 290),
        ],
      ),
    ),
  );
}
