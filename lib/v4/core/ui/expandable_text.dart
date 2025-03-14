import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final List<AmityUserMentionMetadata>? mentionedUsers;
  final TextStyle linkStyle;
  final TextStyle style;
  final int? maxLines;
  final String showMoreText;
  final Function(String userId)? onMentionTap;
  // LayoutBuilder approach doesn't work if ExpandableText is used within IntrinsicWidth widget. Set false to use RenderBox approach.
  final bool useLayoutBuilder;

  const ExpandableText({
    Key? key,
    required this.text,
    required this.mentionedUsers,
    this.style = const TextStyle(color: Colors.black),
    this.maxLines,
    this.linkStyle = const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    this.showMoreText = "See more",
    this.onMentionTap,
    this.useLayoutBuilder = true,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  final RegExp _urlRegExp = RegExp(
      r'((?:https?://|www\.)?(?:[-a-z0-9]+\.)*[-a-z0-9]+\.[a-z0-9]+(?:\/[^?\s]*)?(?:\?[^\s]*)?)');
  final GlobalKey _textKey = GlobalKey();
  double? _containerWidth;
  bool _measuringInProgress = false;

  @override
  void initState() {
    super.initState();
    if (!widget.useLayoutBuilder && widget.maxLines != null) {
      // Only use post-frame callback when not using LayoutBuilder
      _scheduleWidthMeasurement();
    }
  }
  
  void _scheduleWidthMeasurement() {
    if (_measuringInProgress) return;
    
    _measuringInProgress = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContainerWidth();
      _measuringInProgress = false;
    });
  }

  void _measureContainerWidth() {
    final RenderBox? renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final newWidth = renderBox.size.width;
      if (_containerWidth != newWidth) {
        setState(() {
          _containerWidth = newWidth;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose between approaches based on the flag
    if (widget.useLayoutBuilder) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _buildByConstraints(constraints.maxWidth);
        },
      );
    } else {
      return Container(
        key: _textKey,
        child: _buildContent(),
      );
    }
  }

  Widget _buildContent() {
    if (widget.maxLines == null) {
      return _buildExpandedText();
    } else if (!_expanded) {
      // Fall back to MediaQuery if measurement hasn't completed
      _containerWidth ??= MediaQuery.of(context).size.width;
      return _buildCollapsedText(_containerWidth!);
    } else {
      return _buildExpandedText();
    }
  }
  
  Widget _buildByConstraints(double width) {
    if (widget.maxLines == null || _expanded) {
      return _buildExpandedText();
    } else {
      return _buildCollapsedText(width);
    }
  }

  Widget _buildCollapsedText(double maxWidth) {
    final TextSpan fullTextSpan = TextSpan(
      children: _processTextWithUrlsAndMentions(widget.text),
      style: widget.style,
    );

    final TextPainter textPainter = TextPainter(
      text: fullTextSpan,
      textDirection: TextDirection.ltr,
      maxLines: widget.maxLines,
    );
    textPainter.layout(maxWidth: maxWidth);

    if (!textPainter.didExceedMaxLines) {
      // Text fits within maxLines, no need for "showMore"
      return RichText(text: fullTextSpan);
    }

    // Calculate where to truncate the text
    final String showMoreString = widget.showMoreText;
    final TextSpan showMoreSpan = TextSpan(
      children: [
        TextSpan(text: '... ', style: widget.style),
        TextSpan(text: showMoreString, style: widget.linkStyle),
      ],
    );

    final TextPainter showMorePainter = TextPainter(
      text: showMoreSpan,
      textDirection: TextDirection.ltr,
    );
    showMorePainter.layout(maxWidth: maxWidth);

    // Find position to truncate original text to fit with "...showMore"
    int endPosition = _calculateTruncatePosition(
        widget.text, maxWidth, showMorePainter.width, widget.maxLines ?? 3);

    if (endPosition < 0) endPosition = 0;

    // Create truncated text
    final String truncatedText =
        safeSubstring(widget.text, 0, endPosition).trim();

    // Process URLs in truncated text
    final List<TextSpan> truncatedTextSpans =
        _processTextWithUrlsAndMentions(truncatedText);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = true;
        });
      },
      child: RichText(
        maxLines: widget.maxLines,
        overflow: TextOverflow.clip,
        text: TextSpan(
          children: [
            ...truncatedTextSpans,
            TextSpan(
              text: '... ',
              style: widget.style,
            ),
            TextSpan(
              text: showMoreString,
              style: widget.linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _expanded = true;
                  });
                },
            ),
          ],
          style: widget.style,
        ),
      ),
    );
  }

  int _calculateTruncatePosition(
      String text, double maxWidth, double showMoreWidth, int maxLines) {
    // Check for empty text
    if (text.isEmpty) {
      return 0;
    }

    // Create text painter for measuring
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );

    // Start with trying the full text
    textPainter.layout(maxWidth: maxWidth);

    // If text fits completely, return the full length
    if (!textPainter.didExceedMaxLines) {
      return text.length;
    }

    // Try different lengths with binary search
    int low = 0;
    int high = text.length;

    while (low < high) {
      final int mid = (low + high) ~/ 2;

      // Check if this length works with the "See more" text
      textPainter.text = TextSpan(
        children: [
          TextSpan(text: safeSubstring(text, 0, mid), style: widget.style),
          TextSpan(text: '... ', style: widget.style),
          TextSpan(text: widget.showMoreText, style: widget.linkStyle),
        ],
      );

      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines) {
        // Still too much text
        high = mid - 1;
      } else {
        // Text fits, try with more
        low = mid + 1;
      }
    }

    // Ensure high value is in valid range
    high = max(0, min(high, text.length));

    return max(0, high - widget.showMoreText.length + 4); // Add 4 for "... "
  }

  Widget _buildExpandedText() {
    final List<TextSpan> textSpans =
        _processTextWithUrlsAndMentions(widget.text);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = false;
        });
      },
      child: RichText(
        text: TextSpan(
          children: [
            ...textSpans,
          ],
          style: widget.style,
        ),
      ),
    );
  }

  List<TextSpan> _processTextWithUrlsAndMentions(String text) {
    List<TextSpan> spans = [];
    int currentIndex = 0;

    // First, extract all URLs into a list of "entities" with their positions
    List<Map<String, dynamic>> entities = [];

    // Add URL matches
    for (final Match match in _urlRegExp.allMatches(text)) {
      entities.add({
        'type': 'url',
        'index': match.start,
        'length': match.end - match.start,
        'text': match.group(0)!,
      });
    }

    // Add mentions if provided
    if (widget.mentionedUsers != null) {
      for (var mention in widget.mentionedUsers!) {
        if (mention.index < text.length) {
          // We need to adjust the end position correctly
          int rawEndIndex = mention.index + mention.length + 1;
          // Clamp the end index to the text length.
          int safeEndIndex = min(rawEndIndex, text.length);

          if (safeEndIndex > mention.index) {
            entities.add({
              'type': 'mention',
              'index': mention.index,
              'length': mention.length + 1,
              'userId': mention.userId,
              'end': safeEndIndex,
            });
          }
        }
      }
    }

    // Sort entities by their starting position
    entities.sort((a, b) => a['index'].compareTo(b['index']));

    // Process the text with entities in order
    for (var entity in entities) {
      int entityStart = entity['index'];
      int entityEnd = entityStart + entity['length'] as int;

      // Add normal text before this entity
      if (entityStart > currentIndex) {
        spans.add(TextSpan(
          text: safeSubstring(text, currentIndex, entityStart),
          style: widget.style,
        ));
      }

      // Add the entity with appropriate styling
      if (entity['type'] == 'url') {
        spans.add(TextSpan(
          text: entity['text'],
          style: widget.linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              String url = entity['text'];
              if (!url.startsWith('http')) {
                url = 'https://$url';
              }
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
        ));
      } else if (entity['type'] == 'mention') {
        // Use the pre-calculated end position from the entity
        int mentionEnd = entity['end'];

        // Create the span with the full mention text
        spans.add(TextSpan(
          text: safeSubstring(text, entityStart, mentionEnd),
          style: widget.linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              widget.onMentionTap?.call(entity['userId']);
            },
        ));
      }

      currentIndex = entityEnd;
    }

    // Add any remaining text after the last entity
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: widget.style,
      ));
    }

    return spans;
  }

  String safeSubstring(String text, int start, int end) {
    try {
      return text.substring(start, end);
    } catch (e) {
      // Try one character earlier
      if (end > start && end > 0) {
        return safeSubstring(text, start, end - 1);
      }
      // Fallback
      return '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only use measurement with RenderBox approach
    if (!widget.useLayoutBuilder && widget.maxLines != null) {
      _scheduleWidthMeasurement();
    }
  }
}