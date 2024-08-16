import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/create_post_menu_component.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/search_communities.dart';
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

        AmityCreatePostMenuComponent(),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}

showActions(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.symmetric(vertical: 4 , horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            

            Container(
              height: 5,
              width: 50,
              padding: const EdgeInsets.all( 5),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(100),
              ),
            ),


            Container(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) { return const AmityCreateStoryPage(); }));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all( 15),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/Icons/ic_story_action.svg",
                        height: 24,
                        package: 'amity_uikit_beta_service',
                      ),
                      const SizedBox(width: 10),
                      const Text("Story" , style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}


