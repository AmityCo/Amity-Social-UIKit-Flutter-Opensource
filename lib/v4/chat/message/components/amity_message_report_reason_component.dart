import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
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
    return BlocProvider(
      create: (context) => AmityMessageReportReasonCubit(
        message: message,
        onCancel: onCancel,
        onBack: onBack,
        toastBloc: context.read<AmityToastBloc>(),
        successMessage: context.l10n.toast_message_reported,
        errorMessage: context.l10n.toast_message_report_error,
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
            color: theme.backgroundColor,
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
                    color: theme.baseColorShade3,
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
                          theme.baseColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Others',
                        style: AmityTextStyle.titleBold(theme.baseColor),
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

              const SizedBox(height: 24),

              // Description label
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    Text(
                      'Describe your reason',
                      style: AmityTextStyle.titleBold(theme.baseColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(Optional)',
                      style: AmityTextStyle.caption(theme.baseColorShade3),
                    ),
                    const Spacer(),
                    Text(
                      '${state.characterCount}/300',
                      style: AmityTextStyle.caption(theme.baseColorShade1),
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
                  decoration: InputDecoration(
                    hintText: context.l10n.message_report_details_hint,
                    hintStyle: AmityTextStyle.body(theme.baseColorShade3),
                    contentPadding: EdgeInsets.only(bottom: 8),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.baseColorShade4),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.baseColorShade4),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.baseColorShade4),
                    ),
                    counterText: '', // Hide the default counter
                  ),
                  maxLength: 300, // Still enforce the limit
                  style: AmityTextStyle.body(theme.baseColor),
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
                        ? theme.primaryColor
                        : theme.primaryColor.blend(ColorBlendingOption.shade2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor:
                        theme.primaryColor.blend(ColorBlendingOption.shade2),
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
