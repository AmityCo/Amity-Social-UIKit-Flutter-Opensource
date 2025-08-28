import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post_poll_composer_page/post_poll_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/image_feed/user_image_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/edit_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/user_moderation_confirmation_handler.dart';
import 'package:amity_uikit_beta_service/v4/social/user/video_feed/user_video_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:animation_wrappers/animations/fade_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';
import 'package:provider/provider.dart';

import 'package:amity_uikit_beta_service/v4/social/user/profile/bloc/user_profile_bloc.dart';
import 'components/bitazza_me_profile_header_component.dart';
import 'components/bitazza_me_profile_tab_component.dart';

class BitazzaMePage extends NewBasePage {
  final String userId;
  final bool? isEnableAppbar;
  final Widget? customActions;
  final Widget? customProfile;
  final Widget? customHeader;
  final String? avatarUrl;
  final Widget avatar;
  final String rarity;

  BitazzaMePage({
    super.key,
    required this.userId,
    required this.avatar,
    this.isEnableAppbar = true,
    this.customActions,
    this.customProfile,
    this.customHeader,
    this.avatarUrl,
    this.rarity = "Common",
  }) : super(pageId: 'bitazza_me_page');

  final ScrollController _scrollController = ScrollController();

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(userId),
      child: Builder(builder: (context) {
        return BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            _scrollController.addListener(() {
              if (_scrollController.hasClients &&
                  _scrollController.offset >
                      MediaQuery.of(context).size.height * 0.3) {
                context
                    .read<UserProfileBloc>()
                    .add(const ShowUserNameOnAppBarEvent(showUserName: true));
              } else {
                context
                    .read<UserProfileBloc>()
                    .add(const ShowUserNameOnAppBarEvent(showUserName: false));
              }
            });

            return Scaffold(
              appBar: (isEnableAppbar ?? true)
                  ? AppBar(
                      centerTitle: true,
                      title: state.showUserNameOnAppBar
                          ? Text(
                              state.user?.displayName ?? "",
                              style: AmityTextStyle.titleBold(theme.baseColor),
                            )
                          : null,
                      scrolledUnderElevation: 0,
                      backgroundColor: theme.backgroundColor,
                      leading: IconButton(
                        icon: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              theme.baseColor, BlendMode.srcIn),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_nav_back_button.svg',
                            package: 'amity_uikit_beta_service',
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: theme.baseColor,
                          ),
                          iconSize: 24,
                          onPressed: () {
                            showUserEditActions(
                              context,
                              state.user,
                              state.userFollowInfo?.status,
                            );
                          },
                        )
                      ],
                    )
                  : null,
              backgroundColor: theme.backgroundColor,
              body: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: MediaQuery.of(context).size.height * 0.4,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero,
                      expandedTitleScale: 1,
                      title: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 16.0,
                              sigmaY: 16.0,
                              tileMode: TileMode.clamp,
                            ),
                            child: avatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: avatarUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    repeat: ImageRepeat.noRepeat,
                                    alignment: Alignment.center,
                                  )
                                : const Image(
                                    image: AssetImage(
                                        'assets/images/default_avatar.png'),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (_getRarityTintColor(rarity) != null)
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color:
                                  _getRarityTintColor(rarity)!.withOpacity(0.3),
                            ),
                          if (!state.showUserNameOnAppBar) avatar,
                        ],
                      ),
                    ),
                    title: customHeader ?? Container(),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: BitazzaMeProfileHeaderComponent(
                            user: state.user,
                            myFollowInfo: state.myFollowInfo,
                            userFollowInfo: state.userFollowInfo,
                            customProfile: customProfile,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildItems(context, state, userId),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: BitazzaMeProfileTabComponent(
                        selectedIndex: state.selectedIndex,
                        onTabSelected: (index) {
                          context
                              .read<UserProfileBloc>()
                              .add(UserProfileEventTabSelected(tab: index));
                        },
                      ),
                    ),
                  ),
                  if (state.selectedIndex == UserProfileTabIndex.feed)
                    UserFeedComponent(
                      key: Key(
                          "user_feed_${state.userId}_${state.userFollowInfo?.status.name ?? ""}"),
                      pageId: pageId,
                      userId: state.userId,
                      scrollController: _scrollController,
                      userFollowInfo: state.userFollowInfo,
                    ),
                  if (state.selectedIndex == UserProfileTabIndex.image)
                    UserImageFeedComponent(
                      key: Key(
                          "image_feed_${state.userId}_${state.userFollowInfo?.status.name ?? ""}"),
                      pageId: pageId,
                      userId: state.userId,
                      scrollController: _scrollController,
                    ),
                  if (state.selectedIndex == UserProfileTabIndex.video)
                    UserVideoFeedComponent(
                      key: Key(
                          "video_feed_${state.userId}_${state.userFollowInfo?.status.name ?? ""}"),
                      pageId: pageId,
                      userId: state.userId,
                      scrollController: _scrollController,
                    )
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: userId != AmityCoreClient.getUserId()
                  ? Container()
                  : SizedBox(
                      height: 64,
                      width: 64,
                      child: FloatingActionButton(
                        onPressed: () {
                          showUserProfileActions(context);
                        },
                        shape: const CircleBorder(),
                        backgroundColor: theme.lightGreenColor,
                        elevation: 1,
                        focusElevation: 0,
                        highlightElevation: 0,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: SvgPicture.asset(
                            'assets/Icons/ic_create_post_black.svg',
                            package: 'amity_uikit_beta_service',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ),
            );
          },
        );
      }),
    );
  }

  Color? _getRarityTintColor(String? avatarRarity) {
    if (avatarRarity == null) return null;

    switch (avatarRarity) {
      case 'Epic':
        return const Color(0xFF7223CD);
      case 'Uncommon':
        return const Color(0xFF68E075);
      case 'Rare':
        return const Color(0xFF2532CE);
      case 'Common':
        return null; // No tint for common, just blur
      case 'Legendary':
        return const Color(0xFF7223CD);
      default:
        return null;
    }
  }

  Widget _buildItems(
    BuildContext context,
    UserProfileState state,
    String userId,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          state.user?.userId == userId
              ? customActions ?? const SizedBox.shrink()
              : (state.userFollowInfo?.status == AmityFollowStatus.ACCEPTED)
                  ? Provider.of<AmityUIConfiguration>(
                      context,
                      listen: false,
                    ).widgetBuilders.buildMessageButton(
                        state.user,
                      )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(),
                            child: state.userFollowInfo?.id == null
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Provider.of<AmityUIConfiguration>(
                                                      context)
                                                  .primaryColor,
                                          style: BorderStyle.solid,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
                                    child: const Text(
                                      "",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : StreamBuilder<AmityUserFollowInfo>(
                                    stream: state.userFollowInfo!.listen.stream,
                                    initialData: state.userFollowInfo,
                                    builder: (context, snapshot) {
                                      return FadeAnimation(
                                          child: snapshot.data!.status ==
                                                  AmityFollowStatus.ACCEPTED
                                              ? const SizedBox()
                                              : GestureDetector(
                                                  onTap: () {
                                                    // TODO: Implement follow action
                                                  },
                                                  child: Semantics(
                                                    identifier:
                                                        'amityUserProfileFollow',
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                getFollowingStatusTextColor(
                                                                    context,
                                                                    snapshot
                                                                        .data!
                                                                        .status),
                                                            style: BorderStyle
                                                                .solid,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color:
                                                            getFollowingStatusColor(
                                                          context,
                                                          snapshot.data!.status,
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 10, 10, 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            size: 16,
                                                            color: Provider.of<
                                                                        AmityUIConfiguration>(
                                                                    context)
                                                                .appColors
                                                                .userProfileBGColor,
                                                            weight: 4,
                                                          ),
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            getFollowingStatusString(
                                                                snapshot.data!
                                                                    .status),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                    }),
                          ),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  String getFollowingStatusString(AmityFollowStatus amityFollowStatus) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return "Follow";
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return "Pending";
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return "Following";
    } else if (amityFollowStatus == AmityFollowStatus.BLOCKED) {
      return "Blocked";
    } else {
      return "Miss Type";
    }
  }

  Color getFollowingStatusColor(
    BuildContext context,
    AmityFollowStatus amityFollowStatus,
  ) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.grey;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Color getFollowingStatusTextColor(
    BuildContext context,
    AmityFollowStatus amityFollowStatus,
  ) {
    if (amityFollowStatus == AmityFollowStatus.NONE) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.PENDING) {
      return Colors.white;
    } else if (amityFollowStatus == AmityFollowStatus.ACCEPTED) {
      return Provider.of<AmityUIConfiguration>(context).primaryColor;
    } else {
      return Colors.red;
    }
  }

  void showUserProfileActions(BuildContext context) {
    final postOption = BottomSheetMenuOption(
        title: "Post",
        icon: "assets/Icons/amity_ic_create_post_button.svg",
        onTap: () {
          Navigator.of(context).pop();

          final createOptions = AmityPostComposerOptions.createOptions(
              targetId: AmityCoreClient.getUserId(),
              targetType: AmityPostTargetType.USER);

          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityPostComposerPage(
              options: createOptions,
            ),
          ));
        });

    final storyOption = BottomSheetMenuOption(
        title: "Story",
        icon: "assets/Icons/ic_create_stroy_black.svg",
        onTap: () {
          Navigator.pop(context);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return CreateStoryConfigProviderWidget(
                  targetType: AmityStoryTargetType.USER,
                  targetId: AmityCoreClient.getUserId(),
                  pageId: 'create_story_page',
                );
              },
            ),
          );
        });

    final pollOption = BottomSheetMenuOption(
        title: "Poll",
        icon: "assets/Icons/amity_ic_create_poll_button.svg",
        onTap: () {
          Navigator.of(context).pop();

          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityPollPostComposerPage(
              targetId: AmityCoreClient.getUserId(),
              targetType: AmityPostTargetType.USER,
            ),
          ));
        });

    List<BottomSheetMenuOption> userActions = [
      postOption,
      storyOption,
      pollOption
    ];

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void showUserEditActions(
    BuildContext context,
    AmityUser? user,
    AmityFollowStatus? status, {
    VoidCallback? onTappedEditProfile,
  }) {
    final profileBloc = context.read<UserProfileBloc>();
    final AmityToastBloc toastBloc = context.read<AmityToastBloc>();

    final editAction = BottomSheetMenuOption(
        title: "Edit profile",
        icon: 'assets/Icons/amity_ic_edit_comment.svg',
        onTap: () {
          Navigator.of(context).pop();

          if (onTappedEditProfile != null) {
            onTappedEditProfile.call();
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AmityEditUserProfilePage(
                  userId: userId,
                  userEditAction: (status) {
                    if (status) {
                      profileBloc
                          .addEvent(UserProfileEventRefresh(userId: userId));

                      toastBloc.add(const AmityToastShort(
                          message: "Successfully updated your profile!",
                          icon: AmityToastIcon.success));
                    } else {
                      toastBloc.add(const AmityToastShort(
                          message:
                              "Failed to save your profile. Please try again.",
                          icon: AmityToastIcon.warning));
                    }
                  },
                );
              },
            ),
          );
        });

    final reportAction = BottomSheetMenuOption(
        title: "Report User",
        icon: "assets/Icons/amity_ic_report_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          profileBloc.addEvent(UserProfileUserModerationEvent(
              action: UserModerationAction.report,
              userId: userId,
              toastBloc: context.read<AmityToastBloc>(),
              onError: () {}));
        });

    final unreportAction = BottomSheetMenuOption(
        title: "Unreport User",
        icon: "assets/Icons/amity_ic_unreport_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          profileBloc.addEvent(UserProfileUserModerationEvent(
              action: UserModerationAction.unreport,
              userId: userId,
              toastBloc: toastBloc,
              onError: () {}));
        });

    final blockUserAction = BottomSheetMenuOption(
      title: "Block User",
      icon: "assets/Icons/amity_ic_block_user.svg",
      onTap: () {
        Navigator.of(context).pop();

        final confirmationHandler =
            UserModerationConfirmationHandler(context: context, theme: theme);
        confirmationHandler.askConfirmationToBlockUser(
            displayName: user?.displayName ?? "",
            onConfirm: () {
              profileBloc.add(UserProfileUserModerationEvent(
                action: UserModerationAction.block,
                userId: userId,
                toastBloc: toastBloc,
                onError: () {},
              ));
            });
      },
    );

    final currentUserId = AmityCoreClient.getUserId();

    List<BottomSheetMenuOption> userActions = [];
    if (userId == currentUserId) {
      userActions = [editAction];
    } else {
      final isReported = user?.isFlaggedByMe;

      if (isReported == true) {
        userActions.add(unreportAction);
      } else {
        userActions.add(reportAction);
      }

      if (status != AmityFollowStatus.BLOCKED) {
        userActions.add(blockUserAction);
      }
    }

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void triggerUserEditActions(
    BuildContext context, {
    VoidCallback? onTappedEditProfile,
  }) {
    final state = context.read<UserProfileBloc>().state;
    showUserEditActions(
      context,
      state.user,
      state.userFollowInfo?.status,
      onTappedEditProfile: onTappedEditProfile,
    );
  }
}