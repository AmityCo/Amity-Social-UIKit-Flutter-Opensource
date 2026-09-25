import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageReportErrorView extends StatelessWidget {
  final Function()? onCancel;
  final AmityThemeColor theme;

  const MessageReportErrorView({
    Key? key,
    this.onCancel,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: ShapeDecoration(
              color: context.amityToken(AmityColorToken.textSheetsHeaderTextDescriptionDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Error content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/Icons/amity_ic_report_message_error.svg',
                    width: 61,
                    height: 41,
                    package: 'amity_uikit_beta_service',
                    colorFilter: ColorFilter.mode(
                      context.amityToken(AmityColorToken.textInputTextInputPlaceholderEnabled),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: AmityTextStyle.headline(context.amityToken(AmityColorToken.textSheetsHeaderTextDescriptionDefault)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The message you\'re looking for is unavailable.',
                    style: AmityTextStyle.body(context.amityToken(AmityColorToken.textSheetsHeaderTextDescriptionDefault)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(height: 1, color: context.amityToken(AmityColorToken.lineDividerContentDefault)),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor:
                    context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryDisabled),
              ),
              child: Text(
                'Close',
                style: AmityTextStyle.bodyBold(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
