import 'package:amity_uikit_beta_service/v4/core/theme.dart';
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
        backgroundColor: theme.backgroundColor,
        scrolledUnderElevation: 1,
        centerTitle: displayName == "Replied message", //TODO Remove this condition when jump to replied message is implemented
        title: Text(displayName,
            style: TextStyle(
              color: theme.baseColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: theme.backgroundColor,
        child: Scrollbar(
          thickness: 4.0, 
          radius: const Radius.circular(8.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: SelectableLinkify(
                text: fullText,
                style: TextStyle(
                    color: theme.baseColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
                linkStyle: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.primaryColor),
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
