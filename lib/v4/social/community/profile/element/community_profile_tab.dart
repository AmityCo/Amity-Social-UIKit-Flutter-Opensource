import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/profile_tab_item.dart';
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
                children: getProfileTabs(context)
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

  ProfileTabItem  profileTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_community_feed.svg',
      isSelected: selectedIndex == CommunityProfileTabIndex.feed,
      theme: theme,
      onTap: () {
        if (selectedIndex != CommunityProfileTabIndex.feed) {
          onTabSelected(CommunityProfileTabIndex.feed);
        }
      },
    );
  }

  ProfileTabItem pinTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_community_pin.svg',
      isSelected: selectedIndex == CommunityProfileTabIndex.pin,
      theme: theme,
      onTap: () {
        if (selectedIndex != CommunityProfileTabIndex.pin) {
          onTabSelected(CommunityProfileTabIndex.pin);
        }
      },
    );
  }

  ProfileTabItem imageTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_user_image.svg',
      isSelected: selectedIndex == CommunityProfileTabIndex.image,
      theme: theme,
      onTap: () {
        if (selectedIndex != CommunityProfileTabIndex.image) {
          onTabSelected(CommunityProfileTabIndex.image);
        }
      },
    );
  }

  ProfileTabItem videoTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_user_video.svg',
      isSelected: selectedIndex == CommunityProfileTabIndex.video,
      theme: theme,
      onTap: () {
        if (selectedIndex != CommunityProfileTabIndex.video) {
          onTabSelected(CommunityProfileTabIndex.video);
        }
      },
    );
  }

  List<Widget> getProfileTabs(BuildContext context) {
    final featureConfig = configProvider.getFeatureConfig();
    final isImageTabEnabled = featureConfig.post.image.viewImageTabEnabled;
    final isVideoTabEnabled = featureConfig.post.video.viewVideoTabEnabled;

    var items = <Widget>[];
    items.add(profileTab());
    items.add(pinTab());

    if (isImageTabEnabled) {
      items.add(imageTab());
    }

    if (isVideoTabEnabled) {
      items.add(videoTab());
    }
    return items;
  }
}