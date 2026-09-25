import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/bloc/amity_message_report_reason_cubit.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageReportReasonView extends StatelessWidget {
  final AmityMessage message;
  final Function()? onCancel;
  final Function()? onBack;
  final AmityThemeColor theme;

  const MessageReportReasonView({
    Key? key,
    required this.message,
    required this.theme,
    this.onCancel,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Read the strings here, not inside `create`. `context.l10n` is
    // AppLocalizations.of(context), which registers an InheritedWidget
    // dependency — legal in build, fatal in a provider's create callback,
    // where Flutter throws "Tried to listen to an InheritedWidget in a
    // life-cycle that will never be called again" and the sheet red-screens
    // instead of opening. That is what it did on open, which is also why the
    // colours this ticket is about could not be seen.
    final successMessage = context.l10n.toast_message_reported;
    final errorMessage = context.l10n.toast_message_report_error;

    return BlocProvider(
      create: (providerContext) => AmityMessageReportReasonCubit(
        message: message,
        onCancel: onCancel,
        onBack: onBack,
        toastBloc: providerContext.read<AmityToastBloc>(),
        successMessage: successMessage,
        errorMessage: errorMessage,
      ),
      child: _MessageReportOthersView(theme: theme),
    );
  }
}

class _MessageReportOthersView extends StatelessWidget {
  final AmityThemeColor theme;

  const _MessageReportOthersView({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AmityMessageReportReasonCubit, AmityMessageReportReasonState>(
      builder: (context, state) {
        final cubit = context.read<AmityMessageReportReasonCubit>();

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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: context.amityToken(AmityColorToken.textSheetsHeaderTextDescriptionDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header with back button
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (cubit.onBack != null) {
                          cubit.onBack!();
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_back_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Others',
                        style: AmityTextStyle.titleBold(context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (cubit.onCancel != null) {
                          cubit.onCancel!();
                        }
                      },
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_close_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Container(height: 1, color: context.amityToken(AmityColorToken.lineDividerContentDefault)),

              const SizedBox(height: 24),

              // Description label
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      'Describe your reason',
                      style: AmityTextStyle.titleBold(context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      // Design binds the Input *Indicator* token here
                      // (#A5A9B5); Sheets/Header/TextDescription resolves to
                      // white_color in dark, so this read as pure white
                      // (PDT-5100 case 3).
                      '(Optional)',
                      style: AmityTextStyle.caption(context.amityToken(
                          AmityColorToken.textInputTextInputIndicatorDefault)),
                    ),
                    const Spacer(),
                    Text(
                      '${state.characterCount}/300',
                      style: AmityTextStyle.caption(context.amityToken(AmityColorToken.textInputTextInputTextCountDefault)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Text input field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: cubit.textController,
                  focusNode: cubit.focusNode,
                  keyboardAppearance: context.amityBrightness,
                  decoration: InputDecoration(
                    hintText: context.l10n.message_report_details_hint,
                    // Same mis-binding as the (Optional) label above: the
                    // placeholder is an Input token, not a Sheets one.
                    hintStyle: AmityTextStyle.body(context.amityToken(
                        AmityColorToken.textInputTextInputPlaceholderEnabled)),
                    contentPadding: EdgeInsets.only(bottom: 8),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.amityToken(AmityColorToken.lineDividerContentDefault)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.amityToken(AmityColorToken.lineDividerContentDefault)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.amityToken(AmityColorToken.lineDividerContentDefault)),
                    ),
                    counterText: '', // Hide the default counter
                  ),
                  maxLength: 300, // Still enforce the limit
                  style: AmityTextStyle.body(context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault)),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  buildCounter: (context,
                      {required currentLength, required isFocused, maxLength}) {
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: state.isSubmitEnabled && !state.isSubmitting
                      ? () async {
                          await cubit.flagMessage();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isSubmitEnabled
                        ? context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled)
                        : context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor:
                        context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled),
                  ),
                  child: state.isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit',
                          style: AmityTextStyle.bodyBold(Colors.white),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
