import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post_poll_composer_page/post_poll_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/image_feed/user_image_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/component/user_profile_header_component.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/edit_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/user_moderation_confirmation_handler.dart';
import 'package:amity_uikit_beta_service/v4/social/user/video_feed/user_video_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';

import 'bloc/user_profile_bloc.dart';
import 'component/user_profile_tab.dart';

class AmityUserProfilePage extends NewBasePage {
  final String userId;

  AmityUserProfilePage({super.key, required this.userId})
      : super(pageId: 'user_profile_page');

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
                  _scrollController.offset > 100) {
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
              appBar: AppBar(
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
                  //iconSize: 24,
                  icon: ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
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
                      showUserEditActions(context, state.user,
                          state.userFollowInfo?.status, theme);
                    },
                  )
                ],
              ),
              backgroundColor: theme.backgroundColor,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: AmityUserProfileHeaderComponent(
                      user: state.user,
                      myFollowInfo: state.myFollowInfo,
                      userFollowInfo: state.userFollowInfo,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: UserProfileTab(
                      selectedIndex: state.selectedIndex,
                      onTabSelected: (index) {
                        context
                            .read<UserProfileBloc>()
                            .add(UserProfileEventTabSelected(tab: index));
                      },
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
                  // AmityToast(elementId: "toast"),
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
                        backgroundColor: theme.highlightColor,
                        elevation: 1,
                        focusElevation: 0,
                        highlightElevation: 0,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_plus_button.svg',
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

  void showUserProfileActions(BuildContext context) {
    final postOption = BottomSheetMenuOption(
        title: "Post",
        icon: "assets/Icons/amity_ic_create_post_button.svg",
        onTap: () {
          // Dismiss popup
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
          // Dismiss bottom sheet
          Navigator.pop(context);

          // Show story creation screen
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
          // Dismiss popup
          Navigator.of(context).pop();

          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityPollPostComposerPage(
              targetId: AmityCoreClient.getUserId(),
              targetType: AmityPostTargetType.USER,
            ),
          ));
        });

    // Setup all actions
    List<BottomSheetMenuOption> userActions = [
      postOption,
      storyOption,
      pollOption
    ];

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void showUserEditActions(BuildContext context, AmityUser? user,
      AmityFollowStatus? status, AmityThemeColor theme) {
    final profileBloc = context.read<UserProfileBloc>();
    final AmityToastBloc toastBloc = context.read<AmityToastBloc>();

    final editAction = BottomSheetMenuOption(
        title: "Edit profile",
        icon: 'assets/Icons/amity_ic_edit_comment.svg',
        onTap: () {
          // Dismiss popup
          Navigator.of(context).pop();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AmityEditUserProfilePage(
                  userId: userId,
                  userEditAction: (status) {
                    if (status) {
                      // Refresh
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

    // Setup all actions
    List<BottomSheetMenuOption> userActions = [];
    if (userId == currentUserId) {
      userActions = [editAction];
    } else {
      final isReported = user?.isFlaggedByMe;

      // Report / Unreport
      if (isReported == true) {
        userActions.add(unreportAction);
      } else {
        userActions.add(reportAction);
      }

      if (status != AmityFollowStatus.BLOCKED) {
        // Block
        userActions.add(blockUserAction);
      }
    }

    BottomSheetMenu(options: userActions).show(context, theme);
  }
}
