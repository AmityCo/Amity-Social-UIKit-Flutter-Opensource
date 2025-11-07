import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_preference_state.dart';
part 'notification_preference_cubit.dart';

class AmityGroupNotificationPreferencePage extends NewBasePage {
  final AmityChannel channel;

  AmityGroupNotificationPreferencePage({
    Key? key,
    required this.channel,
  }) : super(key: key, pageId: 'group_notification_preference_page');

  @override
  Widget buildPage(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                NotificationPreferenceCubit(channel: channel)),
        BlocProvider(create: (context) => AmityToastBloc()),
      ],
      child:
          BlocBuilder<NotificationPreferenceCubit, NotificationPreferenceState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<NotificationPreferenceCubit>(context);
          return Stack(
            children: [
              Scaffold(
                backgroundColor: theme.backgroundColor,
                appBar: AppBar(
                  backgroundColor: theme.backgroundColor,
                  title: Text(
                    context.l10n.notification_preference_title,
                    style: AmityTextStyle.titleBold(theme.baseColor),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    TextButton(
                      onPressed: state.hasChanges
                          ? () async {
                              await cubit.savePreference();

                              // Show toast message
                              context
                                  .read<AmityToastBloc>()
                                  .add(AmityToastShort(
                                    message: state.enabled
                                        ? context.l10n.notification_enabled_toast
                                        : context.l10n.notification_disabled_toast,
                                    icon: AmityToastIcon.success,
                                  ));

                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(
                        context.l10n.general_save,
                        style: AmityTextStyle.body(
                          state.hasChanges
                              ? theme.primaryColor
                              : theme.primaryColor
                                  .blend(ColorBlendingOption.shade2),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (channel.notificationMode == NotificationMode.silent)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.backgroundShade1Color,
                        ),
                        child: Text(
                            context.l10n.notification_disabled_by_moderator,
                            style:
                                AmityTextStyle.caption(theme.baseColorShade3)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildNotificationOption(
                        context: context,
                        title: context.l10n.notification_allow_notifications,
                        description: context.l10n.notification_allow_notifications_desc,
                        value: state.enabled,
                        onChanged: channel.notificationMode ==
                                    NotificationMode.silent
                            ? (_) {}
                            : cubit.setEnabled,
                        isSilent: channel.notificationMode ==
                                NotificationMode.silent,
                      ),
                    ),
                  ],
                ),
              ),
              AmityToast(elementId: 'notification_toast'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required String title,
    required String description,
    required bool value,
    required Function(bool)? onChanged,
    bool isSilent = false,
  }) {
    return Padding(
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
                  style: AmityTextStyle.bodyBold(
                      isSilent ? theme.baseColorShade3 : theme.baseColor),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AmityTextStyle.caption(
                      isSilent ? theme.baseColorShade3 : theme.baseColorShade1),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            trackOutlineColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                return Colors.transparent;
              },
            ),
            activeColor: isSilent
                ? theme.primaryColor.blend(ColorBlendingOption.shade3)
                : theme.primaryColor,
            inactiveTrackColor: isSilent
                ? theme.baseColorShade4
                : theme.baseColorShade3,
            activeTrackColor: isSilent
                ? theme.primaryColor.blend(ColorBlendingOption.shade3)
                : theme.primaryColor,
            thumbColor: MaterialStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }
}
