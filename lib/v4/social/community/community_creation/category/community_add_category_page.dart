import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/category/bloc/community_add_category_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

// ignore: must_be_immutable
class AmityCommunityAddCategoryPage extends NewBasePage {
  final ScrollController _scrollController = ScrollController();
  List<CommunityCategory> categories = [];
  Function(List<CommunityCategory>)? onAddedAction;

  AmityCommunityAddCategoryPage(
      {super.key, required this.categories, this.onAddedAction})
      : super(pageId: 'community_add_category_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => CommunityAddCategoryPageBloc(categories),
      child: BlocBuilder<CommunityAddCategoryPageBloc,
          CommunityAddCategoryPageState>(
        builder: (context, state) {
          _setupScrollListener(context);
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  void _setupScrollListener(BuildContext context) {
    _scrollController.removeListener(() {});
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      const threshold = 200.0; // Load more when within 200 pixels of the bottom

      if (maxScroll - currentScroll <= threshold) {
        context
            .read<CommunityAddCategoryPageBloc>()
            .add(CommunityAddCategoryPageLoadMoreEvent());
      }
    });
  }

  Widget _getPageWidget(
      BuildContext context, CommunityAddCategoryPageState state) {
    return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AmityAppBar(
            title: 'Select Category',
            configProvider: configProvider,
            theme: theme,
            displayBottomLine: true,
            tailingButton: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${state.selectedCategories.length}/10',
                style: TextStyle(
                    color: theme.baseColorShade1,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
            )),
        body: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...state.selectedCategories.isNotEmpty
                    ? [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: CategoryGridView(
                              items: state.selectedCategories,
                              theme: theme,
                              onTap: (category) {
                                context.read<CommunityAddCategoryPageBloc>().add(
                                    CommunityAddCategoryPageCategorySelectedEvent(
                                        category));
                              },
                            )),
                        _getDividerWidget(),
                      ]
                    : [Container()],
              ],
            ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            context.read<CommunityAddCategoryPageBloc>().add(
                                CommunityAddCategoryPageCategorySelectedEvent(
                                    state.categories[index]));
                          },
                          child: _getCategoryItem(
                              context, state, state.categories[index]),
                        );
                      },
                      childCount: state.categories.length,
                    ),
                  ),
                ],
              ),
            ),
            _getDividerWidget(),
            _getAddCategoryButton(context, state)
          ],
        ));
  }

  Widget _getCategoryItem(BuildContext context,
      CommunityAddCategoryPageState state, CommunityCategory category) {
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
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.baseColorShade4,
                        image: DecorationImage(
                          image: NetworkImage(
                              category.icon!.getUrl(AmityImageSize.SMALL)),
                          fit: BoxFit.cover,
                        ),
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
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: state.selectedCategories
                  .map((e) => e.id)
                  .contains(category.id),
              onChanged: (value) {
                context.read<CommunityAddCategoryPageBloc>().add(
                    CommunityAddCategoryPageCategorySelectedEvent(category));
              },
              shape: const CircleBorder(),
              activeColor: theme.primaryColor,
            ),
          )
        ]));
  }

  Widget _getAddCategoryButton(
      BuildContext context, CommunityAddCategoryPageState state) {
    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              if (state.hasCategoriesChanged) {
                context
                    .read<CommunityAddCategoryPageBloc>()
                    .add(CommunityAddCategoryAddCategoryEvent(onSuccess: () {
                  onAddedAction?.call(state.selectedCategories);
                }));
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: !state.hasCategoriesChanged
                      ? theme.primaryColor.blend(ColorBlendingOption.shade2)
                      : theme.primaryColor, // Rectangle background color
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: Text(
                    "Add Category",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                )),
          )),
        ],
      ),
    );
  }

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: theme.baseColorShade4,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          height: 1,
        ));
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
}
