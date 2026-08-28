import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/processed_text_cache.dart';
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
  // Optional search keyword to highlight (case-insensitive) at every
  // occurrence in [text], including inside urls and mentions.
  final String? highlightKeyword;
  // Merged on top of the underlying style at each match, so matches keep their
  // own colour. Omit any colour here to preserve it.
  final TextStyle? highlightStyle;

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
    this.highlightKeyword,
    this.highlightStyle,
  }) : super(key: key);

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
      _truncatedSpans = _entitiesToTextSpans(truncatedText, _textCache.get(truncatedText)!);
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
        spans.addAll(_highlightedSpans(
            safeSubstring(text, currentIndex, entityStart), widget.style));
      }

      // Add the entity with appropriate styling
      if (entity['type'] == 'url') {
        final recognizer = TapGestureRecognizer()
          ..onTap = () async {
            String url = entity['text'];
            if (!url.startsWith('http://') &&
                !url.startsWith('https://') &&
                !url.startsWith('ftp://') &&
                !url.startsWith('mailto:')) {
              url = 'https://$url';
            }
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          };
        spans.addAll(_highlightedSpans(entity['text'], widget.linkStyle,
            recognizer: recognizer));
      } else if (entity['type'] == 'mention') {
        int mentionEnd = entity['end'];
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            widget.onMentionTap?.call(entity['userId']);
          };
        spans.addAll(_highlightedSpans(
            safeSubstring(text, entityStart, mentionEnd), widget.linkStyle,
            recognizer: recognizer));
      }

      currentIndex = entityEnd;
    }

    // Add any remaining text after the last entity
    if (currentIndex < text.length) {
      spans.addAll(
          _highlightedSpans(text.substring(currentIndex), widget.style));
    }

    return spans;
  }

  // Splits [segment] on case-insensitive keyword matches. [recognizer] is
  // reapplied to every span so splitting a tappable entity keeps its tap target.
  List<TextSpan> _highlightedSpans(
    String segment,
    TextStyle? baseStyle, {
    GestureRecognizer? recognizer,
  }) {
    final keyword = widget.highlightKeyword?.trim() ?? '';
    if (segment.isEmpty || keyword.isEmpty) {
      return [
        TextSpan(text: segment, style: baseStyle, recognizer: recognizer)
      ];
    }

    final matchStyle = widget.highlightStyle == null
        ? baseStyle
        : (baseStyle ?? const TextStyle()).merge(widget.highlightStyle);
    final lowerSegment = segment.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    final List<TextSpan> spans = [];
    int currentIndex = 0;
    int searchStart = 0;
    while (searchStart <= lowerSegment.length) {
      final matchIndex = lowerSegment.indexOf(lowerKeyword, searchStart);
      if (matchIndex == -1) break;
      final matchEnd = matchIndex + lowerKeyword.length;

      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: segment.substring(currentIndex, matchIndex),
          style: baseStyle,
          recognizer: recognizer,
        ));
      }
      spans.add(TextSpan(
        text: segment.substring(matchIndex, matchEnd),
        style: matchStyle,
        recognizer: recognizer,
      ));
      currentIndex = matchEnd;
      // Advance past this match; non-overlapping occurrences are highlighted.
      searchStart = matchEnd;
    }

    if (currentIndex < segment.length) {
      spans.add(TextSpan(
        text: segment.substring(currentIndex),
        style: baseStyle,
        recognizer: recognizer,
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
      int endPosition = _calculateTruncatePosition(widget.text, maxWidth,
          showMorePainter.width, widget.maxLines ?? 3);

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
    high = max(0, min(high, maxSearchLength));

    return max(0, high - widget.showMoreText.length + 4); // Add 4 for "... "
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
    } else if (oldWidget.highlightKeyword != widget.highlightKeyword ||
        oldWidget.highlightStyle != widget.highlightStyle) {
      // Keyword styling is applied when entities are converted to spans (not
      // baked into the shared cache), so a keyword change only needs the spans
      // rebuilt for the same text. Clear the derived spans and recompute.
      _truncatedSpans = null;
      _processedSpans = null;
      _processText(widget.text);
      if (mounted) setState(() {});
    }
  }
}

bool _hasBalancedParens(String text) {
  int open = 0;
  int close = 0;
  for (int i = 0; i < text.length; i++) {
    if (text[i] == '(') open++;
    if (text[i] == ')') close++;
  }
  return open == close;
}

Future<List<Map<String, dynamic>>> processTextInBackground(
    TextProcessingData data) async {
  // Kept byte-identical to the shared native pattern (iOS
  // AmityPreviewLinkWizard.pattern / Android urlPattern) so link detection
  // agrees across platforms. A scheme, mailto: or www. prefix is required, so
  // bare word.word text such as "running.the" is not treated as a url.
  final RegExp urlRegExp = RegExp(
      r'(?<![\w])(?:(?:https?|ftp):\/\/(?:[a-zA-Z0-9.-]+|[\d.]+)(?::\d{1,5})?(?:\/(?:[^\s<>|()]*(?:\([^\s<>|()]*\)[^\s<>|()]*)*)*)?|mailto:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|www\.(?:[a-zA-Z0-9.-]+)(?:\/(?:[^\s<>|()]*(?:\([^\s<>|()]*\)[^\s<>|()]*)*)*)?)?(?=[.,;]?\s|[.,;]?$|$)',
      caseSensitive: false,
      multiLine: true);

  List<Map<String, dynamic>> entities = [];

  // Add URL matches
  for (final Match match in urlRegExp.allMatches(data.text)) {
    final String matched = match.group(0)!;
    // The outer alternation is optional, so the pattern yields empty matches at
    // sentence boundaries where only the trailing lookahead is satisfied.
    if (matched.trim().isEmpty) continue;
    if (!_hasBalancedParens(matched)) continue;

    entities.add({
      'type': 'url',
      'index': match.start,
      'length': match.end - match.start,
      'text': matched,
    });
  }

  // Add mentions if provided
  if (data.mentionedUsers != null) {
    for (var mention in data.mentionedUsers!) {
      if (mention.index < data.text.length) {
        int rawEndIndex = mention.index + mention.length;
        int safeEndIndex = min(rawEndIndex, data.text.length);

        if (safeEndIndex > mention.index) {
          entities.add({
            'type': 'mention',
            'index': mention.index,
            'length': mention.length,
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