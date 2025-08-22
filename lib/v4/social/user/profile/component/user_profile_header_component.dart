import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
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

class AmityUserProfileHeaderComponent extends NewBaseComponent {
  final AmityUser? user;
  final AmityMyFollowInfo? myFollowInfo;
  final AmityUserFollowInfo? userFollowInfo;

  AmityUserProfileHeaderComponent({
    super.key,
    String? pageId = "user_profile_page",
    required this.user,
    this.myFollowInfo,
    this.userFollowInfo,
  }) : super(pageId: pageId, componentId: "user_profile_header");

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
        ? UserProfileHeaderSkeleton()
        : Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  color: theme.backgroundColor,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
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
                            child: AmityUserAvatar(
                              avatarUrl: user?.avatarUrl,
                              displayName: user?.displayName ?? "",
                              isDeletedUser: user?.isDeleted ?? false,
                              avatarSize: const Size(56, 56),
                              characterTextStyle: AmityTextStyle.custom(
                                  32, FontWeight.w400, Colors.white),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: RichText(
                                    maxLines: 4,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: user?.displayName ?? "",
                                          style: AmityTextStyle.headline(
                                              theme.baseColor),
                                        ),
                                        if (user?.isBrand ?? false)
                                          WidgetSpan(
                                            child: brandBadge(),
                                            alignment:
                                                PlaceholderAlignment.middle,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      if (user?.description?.isNotEmpty ?? false) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child:
                              BlocConsumer<UserProfileBloc, UserProfileState>(
                            builder: (context, state) {
                              return AmityExpandableText(
                                theme: theme,
                                text: user?.description ?? "",
                                maxLines: 4,
                                style: AmityTextStyle.body(theme.baseColor),
                                isDetailExpanded: state.isHeaderExpanded,
                                onExpand: () {
                                  profileBloc
                                      .add(UserProfileExpandHeaderEvent());
                                },
                              );
                            },
                            listener: (context, state) {},
                          ),
                        ),
                      ],
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: FollowInfo(followingCount,
                                  context.l10n.profile_following.toLowerCase()),
                              onTap: () {
                                showUserRelationshipPage(context,
                                    AmityUserRelationshipPageTab.following);
                              },
                            ),

                            // Separator
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                  height: 20,
                                  width: 1,
                                  color: theme.baseColorShade4),
                            ),

                            GestureDetector(
                              child: FollowInfo(followerCount,
                                  context.l10n.profile_followers.toLowerCase()),
                              onTap: () {
                                showUserRelationshipPage(context,
                                    AmityUserRelationshipPageTab.follower);
                              },
                            ),
                          ],
                        ),
                      ),

                      // If this is current user profile, we show pending request count
                      if (myFollowInfo != null &&
                          (myFollowInfo?.pendingRequestCount ?? 0) > 0) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AmityUserPendingFollowRequestsPage(
                                  actionCallback: () {
                                    profileBloc
                                        .addEvent(UserFollowInfoFetchEvent());
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
                              padding: const EdgeInsets.only(
                                  top: 12.0, bottom: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 6,
                                        width: 6,
                                        decoration: ShapeDecoration(
                                            shape: const CircleBorder(),
                                            color: theme.primaryColor),
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        context.l10n.user_follow_request_new,
                                        style: AmityTextStyle.bodyBold(
                                            theme.baseColor),
                                      )
                                    ],
                                  ),
                                  Text(
                                    context.l10n.user_follow_request_approval('${myFollowInfo?.pendingRequestCount ?? 0}'),
                                    style: AmityTextStyle.caption(
                                        theme.baseColorShade2),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status == AmityFollowStatus.NONE) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 0),
                          child: UserProfileHeaderActionButton(
                            state: UserProfileHeaderState.followRequest,
                            text: context.l10n.user_follow,
                            tapAction: () {
                              profileBloc
                                  .addEvent(UserProfileUserModerationEvent(
                                action: UserModerationAction.follow,
                                userId: user?.userId ?? "",
                                toastBloc: toastBloc,
                                successMessage:
                                    context.l10n.user_follow_success,
                                errorMessage: context.l10n.user_follow_error,
                                onError: () {
                                  // Need to show popup when user who has been already blocked tries to follow that user.
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text(context
                                              .l10n.user_follow_unable_title),
                                          content: Text(context.l10n
                                              .user_follow_unable_description),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: Text(
                                                context.l10n.general_ok,
                                                style: AmityTextStyle.body(
                                                    theme.highlightColor),
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
                        ),
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.PENDING) ...[
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 0),
                            child: UserProfileHeaderActionButton(
                              state: UserProfileHeaderState.cancelRequest,
                              text: context.l10n.user_follow_cancel,
                              tapAction: () {
                                profileBloc.addEvent(
                                  UserProfileUserModerationEvent(
                                    action: UserModerationAction.unfollow,
                                    userId: user?.userId ?? "",
                                    toastBloc: toastBloc,
                                    successMessage:
                                        context.l10n.user_unfollow_success,
                                    errorMessage:
                                        context.l10n.user_unfollow_error,
                                    onError: () {},
                                  ),
                                );
                              },
                              elementId: "pending_user_button",
                            )),
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.ACCEPTED) ...[
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 0),
                            child: UserProfileHeaderActionButton(
                              state: UserProfileHeaderState.following,
                              text: context.l10n.user_following,
                              tapAction: () {
                                final unfollowOption = BottomSheetMenuOption(
                                  title: context.l10n.user_unfollow,
                                  icon:
                                      "assets/Icons/amity_ic_unfollow_option.svg",
                                  onTap: () {
                                    Navigator.of(context).pop();

                                    final confirmationHandler =
                                        UserModerationConfirmationHandler(
                                            context: context, theme: theme);
                                    confirmationHandler
                                        .askConfirmationToUnfollowUser(
                                            onConfirm: () {
                                      profileBloc.add(
                                        UserProfileUserModerationEvent(
                                          action: UserModerationAction.unfollow,
                                          userId: user?.userId ?? "",
                                          toastBloc: toastBloc,
                                          successMessage: context
                                              .l10n.user_unfollow_success,
                                          errorMessage:
                                              context.l10n.user_unfollow_error,
                                          onError: () {},
                                        ),
                                      );
                                    });
                                  },
                                );

                                BottomSheetMenu(options: [unfollowOption])
                                    .show(context, theme);
                              },
                              elementId: "following_user_button",
                            )),
                      ],

                      if (userFollowInfo != null &&
                          userFollowInfo?.status ==
                              AmityFollowStatus.BLOCKED) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 0),
                          child: UserProfileHeaderActionButton(
                            state: UserProfileHeaderState.unblockUser,
                            text: context.l10n.user_unblock,
                            tapAction: () {
                              final confirmationHandler =
                                  UserModerationConfirmationHandler(
                                      context: context, theme: theme);
                              confirmationHandler.askConfirmationToUnblockUser(
                                displayName: user?.displayName ?? "",
                                onConfirm: () {
                                  profileBloc.add(
                                    UserProfileUserModerationEvent(
                                      action: UserModerationAction.unblock,
                                      userId: user?.userId ?? "",
                                      toastBloc: toastBloc,
                                      successMessage:
                                          context.l10n.user_unblock_success,
                                      errorMessage:
                                          context.l10n.user_unblock_error,
                                      onError: () {},
                                    ),
                                  );
                                },
                              );
                            },
                            elementId: "unblock_user_button",
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget FollowInfo(int count, String title) {
    return Row(
      children: [
        Text(
          count.formattedCompactString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AmityTextStyle.bodyBold(theme.baseColor),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AmityTextStyle.caption(theme.baseColorShade2),
        ),
      ],
    );
  }

  Widget UserProfileHeaderSkeleton() {
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
  final String text;

  UserProfileHeaderActionButton({
    Key? key,
    String? pageId = "user_profile_page",
    String? componentId = "user_profile_header",
    required this.state,
    required this.tapAction,
    required this.text,
    required String elementId,
  }) : super(
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
              text,
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
