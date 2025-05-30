import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_notification_cubit.dart';
part 'group_notification_state.dart';

class GroupNotificationPage extends NewBasePage {
  final AmityChannel channel;

  GroupNotificationPage({Key? key, required this.channel})
      : super(key: key, pageId: 'group_notification_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupNotificationCubit(channel),
      child: BlocBuilder<GroupNotificationCubit, GroupNotificationState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<GroupNotificationCubit>(context);

          return Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              backgroundColor: theme.backgroundColor,
              title: Text(
                'Group notifications',
                style: AmityTextStyle.titleBold(theme.baseColor),
              ),
              actions: [
                TextButton(
                  onPressed: state.hasChanges
                      ? () {
                          AmityChatClient.newChannelRepository()
                              .updateChannel(channel.channelId ?? "")
                              .notificationMode(state.selectedMode)
                              .create()
                              .then((updatedChannel) {
                            Navigator.pop(context, {
                              'status': 'success',
                              'channel': updatedChannel,
                            });
                          }).catchError((error) {
                            Navigator.pop(context, {
                              'status': 'error',
                            });
                          });
                        }
                      : null, // Make button untappable when no changes
                  child: Text(
                    'Save',
                    style: AmityTextStyle.body(
                      state.hasChanges
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
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationOption(
                    context: context,
                    title: 'Default mode',
                    description:
                        'By default, members in this community will receive notifications, but they can choose to turn them off.',
                    value: NotificationMode.defaultMode,
                    groupMode: state.selectedMode,
                    onChanged: cubit.setNotificationMode,
                  ),
                  const SizedBox(height: 20),
                  _buildNotificationOption(
                    context: context,
                    title: 'Silent mode',
                    description:
                        'No notifications for everyone in this channel. Members can\'t turn on notifications in the channel.',
                    value: NotificationMode.silent,
                    groupMode: state.selectedMode,
                    onChanged: cubit.setNotificationMode,
                  ),
                  const SizedBox(height: 20),
                  _buildNotificationOption(
                    context: context,
                    title: 'Subscribe mode',
                    description:
                        'All members have the option to receive notifications, but they need to enable them. By default, notifications are turned off for each member.',
                    value: NotificationMode.subscribe,
                    groupMode: state.selectedMode,
                    onChanged: cubit.setNotificationMode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required String title,
    required String description,
    required NotificationMode value,
    required NotificationMode groupMode,
    required Function(NotificationMode) onChanged,
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
                    style: AmityTextStyle.bodyBold(theme.baseColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AmityTextStyle.caption(theme.baseColorShade1),
                  ),
                ],
              ),
            ),
            Radio<NotificationMode>(
              value: value,
              groupValue: groupMode,
              onChanged: (val) => onChanged(val!),
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
