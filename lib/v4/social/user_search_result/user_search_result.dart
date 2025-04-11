import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/user/user_list.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityUserSearchResultComponent extends NewBaseComponent {
  AmityGlobalSearchViewModel viewModel;

  AmityUserSearchResultComponent({
    Key? key,
    String? pageId,
    required this.viewModel,
  }) : super(key: key, pageId: pageId, componentId: 'user_search_result');

  @override
  Widget buildComponent(BuildContext context) {
    if (viewModel.users.isEmpty) {
      if (viewModel.isUsersFetching) {
        return userSkeletonList(theme, configProvider);
      } else {
        return Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Centers the children within the column
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_search_not_found.svg',
                package: 'amity_uikit_beta_service',
                colorFilter:
                    ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
                width: 47,
                height: 47,
              ),
              const SizedBox(
                  height: 10), // Optional spacing between icon and text
              Text(
                'No results found',
                style: TextStyle(
                  color: theme.baseColorShade3,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return Container(
        color: theme.backgroundColor,
        child: userList(
            context: context,
            scrollController: viewModel.scrollController,
            users: viewModel.users,
            theme: theme,
            loadMore: viewModel.onLoadMore?.call ?? () {},
            onTap: (user) {
              final userId = user.userId;
              if (userId != null && userId.isNotEmpty) {
                AmityUIKit4Manager.behavior.userSearchResultBehavior
                    .goToUserProfilePage(context, userId);
              }
            }),
      );
    }
  }
}
