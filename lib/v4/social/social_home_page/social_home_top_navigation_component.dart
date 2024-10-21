import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/create_post_menu_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmitySocialHomeTopNavigationComponent extends NewBaseComponent {
  final AmitySocialHomePageTab selectedTab;
  final void Function()? searchButtonAction;

  AmitySocialHomeTopNavigationComponent({
    Key? key,
    String? pageId,
    required String componentId,
    required this.selectedTab,
    this.searchButtonAction,
  }) : super(key: key, pageId: pageId, componentId: componentId);

  @override
  Widget buildComponent(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        configProvider.getConfig("$pageId/$componentId/header_label")["text"]
            as String,
        style: TextStyle(
          fontSize: 20,
          color: theme.baseColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.secondaryColor.blend(ColorBlendingOption.shade4),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(5),
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_search_button.svg',
              package: 'amity_uikit_beta_service',
              width: 21,
              height: 21,
              colorFilter: ColorFilter.mode(
                theme.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          onPressed: () {
            if (searchButtonAction != null) {
              searchButtonAction!();
            }
          },
        ),
        if (selectedTab != AmitySocialHomePageTab.explore)
          AmityCreatePostMenuComponent(),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}

enum AmitySocialHomePageTab {
  newsFeed,
  explore,
  myCommunities,
}
