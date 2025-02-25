import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/bloc/amity_all_categories_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/communities_by_category/amity_communities_by_category_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityAllCategoriesPage extends NewBasePage {
  final _scrollController = ScrollController();

  AmityAllCategoriesPage({super.key})
      : super(pageId: 'amity_all_categories_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) => AllCategoriesPageBloc(scrollController: _scrollController),
      child: BlocBuilder<AllCategoriesPageBloc, AllCategoriesPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(BuildContext context, AllCategoriesPageState state) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AmityAppBar(
          title: 'All Categories',
          configProvider: configProvider,
          theme: theme),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => {
                    _goToCommunitiesByCategoryPage(
                        context, state.categories[index])
                  },
                  child: _getCategoryItem(context, state.categories[index]),
                );
              },
              childCount: state.categories.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryItem(BuildContext context, CommunityCategory category) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.baseColorShade4,
              ),
              child: category.icon != null
                  ? ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.network(
                            category.icon!.getUrl(AmityImageSize.SMALL),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholderAvatar()),
                      ),
                    )
                  : _placeholderAvatar()),
          const SizedBox(
              width: 8), // Add some spacing between the icon and text
          Expanded(
            child: Text(
              category.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.baseColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Center(
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ),
        ]));
  }

  Widget _placeholderAvatar() {
    return SvgPicture.asset(
      'assets/Icons/amity_ic_default_category.svg',
      width: 40,
      height: 40,
      package: 'amity_uikit_beta_service',
      fit: BoxFit.contain,
    );
  }

  void _goToCommunitiesByCategoryPage(
      BuildContext context, CommunityCategory category) {
    if (category.category == null) {
      return;
    }
    
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AmityCommunitiesByCategoryPage(category: category.category!)));
  }
}
