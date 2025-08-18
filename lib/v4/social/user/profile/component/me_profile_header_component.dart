import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/pending_requests/user_pending_follow_request_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/user_moderation_confirmation_handler.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/expandable_text.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class MeProfileHeaderComponent extends NewBaseComponent {
  final AmityUser? user;
  final AmityMyFollowInfo? myFollowInfo;
  final AmityUserFollowInfo? userFollowInfo;
  final Widget? customProfile;

  MeProfileHeaderComponent({
    super.key,
    String? pageId = "user_profile_page",
    required this.user,
    this.myFollowInfo,
    this.userFollowInfo,
    this.customProfile,
  }) : super(pageId: pageId, componentId: "user_profile_header");

  Color get greyColor => const Color(0xff5D5F71);

  @override
  Widget buildComponent(BuildContext context) {
    final followingCount = myFollowInfo != null
        ? myFollowInfo?.followingCount ?? 0
        : userFollowInfo?.followingCount ?? 0;

    final followerCount = myFollowInfo != null
        ? myFollowInfo?.followerCount ?? 0
        : userFollowInfo?.followerCount ?? 0;

    final profileBloc = context.read<UserProfileBloc>();
    final toastBloc = context.read<AmityToastBloc>();

    return (user == null)
        ? userProfileHeaderSkeleton()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildAvatar(context),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDisplayName(context),
                                _buildFollowInfo(
                                  context,
                                  followerCount,
                                  followingCount,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      if (user?.description?.isNotEmpty ?? false) ...[
                        _buildDescription(
                          profileBloc,
                        )
                      ],

                      // If this is current user profile, we show pending request count
                      if (myFollowInfo != null &&
                          (myFollowInfo?.pendingRequestCount ?? 0) > 0) ...[
                        _buildPendingFollowRequest(
                          context,
                          profileBloc,
                        )
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status == AmityFollowStatus.NONE) ...[
                        _buildFollowButton(
                          context,
                          profileBloc,
                          toastBloc,
                        )
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.PENDING) ...[
                        _buildCancelFollowRequestButton(
                          context,
                          profileBloc,
                          toastBloc,
                        )
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.ACCEPTED) ...[
                        _buildShowFollowingButton(
                          context,
                          profileBloc,
                          toastBloc,
                        )
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.BLOCKED) ...[
                        _buildShowUnblockButton(
                          context,
                          profileBloc,
                          toastBloc,
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final avatarUrl = user?.avatarUrl;
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => AmityImageViewer(
                imageUrl: "$avatarUrl?size=large",
              ),
            ),
          );
        }
      },
      child: customProfile ??
          AmityUserAvatar(
            avatarUrl: user?.avatarUrl,
            displayName: user?.displayName ?? "",
            isDeletedUser: user?.isDeleted ?? false,
            avatarSize: const Size(56, 56),
            characterTextStyle:
                AmityTextStyle.custom(32, FontWeight.w400, Colors.white),
          ),
    );
  }

  Widget _buildDisplayName(BuildContext context) {
    return Flexible(
      child: RichText(
        maxLines: 4,
        text: TextSpan(
          children: [
            TextSpan(
              text: user?.displayName ?? "",
              style: AmityTextStyle.headline(theme.baseColor).copyWith(
                fontSize: 16,
              ),
            ),
            if (user?.isBrand ?? false)
              WidgetSpan(
                child: brandBadge(),
                alignment: PlaceholderAlignment.middle,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowInfo(
      BuildContext context, int followerCount, int followingCount) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            child: followInfo(followerCount, "Followers"),
            onTap: () {
              showUserRelationshipPage(
                  context, AmityUserRelationshipPageTab.follower);
            },
          ),
          const SizedBox(width: 8),
          GestureDetector(
            child: followInfo(followingCount, "Following"),
            onTap: () {
              showUserRelationshipPage(
                  context, AmityUserRelationshipPageTab.following);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(UserProfileBloc profileBloc) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BlocConsumer<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return AmityExpandableText(
            theme: theme,
            text: user?.description ?? "",
            maxLines: 4,
            style: AmityTextStyle.body(theme.baseColor).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            isDetailExpanded: state.isHeaderExpanded,
            onExpand: () {
              profileBloc.add(UserProfileExpandHeaderEvent());
            },
          );
        },
        listener: (context, state) {},
      ),
    );
  }

  Widget _buildPendingFollowRequest(
      BuildContext context, UserProfileBloc profileBloc) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AmityUserPendingFollowRequestsPage(
              actionCallback: () {
                profileBloc.addEvent(UserFollowInfoFetchEvent());
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: theme.backgroundShade1Color,
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 6,
                    width: 6,
                    decoration: ShapeDecoration(
                        shape: const CircleBorder(), color: theme.primaryColor),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(
                    "New follow requests",
                    style: AmityTextStyle.bodyBold(theme.baseColor),
                  )
                ],
              ),
              Text(
                "${myFollowInfo?.pendingRequestCount ?? 0} requests need your approval",
                style: AmityTextStyle.caption(theme.baseColorShade2),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(
    BuildContext context,
    UserProfileBloc profileBloc,
    AmityToastBloc toastBloc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: UserProfileHeaderActionButton(
        state: UserProfileHeaderState.followRequest,
        tapAction: () {
          profileBloc.addEvent(UserProfileUserModerationEvent(
            action: UserModerationAction.follow,
            userId: user?.userId ?? "",
            toastBloc: toastBloc,
            onError: () {
              // Need to show popup when user who has been already blocked tries to follow that user.
              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("Unable to follow this user"),
                      content: const Text(
                          "Oops! something went wrong. Please try again later."),
                      actions: [
                        CupertinoDialogAction(
                          child: Text(
                            "OK",
                            style: AmityTextStyle.body(theme.highlightColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            },
          ));
        },
        elementId: "follow_user_button",
      ),
    );
  }

  Widget _buildCancelFollowRequestButton(
    BuildContext context,
    UserProfileBloc profileBloc,
    AmityToastBloc toastBloc,
  ) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: UserProfileHeaderActionButton(
          state: UserProfileHeaderState.cancelRequest,
          tapAction: () {
            profileBloc.addEvent(
              UserProfileUserModerationEvent(
                action: UserModerationAction.unfollow,
                userId: user?.userId ?? "",
                toastBloc: toastBloc,
                onError: () {},
              ),
            );
          },
          elementId: "pending_user_button",
        ));
  }

  Widget _buildShowFollowingButton(
    BuildContext context,
    UserProfileBloc profileBloc,
    AmityToastBloc toastBloc,
  ) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: UserProfileHeaderActionButton(
          state: UserProfileHeaderState.following,
          tapAction: () {
            final unfollowOption = BottomSheetMenuOption(
              title: "Unfollow",
              icon: "assets/Icons/amity_ic_unfollow_option.svg",
              onTap: () {
                Navigator.of(context).pop();

                final confirmationHandler = UserModerationConfirmationHandler(
                    context: context, theme: theme);
                confirmationHandler.askConfirmationToUnfollowUser(
                    onConfirm: () {
                  profileBloc.add(
                    UserProfileUserModerationEvent(
                      action: UserModerationAction.unfollow,
                      userId: user?.userId ?? "",
                      toastBloc: toastBloc,
                      onError: () {},
                    ),
                  );
                });
              },
            );

            BottomSheetMenu(options: [unfollowOption]).show(context, theme);
          },
          elementId: "following_user_button",
        ));
  }

  Widget _buildShowUnblockButton(
    BuildContext context,
    UserProfileBloc profileBloc,
    AmityToastBloc toastBloc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: UserProfileHeaderActionButton(
        state: UserProfileHeaderState.unblockUser,
        tapAction: () {
          final confirmationHandler =
              UserModerationConfirmationHandler(context: context, theme: theme);
          confirmationHandler.askConfirmationToUnblockUser(
            displayName: user?.displayName ?? "",
            onConfirm: () {
              profileBloc.add(
                UserProfileUserModerationEvent(
                  action: UserModerationAction.unblock,
                  userId: user?.userId ?? "",
                  toastBloc: toastBloc,
                  onError: () {},
                ),
              );
            },
          );
        },
        elementId: "unblock_user_button",
      ),
    );
  }

  Widget followInfo(int count, String title) {
    return Row(
      children: [
        Text(
          count.formattedCompactString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AmityTextStyle.bodyBold(theme.baseColor).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: greyColor,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AmityTextStyle.caption(theme.baseColorShade2).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: greyColor,
          ),
        ),
      ],
    );
  }

  Widget userProfileHeaderSkeleton() {
    return Shimmer(
      linearGradient: configProvider.getShimmerGradient(),
      child: Container(
        width: double.infinity,
        // height: 156,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: ShimmerLoading(
          isLoading: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Circle
                    SkeletonCircle(size: 56),

                    const SizedBox(width: 12),

                    SkeletonRectangle(width: 200, height: 12)
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                SkeletonRectangle(
                  height: 8,
                  width: 240,
                ),
                const SizedBox(
                  height: 12,
                ),
                SkeletonRectangle(
                  height: 8,
                  width: 300,
                ),
                const SizedBox(
                  height: 22,
                ),
                Row(
                  children: [
                    SkeletonRectangle(
                      height: 12,
                      width: 54,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    SkeletonRectangle(
                      height: 12,
                      width: 54,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget brandBadge() {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_brand.svg',
        package: 'amity_uikit_beta_service',
        fit: BoxFit.fill,
        width: 24,
        height: 24,
      ),
    );
  }

  // Actions
  void showUserRelationshipPage(
    BuildContext context,
    AmityUserRelationshipPageTab selectedTab,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AmityUserRelationshipPage(
            userId: user?.userId ?? "", selectedTab: selectedTab),
      ),
    );
  }
}

enum UserProfileHeaderState {
  followRequest,
  cancelRequest,
  following,
  unblockUser,
}

class UserProfileHeaderActionButton extends BaseElement {
  final UserProfileHeaderState state;
  final Function tapAction;

  UserProfileHeaderActionButton(
      {Key? key,
      String? pageId = "user_profile_page",
      String? componentId = "user_profile_header",
      required this.state,
      required this.tapAction,
      required String elementId})
      : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId: elementId);

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 10,
        left: 0,
        right: 0,
        bottom: 10,
      ),
      decoration: (state == UserProfileHeaderState.followRequest)
          ? ShapeDecoration(
              color: theme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            )
          : BoxDecoration(
              border: Border.all(
                  color:
                      theme.secondaryColor.blend(ColorBlendingOption.shade3)),
              borderRadius: BorderRadius.circular(8),
            ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          tapAction();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                getAsset(),
                package: 'amity_uikit_beta_service',
              ),
            ),
            const SizedBox(width: 4),
            Text(
              uiConfig.text ?? "",
              style: (state == UserProfileHeaderState.followRequest)
                  ? AmityTextStyle.bodyBold(
                      Colors.white,
                      textHeight: 1.0,
                    )
                  : AmityTextStyle.bodyBold(
                      theme.secondaryColor,
                      textHeight: 1.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String getAsset() {
    switch (state) {
      case UserProfileHeaderState.followRequest:
        return 'assets/Icons/amity_ic_follow_button.svg';
      case UserProfileHeaderState.cancelRequest:
        return 'assets/Icons/amity_ic_follow_request_cancel_button.svg';
      case UserProfileHeaderState.following:
        return 'assets/Icons/amity_ic_follow_following_button.svg';
      case UserProfileHeaderState.unblockUser:
        return 'assets/Icons/amity_ic_block_user.svg';
    }
  }
}
