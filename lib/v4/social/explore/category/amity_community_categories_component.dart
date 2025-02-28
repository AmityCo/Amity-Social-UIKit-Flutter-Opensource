import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_all_categories_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_explore_category_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/category_list_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/communities_by_category/amity_communities_by_category_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunityCategoriesComponent extends NewBaseComponent {
  final Function(CategoryListState) onStateChanged;

  AmityCommunityCategoriesComponent({
    super.key,
    super.pageId,
    required this.onStateChanged,
  }) : super(componentId: 'amity_community_categories_component');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryListCubit()..loadCategories(),
      child: AmityCommunityCategoriesView(
          onStateChanged: onStateChanged, theme: theme),
    );
  }
}

class AmityCommunityCategoriesView extends StatelessWidget {
  final Function(CategoryListState) onStateChanged;
  final AmityThemeColor theme;

  const AmityCommunityCategoriesView({
    Key? key,
    required this.onStateChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryListCubit, CategoryState>(
      listener: (context, state) {
        onStateChanged(context.read<CategoryListCubit>().getCurrentState());
      },
      builder: (context, state) {
        if (state.isLoading) {
          return AmityExploreCategoryShimmer();
        }

        if (state.hasError || state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ...state.categories.take(5).map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildCategoryChip(context, category),
                  )),
              if (state.categories.length > 5) _buildSeeMoreButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
      BuildContext context, AmityCommunityCategory category) {
    return InkWell(
      onTap: () {
        _goToCommunitiesByCategoryPage(context, category);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.baseColorShade4),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            category.avatar != null
                ? ClipOval(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Image.network(
                          category.avatar!.getUrl(AmityImageSize.SMALL),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholderAvatar()),
                    ),
                  )
                : _placeholderAvatar(),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: Text(
                category.name ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _goToAllCategoriesPage(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.baseColorShade4),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See more',
              style: TextStyle(
                color: theme.baseColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: theme.baseColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderAvatar() {
    return SvgPicture.asset(
      'assets/Icons/amity_ic_default_category.svg',
      width: 28,
      height: 28,
      package: 'amity_uikit_beta_service',
      fit: BoxFit.contain,
    );
  }

  void _goToAllCategoriesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmityAllCategoriesPage(),
      ),
    );
  }

  void _goToCommunitiesByCategoryPage(
      BuildContext context, AmityCommunityCategory category) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AmityCommunitiesByCategoryPage(category: category)));
  }
}
