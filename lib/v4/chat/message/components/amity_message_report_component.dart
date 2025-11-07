import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'amity_message_report_cubit.dart';

final reasonMap = {
  AmityContentFlagReasonType.COMMUNITY_GUIDELINES:
      AmityContentFlagReason.communityGuidelines,
  AmityContentFlagReasonType.HARASSMENT_OR_BULLYING:
      AmityContentFlagReason.harassmentOrBullying,
  AmityContentFlagReasonType.SELF_HARM_OR_SUICIDE:
      AmityContentFlagReason.selfHarmOrSuicide,
  AmityContentFlagReasonType.VIOLENCE_OR_THREATENING_CONTENT:
      AmityContentFlagReason.violenceOrThreateningContent,
  AmityContentFlagReasonType.SELLING_RESTRICTED_ITEMS:
      AmityContentFlagReason.sellingRestrictedItems,
  AmityContentFlagReasonType.SEXUAL_CONTENT_OR_NUDITY:
      AmityContentFlagReason.sexualContentOrNudity,
  AmityContentFlagReasonType.SPAM_OR_SCAMS: AmityContentFlagReason.spamOrScams,
  AmityContentFlagReasonType.FALSE_INFORMATION:
      AmityContentFlagReason.falseInformation,
};

class MessageReportView extends StatelessWidget {
  final AmityMessage message;
  final Function()? onCancel;
  final Function()? onOthersSelected;
  final AmityThemeColor theme;

  const MessageReportView({
    Key? key,
    required this.message,
    required this.theme,
    this.onCancel,
    this.onOthersSelected,
  }) : super(key: key);

  Future<bool> _flagMessage(BuildContext context, AmityContentFlagReason reason,
      {String? customReason}) async {
    try {
      if (message.user?.userId != null) {
        final messageId = message.messageId ?? "";

        // Flag the message with the selected reason
        await AmityChatClient.newMessageRepository()
            .flagMessage(messageId: messageId, reason: reason);

        context.read<AmityToastBloc>().add(AmityToastShort(
            message: context.l10n.toast_message_reported,
            icon: AmityToastIcon.success,
            bottomPadding: AmityChatPage.toastBottomPadding));

        return true;
      } else {
        context.read<AmityToastBloc>().add(AmityToastShort(
            message: context.l10n.toast_message_report_error,
            icon: AmityToastIcon.warning,
            bottomPadding: AmityChatPage.toastBottomPadding));
        return true;
      }
    } catch (e) {
      context.read<AmityToastBloc>().add(AmityToastShort(
          message: context.l10n.toast_message_report_error,
          icon: AmityToastIcon.warning,
          bottomPadding: AmityChatPage.toastBottomPadding));
      return true;
    }
  }

  Widget _buildReportReasonItem(AmityContentFlagReason reason,
      AmityContentFlagReason? selectedReason, AmityMessageReportCubit cubit) {
    final isSelected = selectedReason == reason;
    final isOthersOption = reason.type == AmityContentFlagReasonType.OTHERS;

    return GestureDetector(
      onTap: () {
        if (isOthersOption) {
          cubit.selectReason(reason);
          if (onOthersSelected != null) {
            onOthersSelected!();
          }
        } else {
          cubit.selectReason(reason);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.description,
                style: AmityTextStyle.body(theme.baseColor),
              ),
            ),
            const SizedBox(width: 16),
            if (isOthersOption)
              SvgPicture.asset(
                'assets/Icons/amity_ic_right_arrow_no_body.svg',
                package: 'amity_uikit_beta_service',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.baseColorShade1,
                  BlendMode.srcIn,
                ),
              )
            else
              // Radio button for other options
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? theme.primaryColor : theme.baseColorShade3,
                    width: 2,
                  ),
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AmityMessageReportCubit(),
      child: BlocBuilder<AmityMessageReportCubit, AmityMessageReportState>(
        builder: (context, state) {
          final cubit = context.read<AmityMessageReportCubit>();

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  decoration: ShapeDecoration(
                    color: theme.baseColorShade3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Report reason',
                          style: AmityTextStyle.titleBold(theme.baseColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (onCancel != null) {
                            onCancel!();
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/Icons/amity_ic_close_button.svg',
                          package: 'amity_uikit_beta_service',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            theme.baseColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Container(height: 1, color: theme.baseColorShade4),
                const SizedBox(height: 12),

                // Description
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    'Tell us why you\'re reporting this message. Your report will be reviewed by our moderators and kept confidential.',
                    style: AmityTextStyle.caption(theme.baseColorShade1),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 12),

                // Report reasons list
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Existing report reason items
                        ...reasonMap.values.map((reason) {
                          return _buildReportReasonItem(
                              reason, state.selectedReason, cubit);
                        }).toList(),
                        _buildReportReasonItem(
                            AmityContentFlagReason.others(''),
                            state.selectedReason,
                            cubit),
                      ],
                    ),
                  ),
                ),
                Container(height: 1, color: theme.baseColorShade4),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: state.selectedReason != null
                        ? () async {
                            // Get the custom reason text for "Others" option
                            final reasonText = state.selectedReason!.type ==
                                    AmityContentFlagReasonType.OTHERS
                                ? state.othersText.isNotEmpty
                                    ? state.othersText
                                    : null
                                : null;

                            // Call the flag message API
                            final success = await _flagMessage(
                                context, state.selectedReason!,
                                customReason: reasonText);

                            // Only close the dialog if the operation was successful
                            if (success && onCancel != null) {
                              onCancel!();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.selectedReason != null
                          ? theme.primaryColor
                          : theme.primaryColor
                              .blend(ColorBlendingOption.shade2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor:
                          theme.primaryColor.blend(ColorBlendingOption.shade2),
                    ),
                    child: Text(
                      'Submit',
                      style: AmityTextStyle.bodyBold(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
