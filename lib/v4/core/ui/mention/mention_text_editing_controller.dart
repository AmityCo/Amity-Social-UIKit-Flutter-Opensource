import 'dart:async';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';

/// Example base mention object
class MentionObject {
  MentionObject({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String avatarUrl;
}

/// Example specialized mention
class UserMention extends MentionObject {
  UserMention({
    required super.id,
    required super.displayName,
    required super.avatarUrl,
  });
}

/// Syntax describing how to transform '@Name' into <###@id###>
class MentionSyntax {
  MentionSyntax({
    required this.startingCharacter,
    required this.missingText,
    this.prefix = '<###',
    this.suffix = '###>',
    this.pattern = r'[a-zA-Z0-9-\s]+',
  }) {
    _mentionRegex = RegExp('($prefix)($startingCharacter)($pattern)($suffix)');
  }

  final String startingCharacter; // e.g. '@'
  final String prefix;
  final String suffix;
  final String missingText;
  final String pattern;

  late RegExp _mentionRegex;
  RegExp getRegExp() => _mentionRegex;
}

/// Internal text run for a mention
class _TextMention {
  _TextMention({
    required this.id,
    required this.display,
    required this.start,
    required this.end,
    required this.syntax,
  });

  final String id;
  final String display;
  final MentionSyntax syntax;
  int start;
  int end;
}

/// The main mention-capable TextEditingController
class MentionTextEditingController extends TextEditingController {
  // ----------------------
  // Internal configuration variables.
  // ----------------------
  Color _mentionBgColor = Colors.transparent;
  Color _mentionTextColor = Colors.blue;
  TextStyle _mentionTextStyle = const TextStyle();
  TextStyle _runTextStyle = const TextStyle(color: Colors.black);

  // Optionally copy text to another controller.
  TextEditingController? controllerToCopyTo;

  // User’s original callback.
  Function(MentionSyntax?, String?)? _userCallback;
  // Additional callback we can chain.
  Function(MentionSyntax?, String?)? _extraCallback;

  // For ID->mention-object lookups.
  final MentionObject? Function(BuildContext, String)? idToMentionObject;

  final List<MentionSyntax> mentionSyntaxes;
  bool isInsertingMention = false;

  // ----------------------
  // Internal mention state.
  // ----------------------
  final List<_TextMention> _cachedMentions = [];
  String _previousText = '';

  int? _mentionStartingIndex;
  int? _mentionLength;
  MentionSyntax? _mentionSyntax;
  bool bGuardDeletion = false;

  /// Constructor.
  MentionTextEditingController({
    this.controllerToCopyTo,
    List<MentionSyntax>? mentionSyntaxes,
    Function(MentionSyntax?, String?)? onSuggestionChanged,
    String? text,
    this.idToMentionObject,
  })  : mentionSyntaxes = mentionSyntaxes ??
      [
        MentionSyntax(
          startingCharacter: '@',
          missingText: 'Unknown user',
          prefix: '<###@',
          suffix: '###>',
          pattern: r'[a-zA-Z0-9-\s]+',
        )
      ],
        _userCallback = onSuggestionChanged,
        super(text: text) {
    _init();
  }

  // ----------------------------------------------------------------
  // CHAINING LOGIC
  // ----------------------------------------------------------------
  void chainOnSuggestionChanged(Function(MentionSyntax?, String?)? newCallback) {
    if (newCallback == null) return;
    final oldCallback = _userCallback;
    _extraCallback = newCallback;
    _userCallback = (syntax, substring) {
      if (oldCallback != null) {
        oldCallback(syntax, substring);
      }
      _extraCallback?.call(syntax, substring);
    };
  }

  // ----------------------------------------------------------------
  // Initialization
  // ----------------------------------------------------------------
  void _init() {
    addListener(_onTextChanged);
    if (text.isNotEmpty) {
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    removeListener(_onTextChanged);
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Helper: Update configuration.
  // ----------------------------------------------------------------
  void updateConfig({
    required Color mentionBgColor,
    required Color mentionTextColor,
    required TextStyle mentionTextStyle,
    required TextStyle runTextStyle,
  }) {
    bool changed = false;
    if (_mentionBgColor != mentionBgColor) {
      _mentionBgColor = mentionBgColor;
      changed = true;
    }
    if (_mentionTextColor != mentionTextColor) {
      _mentionTextColor = mentionTextColor;
      changed = true;
    }
    if (_mentionTextStyle != mentionTextStyle) {
      _mentionTextStyle = mentionTextStyle;
      changed = true;
    }
    if (_runTextStyle != runTextStyle) {
      _runTextStyle = runTextStyle;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------
  // Markup Conversion
  // ----------------------------------------------------------------
  void setMarkupText(BuildContext context, String markupText) {
    String deconstructedText = '';
    int lastStartingRunStart = 0;
    _cachedMentions.clear();

    for (int i = 0; i < markupText.length; i++) {
      final character = markupText[i];
      for (final syntax in mentionSyntaxes) {
        if (character == syntax.prefix[0]) {
          final subStr = markupText.substring(i);
          final match = syntax.getRegExp().firstMatch(subStr);
          if (match != null && match.start == 0) {
            deconstructedText += markupText.substring(lastStartingRunStart, i);
            final matchedMarkup = match.input.substring(match.start, match.end);
            final mentionId = match[3]!;
            final mentionObj = idToMentionObject?.call(context, mentionId);
            final mentionDisplayName =
                mentionObj?.displayName ?? syntax.missingText;
            final insertText =
                '${syntax.startingCharacter}$mentionDisplayName';
            final indexToInsertMention = deconstructedText.length;
            final indexToEndInsertion = indexToInsertMention + insertText.length;
            _cachedMentions.add(_TextMention(
              id: mentionId,
              display: insertText,
              start: indexToInsertMention,
              end: indexToEndInsertion,
              syntax: syntax,
            ));
            deconstructedText += insertText;
            lastStartingRunStart = i + matchedMarkup.length;
          }
        }
      }
    }

    if (lastStartingRunStart != markupText.length) {
      deconstructedText += markupText.substring(lastStartingRunStart);
    }

    _previousText = deconstructedText;
    text = deconstructedText;
  }

  // ----------------------------------------------------------------
  // Query mention substring
  // ----------------------------------------------------------------
  String getSearchText() {
    if (!isMentioning()) return '';
    int start = _mentionStartingIndex! + 1;
    int end = _mentionStartingIndex! + _mentionLength!;
    if (end > text.length) end = text.length;
    if (end <= start) return '';
    return text.substring(start, end);
  }

  MentionSyntax? getSearchSyntax() => _mentionSyntax;

  // ----------------------------------------------------------------
  // Convert displayed text => markup with <###@id###>
  // ----------------------------------------------------------------
  String getMarkupText() {
    String finalString = '';
    int lastRunStart = 0;

    for (final mention in _cachedMentions) {
      if (mention.start != lastRunStart) {
        finalString += text.substring(lastRunStart, mention.start);
      }
      final mentionMarkup =
          '${mention.syntax.prefix}${mention.syntax.startingCharacter}'
          '${mention.id}${mention.syntax.suffix}';
      finalString += mentionMarkup;
      lastRunStart = mention.end;
    }

    if (lastRunStart < text.length) {
      finalString += text.substring(lastRunStart);
    }
    return finalString;
  }

  // ----------------------------------------------------------------
  // Build text with mention highlights
  // ----------------------------------------------------------------
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final children = <InlineSpan>[];
    int lastRunStart = 0;

    for (final mention in _cachedMentions) {
      if (mention.start >= text.length) continue;
      final int safeStart = mention.start.clamp(0, text.length);
      final int safeEnd = mention.end.clamp(0, text.length);
      if (safeStart > lastRunStart) {
        children.add(TextSpan(
          text: text.substring(lastRunStart, safeStart),
          style: _runTextStyle,
        ));
      }
      children.add(TextSpan(
        text: text.substring(safeStart, safeEnd),
        style: _mentionTextStyle.copyWith(
          backgroundColor: _mentionBgColor,
          color: _mentionTextColor,
        ),
      ));
      lastRunStart = safeEnd;
    }
    if (lastRunStart < text.length) {
      children.add(TextSpan(
        text: text.substring(lastRunStart),
        style: _runTextStyle,
      ));
    }
    return TextSpan(children: children);
  }

  // ----------------------------------------------------------------
  // Insert a mention
  // ----------------------------------------------------------------
  void insertMention(MentionObject mention) {
    assert(isMentioning());

    final mentionStart = _mentionStartingIndex!;
    final currentCursor = selection.baseOffset;
    if (currentCursor < mentionStart) {
      cancelMentioning();
      return;
    }
    final mentionEnd = currentCursor;
    final visibleText =
        '${_mentionSyntax!.startingCharacter}${mention.displayName}';
    final visibleEnd = mentionStart + visibleText.length;
    _cachedMentions.add(_TextMention(
      id: mention.id,
      display: mention.displayName,
      start: mentionStart,
      end: visibleEnd,
      syntax: _mentionSyntax!,
    ));
    cancelMentioning();
    isInsertingMention = true;
    text = text.replaceRange(mentionStart, mentionEnd, visibleText);
    _previousText = text;
    selection = TextSelection.collapsed(offset: visibleEnd);
    Future.microtask(() {
      isInsertingMention = false;
    });
    _sortMentions();
  }

  // ----------------------------------------------------------------
  // Mention status
  // ----------------------------------------------------------------
  bool isMentioning() =>
      _mentionStartingIndex != null &&
          _mentionLength != null &&
          _mentionSyntax != null;

  void cancelMentioning() {
    _mentionStartingIndex = null;
    _mentionLength = null;
    _mentionSyntax = null;
    _userCallback?.call(null, null);
  }

  /// Dismisses the current mention trigger.
  ///
  /// This method cancels the mention state without removing the typed text.
  /// The user's typed text (e.g., '@abc') will remain in the text field.
  void dismissCurrentMention() {
    // Simply cancel the mention state without deleting the typed text
    cancelMentioning();
  }

  // Keep mention data sorted by start index.
  void _sortMentions() {
    _cachedMentions.sort((a, b) => a.start - b.start);
  }

  Future<void> _onTextChanged() async {
    if (isInsertingMention) return;
    if (_previousText == text) return;
    _processTextChange();
    _previousText = text;
    if (controllerToCopyTo != null) {
      controllerToCopyTo!.text = text;
    }
  }

  void _processTextChange() {
    final differences = diff(_previousText, text);
    int currentTextIndex = 0;
    for (final d in differences) {
      if (d.operation == DIFF_INSERT) {
        if (isMentioning()) {
          if (d.text == ' ') {
            cancelMentioning();
          } else {
            int mentionEnd = _mentionStartingIndex! + _mentionLength!;
            if (mentionEnd > text.length) mentionEnd = text.length;
            if (currentTextIndex >= _mentionStartingIndex! &&
                currentTextIndex <= mentionEnd) {
              _mentionLength = _mentionLength! + d.text.length;
              final typedSub = getSearchText();
              final real = typedSub.startsWith('@')
                  ? typedSub.substring(1)
                  : typedSub;
              if (real.isNotEmpty) {
                _userCallback?.call(_mentionSyntax, real);
              } else if (typedSub == '@') {
                _userCallback?.call(_mentionSyntax, "");
              } else {
                _userCallback?.call(null, null);
              }
            } else {
              cancelMentioning();
            }
          }
        } else {
          for (final syntax in mentionSyntaxes) {
            if (d.text.contains(syntax.startingCharacter)) {
              _mentionStartingIndex = currentTextIndex;
              _mentionLength = d.text.length + 1;
              _mentionSyntax = syntax;
              _userCallback?.call(_mentionSyntax, "");
              break;
            }
          }
        }
      } else if (d.operation == DIFF_DELETE) {
        if (isMentioning()) {
          if (d.text.contains(_mentionSyntax!.startingCharacter) &&
              currentTextIndex <= _mentionStartingIndex!) {
            cancelMentioning();
          } else {
            int mentionEnd = _mentionStartingIndex! + _mentionLength!;
            if (mentionEnd > text.length) mentionEnd = text.length;
            if (currentTextIndex < _mentionStartingIndex!) {
              // Outside mention: do nothing.
            } else if (currentTextIndex > mentionEnd) {
              // Outside mention: do nothing.
            } else {
              _mentionLength = _mentionLength! - d.text.length;
              if (_mentionLength! < 1) {
                _userCallback?.call(null, null);
              } else {
                final typedSub = getSearchText();
                final real = typedSub.startsWith('@')
                    ? typedSub.substring(1)
                    : typedSub;
                if (real.isNotEmpty) {
                  _userCallback?.call(_mentionSyntax, real);
                } else if (typedSub == '@') {
                  _userCallback?.call(_mentionSyntax, "");
                } else {
                  _userCallback?.call(null, null);
                }
              }
            }
          }
        }
      }
      final rangeStart = currentTextIndex;
      var rangeEnd = currentTextIndex + d.text.length;
      if (d.operation != DIFF_DELETE) {
        rangeEnd -= 1;
      }
      
      for (int x = _cachedMentions.length - 1; x >= 0; x--) {
        final mention = _cachedMentions[x];
        if (mention.start >= currentTextIndex && d.operation == DIFF_INSERT) {
          mention.start += d.text.length;
          mention.end += d.text.length;
        }
        if (!bGuardDeletion && d.operation != DIFF_EQUAL) {
          if (rangeStart < mention.end && rangeEnd > mention.start) {
            _cachedMentions.removeAt(x);
            continue;
          }
        }
        if (mention.start >= currentTextIndex && d.operation == DIFF_DELETE) {
          mention.start -= d.text.length;
          mention.end -= d.text.length;
        }
      }
      
      if (d.operation == DIFF_EQUAL || d.operation == DIFF_INSERT) {
        currentTextIndex += d.text.length;
      } else if (d.operation == DIFF_DELETE) {
        currentTextIndex -= d.text.length;
      }
    }
  }

  // ----------------------------------------------------------------
  // Additional Helpers
  // ----------------------------------------------------------------
  List<AmityUserMentionMetadata> getAmityMentionMetadata() {
    final mentionList = getMentions();
    
    if (mentionList.isEmpty) {
      return [];
    }
    
    try {
      final result = mentionList.map((m) {
        final userId = m["userId"] as String;
        final startIndex = m["startIndex"] as int;
        final endIndex = m["endIndex"] as int;
        
        // Calculate length properly to maintain consistency
        final length = endIndex - startIndex;
        
        return AmityUserMentionMetadata(
          userId: userId,
          index: startIndex,
          length: length,
        );
      }).toList();
      
      return result;
    } catch (e) {
      return [];
    }
  }

  List<String> getMentionUserIds() {
    final mentionObjs = getAmityMentionMetadata();
    final userIds = mentionObjs.map((m) => m.userId).toSet().toList();
    return userIds;
  }

  List<String> getAllMentionUserIds() {
    final mentionObjs = getAmityMentionMetadata();
    final userIds = mentionObjs.map((m) => m.userId).toList();
    return userIds;
  }

  Map<String, dynamic> _buildPlainTextAndMentions() {
    final plainBuffer = StringBuffer();
    final List<Map<String, dynamic>> mentionsList = [];
    _cachedMentions.sort((a, b) => a.start - b.start);
    int currentOffset = 0;
    int lastPos = 0;
    for (final mention in _cachedMentions) {
      if (mention.start > lastPos) {
        final normalText = text.substring(lastPos, mention.start);
        plainBuffer.write(normalText);
        currentOffset += normalText.length;
        lastPos = mention.start;
      }
      final mentionText = text.substring(mention.start, mention.end);
      final mentionStartInPlain = currentOffset;
      plainBuffer.write(mentionText);
      currentOffset += mentionText.length;
      final mentionEndInPlain = currentOffset;
      
      mentionsList.add({
        "userId": mention.id,
        "startIndex": mentionStartInPlain,
        "endIndex": mentionEndInPlain,
      });
      lastPos = mention.end;
    }
    if (lastPos < text.length) {
      final remaining = text.substring(lastPos);
      plainBuffer.write(remaining);
      currentOffset += remaining.length;
    }
    
    final result = {
      "plainText": plainBuffer.toString(),
      "mentions": mentionsList,
    };
    
    return result;
  }

  List<Map<String, dynamic>> getMentions() {
    try {
      final result = _buildPlainTextAndMentions();
      final mentions = result["mentions"] as List<Map<String, dynamic>>;
      return mentions;
    } catch (e) {
      return [];
    }
  }

  String getPlainText() {
    final result = _buildPlainTextAndMentions();
    return result['plainText'] as String;
  }

  void populate(String plainText, List<AmityUserMentionMetadata> mentionList) {
    _cachedMentions.clear();
    mentionList.sort((a, b) => a.index.compareTo(b.index));
    
    if (mentionSyntaxes.isEmpty) {
      text = plainText;
      return;
    }
    
    final defaultSyntax = mentionSyntaxes.first;
    for (final m in mentionList) {
      try {
        if (m.index >= plainText.length) {
          continue;
        }
        
        // Calculate the correct end position based on the mention length
        int end = m.index + m.length;
        if (end > plainText.length) {
          end = plainText.length;
        }
        
        // Extract the full text including the @ symbol
        final fullText = plainText.substring(m.index, end);
        
        // The display text should only be the name part (without @)
        // So if fullText is "@John", display should be "John"
        String displayText = fullText;
        if (fullText.startsWith(defaultSyntax.startingCharacter)) {
          displayText = fullText.substring(defaultSyntax.startingCharacter.length);
        }
        
        _cachedMentions.add(_TextMention(
          id: m.userId,
          display: displayText,  // Just the name without @
          start: m.index,
          end: end,
          syntax: defaultSyntax,
        ));
      } catch (e) {
      }
    }
    
    _previousText = plainText;
    text = plainText;
    notifyListeners();
  }
}
