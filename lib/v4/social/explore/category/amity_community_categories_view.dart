import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_explore_category_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/category_list_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommunityCategoriesView extends NewBaseComponent {
  AmityCommunityCategoriesView(this.onStateChanged, {super.key})
      : super(componentId: "community_recommended_community_shimmer");

  final Function(CategoryListState) onStateChanged;


  @override
  Widget buildComponent(BuildContext context) {
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
              if (state.categories.length > 5)
                _buildSeeMoreButton(context),
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AmityCommunitiesByCategoryPage(categoryId: category.categoryId),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.avatar != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Image.network(
                  category.avatar?.fileUrl ?? '',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            Text(
              category.name ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return InkWell(
      onTap: () {
        //TODO Amity: AmityCommunitySetupPage
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const AmityAllCategoriesPage(),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See more',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
