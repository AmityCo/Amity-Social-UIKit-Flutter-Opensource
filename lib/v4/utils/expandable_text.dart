import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AmityExpandableText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final AmityThemeColor theme;
  final bool isDetailExpanded;
  final Function onExpand;

  const AmityExpandableText({
    Key? key,
    required this.theme,
    required this.text,
    required this.maxLines,
    required this.style,
    required this.isDetailExpanded,
    required this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _expandableText(theme, text, maxLines, style, isDetailExpanded, onExpand);
  }

  Widget _expandableText(AmityThemeColor theme,
      String text, int maxLines, TextStyle style, bool isDetailExpanded, Function onExpand) {
    var exceeded = false;
    if (maxLines < 1) {
      maxLines = 1;
    }
    return LayoutBuilder(builder: (context, size) {
      // Build the textspan
      var span = TextSpan(
        text: text,
        style: style,
      );

      // Use a textpainter to determine if it will exceed max lines
      var tp = TextPainter(
        maxLines: maxLines,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        text: span,
      );

      // trigger it to layout
      tp.layout(maxWidth: size.maxWidth);

      // whether the text overflowed or not
      exceeded = tp.didExceedMaxLines;

      // return Column(children: <Widget>[
      return Container(
            child: exceeded && isDetailExpanded
                ? Text.rich(
                    span,
                    overflow: TextOverflow.visible,
                    style: style,
                  )
                : exceeded && !isDetailExpanded
                    ? _seeMoreLess(
                        theme, span, context.l10n.general_see_more, style, maxLines, onExpand)
                    : Text.rich(
                        span,
                        overflow: TextOverflow.visible,
                        style: style,
                      ),
      );
    });
  }

  Widget _seeMoreLess(AmityThemeColor theme,
      TextSpan span, String _text, TextStyle style, int maxLine, Function onExpand) {
    final hightlightStyle = style.copyWith(color: theme.highlightColor);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        maxLine > 0
            ? Text.rich(
                span,
                overflow: TextOverflow.clip,
                style: style,
                maxLines: maxLine,
              )
            : Text.rich(
                span,
                overflow: TextOverflow.visible,
                style: style,
              ),
        InkWell(
            child: Text(_text, style: hightlightStyle),
            onTap: () {
              onExpand();
            }),
      ],
    );
  }
}