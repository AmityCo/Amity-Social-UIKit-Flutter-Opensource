import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class FullTextScreen extends StatelessWidget {
  final String fullText;
  final String displayName;
  final AmityThemeColor theme;

  const FullTextScreen({
    Key? key,
    required this.fullText,
    required this.displayName,
    required this.theme,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.amityToken(AmityColorToken.surfaceSheetsBackgroundGeneral),
        iconTheme: IconThemeData(color: context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault)),
        scrolledUnderElevation: 1,
        // The see-more page centres its title in the design for every title,
        // not just the replied-message one. The old condition compared against
        // an English literal, so a display name was left-aligned and no title
        // ever centred in another locale (PDT-5046).
        centerTitle: true,
        title: Text(displayName,
            style: TextStyle(
              color: context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: context.amityToken(AmityColorToken.surfaceSheetsBackgroundGeneral),
        child: Scrollbar(
          thickness: 4.0, 
          radius: const Radius.circular(8.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: SelectableLinkify(
                text: fullText,
                style: TextStyle(
                    color: context.amityToken(AmityColorToken.textSheetsHeaderTitleDefault),
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
                linkStyle: TextStyle(
                    color: context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: context.amityToken(AmityColorToken.surfaceMainButtonDefaultFilledPrimaryEnabled)),
                onOpen: (link) async {
                  final Uri url = Uri.parse(link.url);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                options: LinkifyOptions(
                  humanize: false,
                  defaultToHttps: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
