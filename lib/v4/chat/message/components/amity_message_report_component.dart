import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/atoms/amity_banner.dart';
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

  Widget _buildReportReasonItem(BuildContext context, AmityContentFlagReason reason,
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
      // List atom row as Android's AmityMessageReportPage draws it: 52 tall,
      // 16 side inset, SemiBold 15 label on Text/List/Header/Default/Default.
      // The Selection stays in the trailing slot per the
      // AmityChatContentReportPage spec (Android puts it leading — its own
      // deviation from the Figma, not copied here).
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason.description,
                style: AmityTextStyle.bodyBold(context
                    .amityToken(AmityColorToken.textListHeaderDefaultDefault)),
              ),
            ),
            const SizedBox(width: 12),
            if (isOthersOption)
              SvgPicture.asset(
                'assets/Icons/amity_ic_right_arrow_no_body.svg',
                package: 'amity_uikit_beta_service',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  context.amityToken(AmityColorToken.iconListLeadingDefaultDefault),
                  BlendMode.srcIn,
                ),
              )
            else
              // Selection atom, radio: 20 circle, 2 ring, 8 dot.
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: context.amityToken(AmityColorToken
                              .borderSelectionRadioAtomicInactiveDefault),
                          width: 2,
                        ),
                  color: context.amityToken(isSelected
                      ? AmityColorToken.surfaceSelectionRadioAtomicActiveDefault
                      : AmityColorToken.surfaceSelectionRadioAtomicInactiveDefault),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.amityToken(
                                AmityColorToken.iconSelectionRadioAtomicDefault),
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

          // The reason list is Expanded so the Submit footer pins to the
          // bottom edge, which needs a bounded height from the presenter (see
          // message_popup.dart). Fail loudly rather than with a RenderFlex
          // trace if a new caller forgets.
          return LayoutBuilder(builder: (context, constraints) {
            assert(constraints.hasBoundedHeight,
                'AmityMessageReportComponent must be given a bounded height '
                '(e.g. SizedBox.expand in a full-height modal sheet).');
            return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: context.amityToken(AmityColorToken.surfaceSheetsBackgroundGeneral),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
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
                    color: context.amityToken(AmityColorToken.textSheetsHeaderTextDescriptionDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sheet header: title only. The spec sets L Action = R Action =
                // None (the sheet dismisses by handle / back), which is also
                // the Figma; Android's back chevron exists because it is a page.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.chat_report_title,
                    style: AmityTextStyle.titleBold(context
                        .amityToken(AmityColorToken.textSheetsHeaderTitleDefault)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 13),
                Container(
                    height: 1,
                    color: context.amityToken(AmityColorToken.lineDividerPostDefault)),

                // Description as the Banner atom (Default hierarchy), as on Android.
                AmityBanner(
                  hierarchy: AmityBannerHierarchy.defaultHierarchy,
                  description: context.l10n.chat_report_description,
                ),

                // Report reasons list. Expanded (not Flexible) so the list
                // absorbs the sheet's spare height and the divider + Submit
                // below it stay pinned to the bottom edge, as on Android.
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Existing report reason items
                        ...reasonMap.values.map((reason) {
                          return _buildReportReasonItem(context, reason,
                              state.selectedReason, cubit);
                        }).toList(),
                        _buildReportReasonItem(
                            context,
                            AmityContentFlagReason.others(''),
                            state.selectedReason,
                            cubit),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: 1,
                    color: context.amityToken(AmityColorToken.lineDividerPostDefault)),

                Container(
                  width: double.infinity,
                  height: 40 + 32, // MainButton Lg (40) inside the 16 footer inset
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
                          ? context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled)
                          : context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor:
                          context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled),
                    ),
                    child: Text(
                      context.l10n.chat_report_submit,
                      style: AmityTextStyle.bodyBold(context.amityToken(
                          state.selectedReason != null
                              ? AmityColorToken
                                  .textMainButtonDefaultFilledPrimaryEnabled
                              : AmityColorToken
                                  .textMainButtonDefaultFilledPrimaryDisabled)),
                    ),
                  ),
                ),
              ],
            ),
          );
          });
        },
      ),
    );
  }
}
