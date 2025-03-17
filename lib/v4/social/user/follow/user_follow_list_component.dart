import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/Skeleton/user_skeleton_list.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/user_moderation_confirmation_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:flutter_svg/svg.dart';

// Internal Component
class UserFollowListComponent extends NewBaseComponent {
  final String userId;
  final AmityUserRelationshipPageTab selectedTab;

  UserFollowListComponent(
      {required this.userId, required this.selectedTab, super.key})
      : super(componentId: 'user_relationship_list');

  final scrollController = ScrollController();

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => UserRelationshipBloc(userId, selectedTab),
      child: BlocBuilder<UserRelationshipBloc, UserRelationshipState>(
          builder: (context, state) {
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            context
                .read<UserRelationshipBloc>()
                .addEvent(UserRelationshipLoadNextPage());
          }
        });

        if (state.isLoading && state.followUsers.isEmpty) {
          return UserSkeletonLoadingView(
            itemCount: 8,
          );
        } else if (!state.isLoading && state.followUsers.isEmpty) {
          return Container(
            alignment: Alignment.center,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/Icons/amity_ic_user_profile_empty_state.svg",
                    package: "amity_uikit_beta_service",
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Nothing here to see yet",
                    style: AmityTextStyle.titleBold(theme.baseColorShade3),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              controller: scrollController,
              itemCount: state.followUsers.length,
              itemBuilder: (context, index) {
                final relationship = state.followUsers[index];
                final user =
                    selectedTab == AmityUserRelationshipPageTab.following
                        ? state.followUsers[index].targetUser
                        : state.followUsers[index].sourceUser;

                return ListTile(
                  leading: AmityUserAvatar(
                      avatarUrl: user?.avatarUrl,
                      displayName: user?.displayName ?? "",
                      isDeletedUser: user?.isDeleted ?? false),
                  title: Text(
                    user?.displayName ?? "",
                    style: AmityTextStyle.bodyBold(theme.baseColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      showAvailableActions(context, user,
                          relationship.status ?? AmityFollowStatus.NONE);
                    },
                  ),
                  horizontalTitleGap: 12,
                  onTap: () {
                    // Go to that user profile
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AmityUserProfilePage(
                              userId: user?.userId ?? "");
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      }),
    );
  }

  // Pass user object here
  void showAvailableActions(
      BuildContext context, AmityUser? user, AmityFollowStatus followStatus) {
    final AmityToastBloc toastBloc = context.read<AmityToastBloc>();
    final UserRelationshipBloc relationshipBloc =
        context.read<UserRelationshipBloc>();

    final userId = user?.userId ?? "";

    final reportAction = BottomSheetMenuOption(
        title: "Report user",
        icon: "assets/Icons/amity_ic_report_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          relationshipBloc.addEvent(UserModerationEvent(
              action: UserModerationAction.report,
              userId: userId,
              toastBloc: context.read<AmityToastBloc>()));
        });

    final unreportAction = BottomSheetMenuOption(
        title: "Unreport user",
        icon: "assets/Icons/amity_ic_unreport_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          relationshipBloc.addEvent(UserModerationEvent(
              action: UserModerationAction.unreport,
              userId: userId,
              toastBloc: toastBloc));
        });

    final blockUser = BottomSheetMenuOption(
        title: "Block user",
        icon: "assets/Icons/amity_ic_block_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          final confirmationHandler =
              UserModerationConfirmationHandler(context: context, theme: theme);
          confirmationHandler.askConfirmationToBlockUser(
              displayName: user?.displayName ?? "",
              onConfirm: () {
                relationshipBloc.addEvent(UserModerationEvent(
                    action: UserModerationAction.block,
                    userId: userId,
                    toastBloc: toastBloc));
              });
        });

    final unblockUser = BottomSheetMenuOption(
        title: "Unblock user",
        icon: "assets/Icons/amity_ic_block_user.svg",
        onTap: () {
          Navigator.of(context).pop();

          final confirmationHandler =
              UserModerationConfirmationHandler(context: context, theme: theme);
          confirmationHandler.askConfirmationToUnblockUser(
              displayName: user?.displayName ?? "",
              onConfirm: () {
                relationshipBloc.addEvent(UserModerationEvent(
                    action: UserModerationAction.unblock,
                    userId: userId,
                    toastBloc: toastBloc));
              });
        });

    final isReported = user?.isFlaggedByMe ?? false;

    List<BottomSheetMenuOption> options = [];
    if (isReported) {
      options.add(unreportAction);
    } else {
      options.add(reportAction);
    }

    if (followStatus == AmityFollowStatus.BLOCKED) {
      options.add(unblockUser);
    } else {
      options.add(blockUser);
    }

    BottomSheetMenu(options: options).show(context, theme);
  }
}
