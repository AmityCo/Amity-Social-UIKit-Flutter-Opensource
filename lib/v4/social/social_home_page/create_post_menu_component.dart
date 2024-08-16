// Define the PopupMenu class
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_target_selection_page/post_target_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
            color: theme.baseColorShade4,
            shape: BoxShape.circle, // Makes the container a circle
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
                package: 'amity_uikit_beta_service'),
            padding: const EdgeInsets.all(5),
            onSelected: (int result) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => PopScope(
                    canPop: true,
                    child: PostTargetSelectionPage(
                      pageId: '',
                    ),
                  ),
                ),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: getMenu(
                    text: "Post", iconPath: "amity_ic_create_post_button.svg"),
              ),
              // PopupMenuItem<int>(
              //   value: 2,
              //   child: getMenu(
              //         text: "Story", iconPath: "amity_ic_create_post_button.svg"),
              // ),
            ],
          ),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget getMenu({required String text, required String iconPath}) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          SvgPicture.asset("assets/Icons/$iconPath",
              package: 'amity_uikit_beta_service'),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
