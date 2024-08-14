import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/search_communities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmitySocialHomeTopNavigationComponent extends NewBaseComponent {
  AmitySocialHomeTopNavigationComponent(
      {Key? key, String? pageId, required String componentId})
      : super(key: key, pageId: pageId, componentId: componentId);

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
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      actions: [
        
        IconButton(
          icon: SvgPicture.asset(
            'assets/Icons/amity_ic_search_button.svg',
            package: 'amity_uikit_beta_service',
            width: 32,
            height: 32,
          ),
          onPressed: () {
            // V3 action
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SearchCommunitiesScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/Icons/amity_ic_create_post_button.svg',
            package: 'amity_uikit_beta_service',
            width: 32,
            height: 32,
          ),
          onPressed: () {
            // V3 action
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Scaffold(body: PostToPage()),
              ),
            );
          },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
