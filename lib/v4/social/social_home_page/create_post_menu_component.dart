// Define the PopupMenu class
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_target_selection_page/post_target_selection_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/story_target_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../post_poll_target_selection_page/post_poll_target_selection_page.dart';

class AmityCreatePostMenuComponent extends NewBaseComponent {

  AmityCreatePostMenuComponent({Key? key, String? pageId})
      : super(key: key, pageId: pageId, componentId: 'componentId');

  @override
  Widget buildComponent(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.secondaryColor.blend(ColorBlendingOption.shade4),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<int>(
            color: theme.backgroundColor,
            surfaceTintColor: theme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            offset: const Offset(-18, 40),
            icon: SvgPicture.asset(
              "assets/Icons/amity_ic_post_creation_button.svg",
              package: 'amity_uikit_beta_service',
              colorFilter: ColorFilter.mode(
                theme.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
            padding: const EdgeInsets.all(5),
            onSelected: (int result) {
              if (result == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => PopScope(
                      canPop: true,
                      child: AmityPostTargetSelectionPage(),
                    ),
                  ),
                );
              }

              if (result == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: AmityStoryTargetSelectionPage(),
                    ),
                  ),
                );
              }

              if (result == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: AmityPostPollTargetSelectionPage(),
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => getPopupMenuItems(context),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  List<PopupMenuItem<int>> getPopupMenuItems(BuildContext context) {
    final menuItems = <PopupMenuItem<int>>[];

    final featureConfig = configProvider.getFeatureConfig();

    if (featureConfig.post.isPostCreationEnabled()) {
      menuItems.add(
        PopupMenuItem<int>(
          value: 1,
          child: getMenu(
              context: context, text: context.l10n.general_post, iconPath: "amity_ic_create_post_button.svg"),
        ),
      );
    }

    if (featureConfig.story.createEnabled) {
      menuItems.add(
        PopupMenuItem<int>(
          value: 2,
          child: getMenu(
              context: context, text: context.l10n.general_story, iconPath: "ic_create_stroy_black.svg"),
        ),
      );
    }

    if (featureConfig.post.poll.createEnabled) {
      menuItems.add(
        PopupMenuItem<int>(
          value: 3,
          child: getMenu(
              context: context, text: context.l10n.general_poll, iconPath: "amity_ic_create_poll_button.svg"),
        ),
      );
    }
    return menuItems;
  } 

  Widget getMenu({required BuildContext context, required String text, required String iconPath}) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          SvgPicture.asset(
            "assets/Icons/$iconPath",
            package: 'amity_uikit_beta_service',
            colorFilter:
                ColorFilter.mode(theme.secondaryColor, BlendMode.srcIn),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  color: theme.baseColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
