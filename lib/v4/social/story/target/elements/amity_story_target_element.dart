import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/elements/amity_story_gradient_ring_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/utils%20/amity_story_target_ext.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryTargetElement extends BaseElement {
  bool isCommunityTarget = false;
  String communityDisplayName = "";
  String avatarUrl = "";
  bool isPublicCommunity = false;
  bool isOfficialCommunity = false;
  bool hasManageStoryPermission = false;
  AmityStoryTargetRingUiState ringUiState;
  AmityStoryTarget target;
  Function(String, AmityStoryTarget) onClick;
  String targetId;
  List<Color> colors = [];
  bool showLoading = false;
  String? pageId;
    String? componentId;

  AmityStoryTargetElement({
    super.key,
    required this.avatarUrl,
    this.isCommunityTarget = false,
    this.communityDisplayName = "",
    required this.ringUiState,
    this.isPublicCommunity = false,
    this.isOfficialCommunity = false,
    this.hasManageStoryPermission = false,
    required this.targetId,
    required this.onClick,
    required this.target,
    this.pageId,
    this.componentId,
  }): super( pageId: pageId, componentId: componentId , elementId:"story_ring" );

  Widget getProfileIcon(AmityStoryTarget storyTarget) {
    if (storyTarget is AmityStoryTargetCommunity) {
      return storyTarget.community?.avatarImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(100),
            child: AmityNetworkImage(
                imageUrl: storyTarget.community!.avatarImage!.fileUrl!,
                placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
              ),
          )
          : const AmityNetworkImage(
              imageUrl: "",
              placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
            );
    }

    return const AmityNetworkImage(imageUrl: "", placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg");
  }
  
  @override
  Widget buildElement(BuildContext context) {
    String? badge;

    if (ringUiState == AmityStoryTargetRingUiState.FAILED) {
      badge = "assets/Icons/ic_warning_circle_red.svg";
    } else if (hasManageStoryPermission) {
      badge = "assets/Icons/ic_add_circle_blue.svg";
    } else if (isOfficialCommunity && !isCommunityTarget) {
      badge = "assets/Icons/ic_verified_blue.svg";
    } else {
      badge = null;
    }

    switch (ringUiState) {
      case AmityStoryTargetRingUiState.SEEN:
        colors = [Color(0xffEBECEF)];
        showLoading = false;
        break;

      case AmityStoryTargetRingUiState.SYNCING:
        colors = [Color(0xffEBECEF), const Color(0xff339AF9)];
        showLoading = true;
        break;
      case AmityStoryTargetRingUiState.HAS_UNSEEN:
        colors = [const Color(0xff339AF9), const Color(0xff78FA58)];
        showLoading = false;
        break;

      case AmityStoryTargetRingUiState.FAILED:
        colors = [theme.alertColor];
        showLoading = false;
        break;
    }
    return
    GestureDetector(
      onTap: () {
        onClick(targetId, target);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: isCommunityTarget ? 52 : 72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 49,
              child: Stack(
                children: [
                  ( showLoading) ? AmityStoryGradientRingElement(
                    backgoundColor: theme.backgroundColor,
                    colors: colors,
                    isIndeterminate: true,
                    child: SizedBox( width: 40 , height: 40 ,child: getProfileIcon(target)),
                  ): AmityStoryGradientRingElement(
                    colors: colors,
                    backgoundColor: theme.backgroundColor,
                    isIndeterminate: false,
                    child: SizedBox( width: 40 , height: 40 ,child: getProfileIcon(target)),
                  ),
                  badge != null
                      ? Positioned(
                          right: 0,
                          bottom: 0,
                          child: SvgPicture.asset(
                            badge,
                            package: 'amity_uikit_beta_service',
                            height: 14,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPublicCommunity && !isCommunityTarget)
                  SvgPicture.asset(
                    "assets/Icons/ic_lock_black.svg",
                    height: 12,
                    color: theme.baseColor,
                    package: 'amity_uikit_beta_service',
                  ),
                if (!isPublicCommunity && !isCommunityTarget)
                  const SizedBox(
                    width: 4,
                  ),
                Expanded(
                  child: Center(
                    child: Text(
                      isCommunityTarget ? "Story" : communityDisplayName,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 13,
                        color: theme.baseColor,
                        fontFamily: "SF Pro Text",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // if (hasManageStoryPermission)
                //   Icon(Icons.edit, size: 16, color: Colors.amber),
              ],
            )
          ],
        ),
      ),
    );
  }
}


// Provider.of<AmityUIConfiguration>(context).appColors.base
