import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/utils/processed_text_cache.dart';
import 'package:flutter/foundation.dart';
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

  ExpandableText({
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

  final LaunchMode urlLaunchMode = AmityUIKit4Manager
      .freedomBehavior.postContentComponentBehavior.urlLaunchMode;

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  final GlobalKey _textKey = GlobalKey();
  double? _containerWidth;
  bool _measuringInProgress = false;

  // Store processed spans synchronously when available
  List<TextSpan>? _processedSpans;
  List<TextSpan>? _truncatedSpans;

  // To track if processing is in progress
  bool _isProcessing = false;

  final ProcessedTextCache _textCache = ProcessedTextCache();

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;
  late final String localizedShowMoreText =
      _getText(context, 'community_posts_see_more') ?? widget.showMoreText;

  @override
  void initState() {
    super.initState();
    if (!widget.useLayoutBuilder && widget.maxLines != null) {
      _scheduleWidthMeasurement();
    }

    // Pre-process the text to avoid lag when expanding
    _processText(widget.text);
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

  // Process text and update state synchronously if cache hit, asynchronously if needed
  void _processText(String text) {
    // Check cache first - synchronous
    if (_textCache.contains(text)) {
      _processedSpans = _entitiesToTextSpans(text, _textCache.get(text)!);
      return; // Return early, we have the spans
    }

    // No cache hit, we need async processing
    _isProcessing = true;
    _processTextAsync(text).then((spans) {
      if (mounted) {
        setState(() {
          _processedSpans = spans;
          _isProcessing = false;
        });
      }
    });
  }

  // Process truncated text
  void _processTruncatedText(String truncatedText) {
    // Check cache first - synchronous
    if (_textCache.contains(truncatedText)) {
      _truncatedSpans =
          _entitiesToTextSpans(truncatedText, _textCache.get(truncatedText)!);
      return; // Return early, we have the spans
    }

    // No cache hit, we need async processing
    _processTextAsync(truncatedText).then((spans) {
      if (mounted) {
        setState(() {
          _truncatedSpans = spans;
        });
      }
    });
  }

  // Process text in background thread using compute
  Future<List<TextSpan>> _processTextAsync(String text) async {
    // Check cache first
    if (_textCache.contains(text)) {
      return _entitiesToTextSpans(text, _textCache.get(text)!);
    }

    // Create processing data
    final data = TextProcessingData(
      text: text,
      mentionedUsers: widget.mentionedUsers,
      style: widget.style,
      linkStyle: widget.linkStyle,
    );

    try {
      // Process in background
      final entities = await compute(processTextInBackground, data);

      // Cache the result
      _textCache.put(text, entities);

      // Convert entities to spans on main thread
      List<TextSpan> spans = _entitiesToTextSpans(text, entities);

      return spans;
    } catch (e) {
      return [];
    }
  }

  // Convert entities to TextSpans (runs on main thread)
  List<TextSpan> _entitiesToTextSpans(
      String text, List<Map<String, dynamic>> entities) {
    List<TextSpan> spans = [];
    int currentIndex = 0;

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
                await launchUrl(uri, mode: widget.urlLaunchMode);
              }
            },
        ));
      } else if (entity['type'] == 'mention') {
        int mentionEnd = entity['end'];
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
    // If spans are still processing, show a simple text placeholder
    if (_isProcessing) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // If we have processed spans, use them directly
    if (_processedSpans != null) {
      final TextSpan fullTextSpan = TextSpan(
        children: _processedSpans,
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
      final String showMoreString = localizedShowMoreText;
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

      // Process truncated text if not yet available
      if (_truncatedSpans == null) {
        _processTruncatedText(truncatedText);
      }

      // If truncated spans are available, use them
      if (_truncatedSpans != null) {
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
                ..._truncatedSpans!,
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

      // Fallback while truncated spans are being processed
      return Text(
        truncatedText + "...",
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Fallback when no spans available yet
    return Text(
      widget.text,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
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

    // Calculate average characters per line first
    final double lineHeight = textPainter.preferredLineHeight;
    final double totalHeight = textPainter.height;
    final int estimatedLines = (totalHeight / lineHeight).ceil();

    // Estimate chars per line
    int charsPerLine = text.length ~/ estimatedLines;

    // Use at most maxLines + 2 lines worth of characters for our binary search
    // This significantly reduces the search space for very long texts
    int maxSearchLength = charsPerLine * (maxLines + 1);
    maxSearchLength = min(maxSearchLength, text.length);

    // Try different lengths with binary search
    int low = 0;
    int high = maxSearchLength;

    while (low < high) {
      final int mid = (low + high) ~/ 2;

      // Check if this length works with the "See more" text
      textPainter.text = TextSpan(
        children: [
          TextSpan(text: safeSubstring(text, 0, mid), style: widget.style),
          TextSpan(text: '... ', style: widget.style),
          TextSpan(text: localizedShowMoreText, style: widget.linkStyle),
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
    high = max(0, min(high, maxSearchLength));

    return max(0, high - localizedShowMoreText.length + 4); // Add 4 for "... "
  }

  Widget _buildExpandedText() {
    // If we have processed spans, use them directly
    if (_processedSpans != null) {
      return GestureDetector(
        onTap: () {
          if (widget.maxLines != null) {
            setState(() {
              _expanded = false;
            });
          }
        },
        child: RichText(
          text: TextSpan(
            children: _processedSpans,
            style: widget.style,
          ),
        ),
      );
    }

    // Fallback while still processing
    return Text(
      widget.text,
      style: widget.style,
    );
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

  @override
  void didUpdateWidget(ExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pre-process text when it changes
    if (oldWidget.text != widget.text) {
      _processTextAsync(widget.text);
    }
  }
}

Future<List<Map<String, dynamic>>> processTextInBackground(
    TextProcessingData data) async {
  final RegExp urlRegExp = RegExp(
      r'((?:https?://|www\.)?(?:[-a-z0-9]+\.)*[-a-z0-9]+\.[a-z0-9]+(?:\/[^?\s]*)?(?:\?[^\s]*)?)',
      caseSensitive: false);

  List<Map<String, dynamic>> entities = [];

  // Add URL matches
  for (final Match match in urlRegExp.allMatches(data.text)) {
    entities.add({
      'type': 'url',
      'index': match.start,
      'length': match.end - match.start,
      'text': match.group(0)!,
    });
  }

  // Add mentions if provided
  if (data.mentionedUsers != null) {
    for (var mention in data.mentionedUsers!) {
      if (mention.index < data.text.length) {
        int rawEndIndex = mention.index + mention.length + 1;
        int safeEndIndex = min(rawEndIndex, data.text.length);

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

  return entities;
}

class TextProcessingData {
  final String text;
  final List<AmityUserMentionMetadata>? mentionedUsers;
  final TextStyle style;
  final TextStyle linkStyle;

  TextProcessingData({
    required this.text,
    this.mentionedUsers,
    required this.style,
    required this.linkStyle,
  });
}
