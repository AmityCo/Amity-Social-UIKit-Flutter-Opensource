import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommunityProfileTab extends BaseElement {
  CommunityProfileTabIndex selectedIndex;
  Function(CommunityProfileTabIndex) onTabSelected;

  CommunityProfileTab({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(elementId: "community_profile_tab");

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
                        if (selectedIndex != CommunityProfileTabIndex.feed) {
                          onTabSelected(CommunityProfileTabIndex.feed);
                        }
                      },
                      child: Container(
                        decoration:
                            (selectedIndex == CommunityProfileTabIndex.feed)
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
                                                CommunityProfileTabIndex.feed)
                                            ? theme.baseColor
                                            : theme.baseColorShade3,
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_community_feed.svg',
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
                        if (selectedIndex != CommunityProfileTabIndex.pin) {
                          onTabSelected(CommunityProfileTabIndex.pin);
                        }
                      },
                      child: Container(
                        decoration:
                            (selectedIndex == CommunityProfileTabIndex.pin)
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
                                                CommunityProfileTabIndex.pin)
                                            ? theme.baseColor
                                            : theme.baseColorShade3,
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/Icons/amity_ic_community_pin.svg',
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
