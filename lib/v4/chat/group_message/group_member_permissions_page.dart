import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:bloc/bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_member_permissions_cubit.dart';
part 'group_member_permissions_state.dart';

class GroupMemberPermissionsPage extends NewBasePage {
  final AmityChannel channel;

  GroupMemberPermissionsPage({Key? key, required this.channel})
      : super(key: key, pageId: 'group_member_permissions_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupMemberPermissionsCubit(channel),
      child:
          BlocBuilder<GroupMemberPermissionsCubit, GroupMemberPermissionsState>(
        builder: (context, state) {
          // Store the initial permission to check if changes were made
          final initialPermission = channel.isMuted ?? false
              ? MessagingPermission.moderatorsOnly
              : MessagingPermission.everyone;

          // Check if any changes were made
          final hasChanges = initialPermission != state.messagingPermission;

          return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                title: const Text('Member permissions'),
                actions: [
                  TextButton(
                    onPressed: hasChanges
                        ? () async {
                            // If moderators only, mute the channel with period of -1 (indefinitely)
                            // Otherwise, unmute the channel
                            try {
                              AmityChannel updatedChannel;
                              if (state.messagingPermission ==
                                  MessagingPermission.moderatorsOnly) {
                                await AmityChatClient.newChannelRepository()
                                    .muteChannel(channel.channelId ?? "",
                                        millis: -1);
                              } else {
                                await AmityChatClient.newChannelRepository()
                                    .unMuteChannel(channel.channelId ?? "");
                              }
                              updatedChannel =
                                  await AmityChatClient.newChannelRepository()
                                      .getChannel(channel.channelId ?? "");
                              Navigator.pop(context, {
                                'status': 'success',
                                'channel': updatedChannel,
                              });
                            } catch (error) {
                              Navigator.pop(context, {
                                'status': 'error',
                              });
                            }
                          }
                        : null, // Disable the button when no changes
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: hasChanges
                            ? theme.primaryColor
                            : theme.primaryColor
                                .blend(ColorBlendingOption.shade2),
                      ),
                    ),
                  ),
                ],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: _buildContent(context, state));
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, GroupMemberPermissionsState state) {
    return Container(
      color: theme.backgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Messaging',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPermissionOption(
            context: context,
            title: 'Everyone',
            description: 'Everyone can send a message in the group.',
            value: MessagingPermission.everyone,
            currentPermission: state.messagingPermission,
            onChanged: (permission) => context
                .read<GroupMemberPermissionsCubit>()
                .setMessagingPermission(permission),
          ),
          const SizedBox(height: 8),
          _buildPermissionOption(
            context: context,
            title: 'Only moderators',
            description:
                'Members who are not moderators can read messages but cannot send any messages.',
            value: MessagingPermission.moderatorsOnly,
            currentPermission: state.messagingPermission,
            onChanged: (permission) => context
                .read<GroupMemberPermissionsCubit>()
                .setMessagingPermission(permission),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionOption({
    required BuildContext context,
    required String title,
    required String description,
    required MessagingPermission value,
    required MessagingPermission currentPermission,
    required Function(MessagingPermission) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Radio<MessagingPermission>(
              value: value,
              groupValue: currentPermission,
              onChanged: (val) => onChanged(val!),
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

enum MessagingPermission {
  everyone,
  moderatorsOnly,
}
