import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'amity_edit_group_notification_cubit.dart';
part 'amity_edit_group_notification_state.dart';

class AmityEditGroupNotificationPage extends NewBasePage {
  final AmityChannel channel;

  AmityEditGroupNotificationPage({Key? key, required this.channel})
      : super(key: key, pageId: 'edit_group_notification_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => AmityGroupNotificationCubit(channel),
      child: BlocBuilder<AmityGroupNotificationCubit, AmityGroupNotificationState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<AmityGroupNotificationCubit>(context);

          return Scaffold(
            backgroundColor: token(AmityColorToken.surfaceSheetsBackgroundGeneral),
            appBar: AppBar(
              backgroundColor: token(AmityColorToken.surfaceSheetsBackgroundGeneral),
              title: Text(
                context.l10n.settings_group_notifications,
                style: AmityTextStyle.titleBold(token(AmityColorToken.textListHeaderDefaultDefault)),
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
                    context.l10n.general_save,
                    style: AmityTextStyle.body(
                      state.hasChanges
                          ? token(AmityColorToken.textMainButtonDefaultGhostPrimaryEnabled)
                          : token(AmityColorToken.textMainButtonDefaultGhostPrimaryDisabled),
                    ),
                  ),
                ),
              ],
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: token(AmityColorToken.textListHeaderDefaultDefault)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Rows are full-bleed and flush; the 16 inset lives inside each row.
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationOption(
                  context: context,
                  title: context.l10n.notification_default_mode,
                  description: context.l10n.notification_default_mode_desc,
                  value: NotificationMode.defaultMode,
                  groupMode: state.selectedMode,
                  onChanged: cubit.setNotificationMode,
                ),
                _buildNotificationOption(
                  context: context,
                  title: context.l10n.notification_silent_mode,
                  description: context.l10n.notification_silent_mode_desc,
                  value: NotificationMode.silent,
                  groupMode: state.selectedMode,
                  onChanged: cubit.setNotificationMode,
                ),
                _buildNotificationOption(
                  context: context,
                  title: context.l10n.notification_subscribe_mode,
                  description: context.l10n.notification_subscribe_mode_desc,
                  value: NotificationMode.subscribe,
                  groupMode: state.selectedMode,
                  onChanged: cubit.setNotificationMode,
                ),
              ],
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AmityTextStyle.bodyBold(token(AmityColorToken.textListHeaderDefaultDefault)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AmityTextStyle.caption(token(AmityColorToken.textListTextDescriptionDefaultDefault)),
                  ),
                ],
              ),
            ),
            _buildRadio(selected: value == groupMode),
          ],
        ),
      ),
    );
  }

  /// Selection/Radio: a 24x24 hit frame around a 20x20 circle. Active is a
  /// filled disc with an 8x8 dot; Inactive is an empty circle with a 2px ring.
  /// The whole row is the tap target, so this control is presentational.
  Widget _buildRadio({required bool selected}) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? token(AmityColorToken.surfaceSelectionRadioAtomicActiveDefault)
              : token(AmityColorToken.surfaceSelectionRadioAtomicInactiveDefault),
          border: selected
              ? null
              : Border.all(
                  color: token(AmityColorToken.borderSelectionRadioAtomicInactiveDefault),
                  width: 2,
                ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: token(AmityColorToken.iconSelectionRadioAtomicDefault),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
