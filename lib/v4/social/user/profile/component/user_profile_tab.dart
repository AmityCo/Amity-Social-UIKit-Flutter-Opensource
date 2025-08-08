import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/profile_tab_item.dart';
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
                children: getProfileTabs(context),
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

  ProfileTabItem videoTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_user_video.svg',
      isSelected: selectedIndex == UserProfileTabIndex.video,
      theme: theme,
      onTap: () {
        if (selectedIndex != UserProfileTabIndex.video) {
          onTabSelected(UserProfileTabIndex.video);
        }
      },
    );
  }

  ProfileTabItem imageTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_user_image.svg',
      isSelected: selectedIndex == UserProfileTabIndex.image,
      theme: theme,
      onTap: () {
        if (selectedIndex != UserProfileTabIndex.image) {
          onTabSelected(UserProfileTabIndex.image);
        }
      },
    );
  }

  ProfileTabItem profileTab() {
    return ProfileTabItem(
      image: 'assets/Icons/amity_ic_user_feed.svg',
      isSelected: selectedIndex == UserProfileTabIndex.feed,
      theme: theme,
      onTap: () {
        if (selectedIndex != UserProfileTabIndex.feed) {
          onTabSelected(UserProfileTabIndex.feed);
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

    if (isImageTabEnabled) {
      items.add(imageTab());
    }

    if (isVideoTabEnabled) {
      items.add(videoTab());
    }
    return items;
  }
}
