import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/component/community_header_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunityCoverView extends BaseElement {
  final AmityCommunity? community;
  final AmityCommunityHeaderStyle style;

  AmityCommunityCoverView({
    super.key,
    required this.community,
    required this.style,
  }) : super(elementId: "community_cover");

  @override
  Widget buildElement(BuildContext context) {
    switch (style) {
      case AmityCommunityHeaderStyle.EXPANDED:
        return Container(
          width: double.infinity,
          height: 188,
          child: Stack(
            fit: StackFit.expand,
            children: [
              renderAvatarImage(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => {Navigator.pop(context)},
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/Icons/amity_ic_back_button.svg",
                            package: 'amity_uikit_beta_service',
                            height: 18,
                            width: 18,
                          ),
                        ),
                      ),
                    ),
                    Flexible(flex: 1, child: Container()),
                    GestureDetector(
                      onTap: () => {
                        if (community != null)
                          {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context2) => CommunitySettingPage(
                                      community: community!,
                                    )))
                          }
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/Icons/amity_ic_post_item_option.svg",
                            package: 'amity_uikit_beta_service',
                            height: 18,
                            width: 18,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case AmityCommunityHeaderStyle.COLLAPSE:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: renderAvatarImage()),
        );
    }
  }

  Widget renderAvatarImage() {
    final url = community?.avatarImage?.getUrl(AmityImageSize.LARGE);
    return (url != null)
        ? AmityNetworkImage(
            imageUrl: url,
            placeHolderPath: '',
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.14, -0.99),
                end: Alignment(0.14, 0.99),
                colors: [Color(0xFFA5A9B5), Color(0xFF898E9E)],
              ),
            ),
          );
  }
}
