import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityStoryHyperlinkView extends StatelessWidget {
  final HyperLink hyperlink;
  final Function onClick;
  const AmityStoryHyperlinkView(
      {super.key, required this.hyperlink, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            onClick();
          },
          child: SizedBox(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    100,
                  ),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/Icons/ic_link_blue.svg",
                    package: 'amity_uikit_beta_service',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    getHyperlinkText(hyperlink).length > 30
                        ? "${getHyperlinkText(hyperlink).substring(0, 30)}..."
                        : getHyperlinkText(hyperlink),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: "SF Pro Text",
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getHyperlinkText(HyperLink hyperLink) {
    if (hyperLink.customText != null && hyperLink.customText!.isNotEmpty) {
      return hyperLink.customText!;
    }
    return hyperLink.url ?? "";
  }
}
