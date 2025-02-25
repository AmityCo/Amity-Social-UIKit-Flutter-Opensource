import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

class UserProfileTab extends BaseElement {
  UserProfileTabIndex selectedIndex;
  Function(UserProfileTabIndex) onTabSelected;

  UserProfileTab({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(elementId: "user_profile_tab");

  @override
  Widget buildElement(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 47,
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16,
          ),
          // clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (selectedIndex != UserProfileTabIndex.feed) {
                          onTabSelected(UserProfileTabIndex.feed);
                        }
                      },
                      child: Container(
                        decoration: (selectedIndex == UserProfileTabIndex.feed)
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 2, color: theme.primaryColor),
                                ),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: theme.backgroundColor,
                              width: double.infinity,
                              height: 37,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        (selectedIndex ==
                                                UserProfileTabIndex.feed)
                                            ? theme.baseColor
                                            : theme.baseColorShade3,
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_user_feed.svg',
                                        package: 'amity_uikit_beta_service',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (selectedIndex != UserProfileTabIndex.image) {
                          onTabSelected(UserProfileTabIndex.image);
                        }
                      },
                      child: Container(
                        decoration: (selectedIndex == UserProfileTabIndex.image)
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 2, color: theme.primaryColor),
                                ),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: theme.backgroundColor,
                              width: double.infinity,
                              height: 37,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        (selectedIndex ==
                                                UserProfileTabIndex.image)
                                            ? theme.baseColor
                                            : theme.baseColorShade3,
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_user_image.svg',
                                        package: 'amity_uikit_beta_service',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (selectedIndex != UserProfileTabIndex.video) {
                          onTabSelected(UserProfileTabIndex.video);
                        }
                      },
                      child: Container(
                        decoration: (selectedIndex == UserProfileTabIndex.video)
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 2, color: theme.primaryColor),
                                ),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              color: theme.backgroundColor,
                              width: double.infinity,
                              height: 37,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        (selectedIndex ==
                                                UserProfileTabIndex.video)
                                            ? theme.baseColor
                                            : theme.baseColorShade3,
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_user_video.svg',
                                        package: 'amity_uikit_beta_service',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(color: theme.baseColorShade4),
        ),
      ],
    );
  }
}
