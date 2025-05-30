import 'package:amity_uikit_beta_service/v4/chat/group_message/group_banned_users_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/group_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/group_notification_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/group_member_permissions_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/group_member_list_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/widgets/group_settings_tile.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/channel_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/notification/notification_preference_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

part 'group_setting_cubit.dart';
part 'group_setting_state.dart';

class GroupSettingPage extends NewBasePage {
  final AmityChannel channel;
  final bool isModerator;

  GroupSettingPage({Key? key, required this.channel, required this.isModerator})
      : super(key: key, pageId: 'group_setting_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupSettingCubit(
        channel: channel,
        isModerator: isModerator,
      ),
      child: BlocBuilder<GroupSettingCubit, GroupSettingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              title: Text(
                state.channel.displayName ?? 'Group Settings',
                style: AmityTextStyle.titleBold(theme.baseColor),
              ),
              leading: IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/amity_ic_back_button.svg',
                  package: 'amity_uikit_beta_service',
                  colorFilter:
                      ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                ),
                onPressed: () {
                  // Return the updated channel when navigating back
                  Navigator.of(context).pop(state.channel);
                },
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Center(
                        child: AmityChannelAvatar.withChannel(
                          channel: state.channel,
                          avatarSize: const Size(120, 120),
                          placeholderSize: const Size(53, 48),
                          borderRadius: 24,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Group settings',
                        style: AmityTextStyle.titleBold(theme.baseColor),
                      ),
                      const SizedBox(height: 4),
                      // Only show group profile editing for moderators
                      if (state.isModerator)
                        GroupSettingsTile(
                          title: 'Group profile',
                          iconAsset:
                              'assets/Icons/amity_ic_edit_group_profile_button.svg',
                          theme: theme,
                          onTap: () async {
                            final result =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupProfilePage(channel: state.channel),
                              ),
                            );

                            // Handle the three cases based on result dictionary
                            handleNavigationResult(
                              context,
                              result,
                              successMessage: "Group profile updated.",
                              errorMessage:
                                  "Failed to update group profile. Please try again.",
                              shouldPopOnSuccess: true,
                              shouldPopOnError: true,
                            );
                          },
                        ),
                      if (state.isModerator)
                        GroupSettingsTile(
                          title: 'Group notifications',
                          iconAsset:
                              'assets/Icons/amity_ic_edit_group_notification_button.svg',
                          theme: theme,
                          trailingText: state.channel.notificationMode
                                  .toString()[0]
                                  .toUpperCase() +
                              state.channel.notificationMode
                                  .toString()
                                  .substring(1),
                          onTap: () async {
                            final result =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupNotificationPage(
                                    channel: state.channel),
                              ),
                            );

                            handleNavigationResult(
                              context,
                              result,
                              successMessage: 'Group notification updated.',
                              errorMessage:
                                  'Failed to update group notification. Please try again.',
                            );
                          },
                        ),
                      // Only show member permissions for moderators
                      if (state.isModerator)
                        GroupSettingsTile(
                          title: 'Member permissions',
                          iconAsset:
                              'assets/Icons/amity_ic_edit_group_member_permission_button.svg',
                          theme: theme,
                          onTap: () async {
                            final result =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupMemberPermissionsPage(
                                        channel: state.channel),
                              ),
                            );

                            handleNavigationResult(
                              context,
                              result,
                              successMessage: 'Member permissions updated.',
                              errorMessage:
                                  'Failed to update member permissions. Please try again.',
                            );
                          },
                        ),

                      GroupSettingsTile(
                        title: 'All members',
                        iconAsset:
                            'assets/Icons/amity_ic_group_member_list_button.svg',
                        theme: theme,
                        onTap: () async {
                          // Navigate to member list page and wait for result
                          final result =
                              await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupMemberListPage(channel: state.channel),
                            ),
                          );

                          // Handle navigation result if page returns data
                          if (result != null) {
                            handleNavigationResult(
                              context,
                              result,
                              successMessage: 'Member list updated.',
                              errorMessage:
                                  'Failed to update member list. Please try again.',
                            );
                          } else {
                            // Fetch updated channel data when returning from member list (fallback)
                            context
                                .read<GroupSettingCubit>()
                                .fetchUpdatedChannel();
                          }
                        },
                      ),
                      // Only show banned users for moderators
                      if (state.isModerator)
                        GroupSettingsTile(
                          title: 'Banned users',
                          iconAsset:
                              'assets/Icons/amity_ic_ban_group_member_button.svg',
                          theme: theme,
                          onTap: () async {
                            final result =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupBannedUsersPage(
                                    channel: state.channel),
                              ),
                            );

                            // Handle navigation result if page returns data
                            if (result != null) {
                              handleNavigationResult(
                                context,
                                result,
                                successMessage: 'Banned users updated.',
                                errorMessage:
                                    'Failed to update banned users. Please try again.',
                              );
                            }
                          },
                        ),

                      // Personal notification preferences for all users
                      Container(height: 1, color: theme.baseColorShade4),
                      const SizedBox(height: 24),
                      Text(
                        'Your preferences',
                        style: AmityTextStyle.titleBold(theme.baseColor),
                      ),
                      GroupSettingsTile(
                        title: 'notifications',
                        iconAsset:
                            'assets/Icons/amity_ic_edit_group_notification_button.svg',
                        theme: theme,
                        trailingText:
                            state.isNotificationsEnabled ? 'On' : 'Off',
                        onTap: () async {
                          // Wait for navigation to complete and then refresh notification settings

                          await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationPreferencePage(
                                channel: state.channel,
                              ),
                            ),
                          );
                          context
                              .read<GroupSettingCubit>()
                              .refreshNotificationSettings();
                        },
                      ),

                      // Add Leave Group button for non-moderators
                      const SizedBox(height: 16),
                      GestureDetector(
                        child: Text(
                          "Leave group",
                          style: AmityTextStyle.bodyBold(theme.alertColor),
                        ),
                        onTap: () async {
                          // Check if user is a moderator and get moderator count
                          if (state.isModerator) {
                            final moderatorCount =
                                state.channel.moderatorCount ?? 0;

                            if (moderatorCount <= 1) {
                              // User is the only moderator - show special dialog
                              bool? shouldOpenMemberList;
                              await PermissionAlertV4Dialog().show(
                                context: context,
                                title: "You're the last moderator",
                                detailText:
                                    'You must promote another member to moderator before leaving.',
                                bottomButtonText: 'Cancel',
                                topButtonText: 'Promote member',
                                onTopButtonAction: () {
                                  shouldOpenMemberList = true;
                                },
                              );

                              // If user chose to view members, navigate to member list
                              if (shouldOpenMemberList == true) {
                                final result =
                                    await Navigator.push<Map<String, dynamic>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupMemberListPage(
                                      channel: state.channel,
                                    ),
                                  ),
                                );

                                // Handle navigation result if page returns data
                                if (result != null) {
                                  handleNavigationResult(
                                    context,
                                    result,
                                    successMessage: 'Member list updated.',
                                    errorMessage:
                                        'Failed to update member list. Please try again.',
                                  );
                                }
                              }
                              return; // Don't proceed with leaving
                            }
                          }

                          // Normal leave group flow for non-moderators or when multiple moderators exist
                          bool? shouldLeave;
                          await ConfirmationV4Dialog().show(
                            context: context,
                            title: 'Leave Group',
                            detailText:
                                'If you leave this group, you will no longer see new activities or participate in this group.',
                            leftButtonText: 'Cancel',
                            rightButtonText: 'Leave',
                            onConfirm: () {
                              shouldLeave = true;
                            },
                          );

                          // If user confirmed, leave the group
                          if (shouldLeave == true) {
                            try {
                              await AmityChatClient.newChannelRepository()
                                  .leaveChannel(state.channel.channelId!)
                                  .then((value) => true);
                              // Show success toast message after leaving
                              context.read<AmityToastBloc>().add(
                                    AmityToastShort(
                                      message: 'Group chat left.',
                                      icon: AmityToastIcon.success,
                                      bottomPadding: 56,
                                    ),
                                  );

                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            } catch (e) {
                              context.read<AmityToastBloc>().add(
                                    AmityToastShort(
                                      message:
                                          'Failed to leave group chat. Please try again.',
                                      icon: AmityToastIcon.warning,
                                      bottomPadding: 56,
                                    ),
                                  );
                            }
                          }
                        },
                      )
                    ],
                  ),
          );
        },
      ),
    );
  }

  void handleNavigationResult(
    BuildContext context,
    Map<String, dynamic>? result, {
    required String successMessage,
    required String errorMessage,
    bool shouldPopOnSuccess = false,
    bool shouldPopOnError = false,
    bool shouldUpdateState = true,
  }) {
    if (result != null) {
      final status = result['status'] as String?;
      final updatedChannel = result['channel'] as AmityChannel?;

      switch (status) {
        case 'success':
          if (updatedChannel != null) {
            if (shouldUpdateState) {
              context
                  .read<GroupSettingCubit>()
                  .updateChannelData(updatedChannel);
            }

            if (shouldPopOnSuccess) {
              Navigator.of(context).pop(updatedChannel);
            }
            Future.delayed(const Duration(milliseconds: 300));

            context.read<AmityToastBloc>().add(
                  AmityToastShort(
                    message: successMessage,
                    icon: AmityToastIcon.success,
                    bottomPadding: 56,
                  ),
                );
          }
          break;
        case 'error':
          if (shouldPopOnError) {
            Navigator.of(context).pop();
          }
          Future.delayed(const Duration(milliseconds: 300));

          // Show error toast
          context.read<AmityToastBloc>().add(
                AmityToastShort(
                  message: errorMessage,
                  icon: AmityToastIcon.warning,
                  bottomPadding: 56,
                ),
              );
          break;
        default:
          break;
      }
    }
  }
}
