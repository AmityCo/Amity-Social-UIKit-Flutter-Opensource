import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MeProfileTabComponent extends BaseElement {
  UserProfileTabIndex selectedIndex;
  Function(UserProfileTabIndex) onTabSelected;

  MeProfileTabComponent({
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
          height: 40,

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
                                  bottom:
                                      BorderSide(width: 2, color: theme.greenColor),
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
                              height: 30,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Timeline',
                                    style: TextStyle(
                                      color: (selectedIndex ==
                                              UserProfileTabIndex.feed)
                                          ? theme.greenColor
                                          : theme.baseColorShade3,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
                                  bottom:
                                      BorderSide(width: 2, color: theme.greenColor),
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
                              height: 30,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gallery',
                                    style: TextStyle(
                                      color: (selectedIndex ==
                                              UserProfileTabIndex.image)
                                          ? theme.greenColor
                                          : theme.baseColorShade3,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
                                    width: 2,
                                    color: theme.greenColor,
                                  ),
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
                              height: 30,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Videos',
                                    style: TextStyle(
                                      color: (selectedIndex ==
                                              UserProfileTabIndex.video)
                                          ? theme.greenColor
                                          : theme.baseColorShade3,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
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
      ],
    );
  }
}
