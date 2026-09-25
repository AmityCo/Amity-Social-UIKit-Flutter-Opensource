import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_banner.dart';
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
      ],
      child:
          BlocBuilder<NotificationPreferenceCubit, NotificationPreferenceState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<NotificationPreferenceCubit>(context);
          return Stack(
            children: [
              Scaffold(
                backgroundColor: token(AmityColorToken.surfaceListDefaultDefault),
                appBar: AppBar(
                  backgroundColor: token(AmityColorToken.surfaceListDefaultDefault),
                  title: Text(
                    context.l10n.notification_preference_title,
                    style: AmityTextStyle.titleBold(
                        token(AmityColorToken.textSheetsHeaderTitleDefault)),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: token(AmityColorToken
                            .iconIconButtonGhostSecondaryDefault)),
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
                              ? token(AmityColorToken.textMainButtonDefaultGhostPrimaryEnabled)
                              : token(AmityColorToken.textMainButtonDefaultGhostPrimaryDisabled),
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (channel.notificationMode == NotificationMode.silent)
                      AmityBanner(
                        hierarchy: AmityBannerHierarchy.subdue,
                        centered: true,
                        description:
                            context.l10n.notification_disabled_by_moderator,
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
                      token(isSilent
                          ? AmityColorToken.textListHeaderDefaultDisabled
                          : AmityColorToken.textListHeaderDefaultDefault)),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AmityTextStyle.caption(
                      token(AmityColorToken.textListTextDescriptionDefaultDefault)),
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
            // isSilent disables the toggle, so it takes the Toggle family's
            // Disabled states — not a hover, which cannot happen on touch.
            activeColor: token(isSilent
                ? AmityColorToken.surfaceToggleBackgroundActiveDisabled
                : AmityColorToken.surfaceToggleBackgroundActiveEnabled),
            inactiveTrackColor: token(isSilent
                ? AmityColorToken.surfaceToggleBackgroundInactiveDisabled
                : AmityColorToken.surfaceToggleBackgroundInactiveEnabled),
            activeTrackColor: token(isSilent
                ? AmityColorToken.surfaceToggleBackgroundActiveDisabled
                : AmityColorToken.surfaceToggleBackgroundActiveEnabled),
            // The thumb has its own on/off axis, so it must be picked from both
            // the value and the disabled state, not from the state alone.
            thumbColor: MaterialStateProperty.all(token(value
                ? (isSilent
                    ? AmityColorToken.surfaceToggleThumbActiveDisabled
                    : AmityColorToken.surfaceToggleThumbActiveEnabled)
                : (isSilent
                    ? AmityColorToken.surfaceToggleThumbInactiveDisabled
                    : AmityColorToken.surfaceToggleThumbInactiveEnabled))),
          ),
        ],
      ),
    );
  }
}
