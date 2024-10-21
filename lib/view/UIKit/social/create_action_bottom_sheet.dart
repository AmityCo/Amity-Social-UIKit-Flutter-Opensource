import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_post_screenV2.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/story_target_page.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class CreateActionBottomSheet {
  static void show(BuildContext context, {AmityCommunity? community, Function? storyCreated}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xffA5A9B5),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              ListTile(
                title: const Text(
                  "Post",
                  style: TextStyle(
                    fontFamily: "SF Pro Text",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: SvgPicture.asset(
                  "assets/Icons/ic_create_post_black.svg",
                  package: 'amity_uikit_beta_service',
                  height: 20,
                  width: 20,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (community != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context2) => AmityCreatePostV2Screen(
                              community: community,
                              feedType: FeedType.community,
                            )));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Scaffold(body: PostToPage()),
                    ));
                  }
                },
              ),
              ListTile(
                title: const Text(
                  "Story",
                  style: TextStyle(
                    fontFamily: "SF Pro Text",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: SvgPicture.asset(
                  "assets/Icons/ic_create_stroy_black.svg",
                  package: 'amity_uikit_beta_service',
                  height: 24,
                  width: 24,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (community != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                      return CreateStoryConfigProviderWidget(
                        targetType: AmityStoryTargetType.COMMUNITY,
                        targetId: community.communityId!,
                        pageId: 'create_story_page',
                      );
                    }));
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Scaffold(
                          body: AmityStoryTargetSelectionPage(
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
