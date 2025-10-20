part of '../message_bubble_view.dart';

extension TextMessageWidget on MessageBubbleView {
  // Extract URLs from text using linkify
  List<String> _extractUrls(String text) {
    // Use default linkify options for better URL detection
    final options = LinkifyOptions(
      humanize: false,
      defaultToHttps: true,
    );
    
    final elements = linkify(
      text, 
      options: options,
      linkifiers: [
        UrlLinkifier(),
      ],
    );
    
    final urlElements = elements.whereType<UrlElement>();
    final urls = urlElements.map((element) => element.url).toList();
    
    // Cache the processed text for PreviewLinkWidget to use
    final processedTextCache = ProcessedTextCache();
    if (urls.isNotEmpty && !processedTextCache.contains(text)) {
      final entities = urlElements.map((element) => {
        'type': 'url',
        'text': element.url,
        'end': element.text.indexOf(element.url) + element.url.length,
      }).toList();
      
      processedTextCache.put(text, entities);
    }
    
    return urls;
  }

  Widget _buildTextMessageWidget(
      BuildContext context, bool isUser, MessageBubbleState state) {
    
    final text = (message.data as MessageTextData).text ?? "";
    
    return Transform.translate(
      offset: Offset(
          ((bounce * bounceOffset) - bounceOffset) * (isUser ? -1 : 1),
          0), // Bounce effect
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser &&
              message.createdAt != null &&
              message.syncState == AmityMessageSyncState.SYNCED) ...[
            _buildDateWidget(message.createdAt!),
            const SizedBox(width: 8),
          ],
          if (!isUser) ...[
            _buildAvatarWidget(context),
            const SizedBox(width: 8),
          ],
          if (isUser &&
              message.syncState != AmityMessageSyncState.SYNCED &&
              message.syncState != AmityMessageSyncState.FAILED) ...[
            _buildSideTextWidget("Sending..."),
            const SizedBox(width: 8),
          ],
          if (message.syncState == AmityMessageSyncState.FAILED && isUser) ...[
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  _showActionSheet(context);
                },
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_error_message.svg',
                  package: 'amity_uikit_beta_service',
                  width: 16,
                  height: 16,
                  color: theme.baseColorShade2,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Removing the red container that might block the content
          _buildTextWidget(context, text, isUser, state),
          if (!isUser && message.createdAt != null) ...[
            const SizedBox(width: 8),
            _buildDateWidget(message.createdAt!),
          ],
        ],
      ),
    );
  }

  Widget _buildTextWidget(BuildContext context, String text, bool isUser,
      MessageBubbleState state) {
    Color initialColor = isUser
        ? messageColor.rightBubbleDefault
        : messageColor.leftBubbleDefault;
    
    // Extract URLs from the text using linkify
    final urls = _extractUrls(text);

    return StatefulBuilder(
      builder: (context, setState) {
        return Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: text,
                  style: TextStyle(
                    color: isUser
                        ? messageColor.rightBubbleText
                        : messageColor.leftBubbleText,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                maxLines: urls.isNotEmpty ? 5 : 10, // Use 5 lines if message contains link, 10 otherwise
                ellipsis: '...',
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              final isOverflowing = textPainter.didExceedMaxLines;

              return GestureDetector(
                onLongPress: () async {
                  if (message.syncState == AmityMessageSyncState.FAILED) {
                    return;
                  }
                  HapticFeedback.heavyImpact();
                  setState(() {
                    initialColor = isUser
                        ? messageColor.rightBubblePressed
                        : messageColor.leftBubblePressed;
                  });
                  final RenderBox? messageBox =
                      context.findRenderObject() as RenderBox?;
                  final Offset? messagePosition =
                      messageBox?.localToGlobal(Offset.zero);
                  double height = messageBox?.size.height ?? 0;
                  double width = messageBox?.size.width ?? 0;
                  if (message.reactionCount != null &&
                      message.reactionCount! > 0) {
                    height += 26;
                  } else {
                    height += 4;
                  }
                  final offset = Offset(
                      isUser
                          ? messagePosition!.dx + width
                          : messagePosition!.dx,
                      messagePosition.dy + height);

                  final reactions = configProvider.getAllMessageReactions();
                  final reactionActionOffset = Offset(
                      isUser
                          ? messagePosition.dx + width - 208
                          : messagePosition.dx,
                      messagePosition.dy - 52);
                  await _showReactionAndMenu(context, offset,
                      reactionActionOffset, message, state, reactions);

                  setState(() {
                    initialColor = isUser
                        ? messageColor.rightBubbleDefault
                        : messageColor.leftBubbleDefault;
                  });
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6, // 60% width just for the bubble itself
                  ),
                  decoration: BoxDecoration(
                    color: initialColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Always align text to the left
                          children: [
                            // Check if there are mentions in the message
                            (message.metadata != null &&
                                    message.metadata!['mentioned'] != null)
                                ? _buildMentionText(text, isUser, context, hasLinks: urls.isNotEmpty)
                                : RichText(
                                    maxLines: urls.isNotEmpty ? 5 : 10, // Use 5 lines if message contains link, 10 otherwise
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left, // Ensure text is always left-aligned
                                    text: TextSpan(
                                      children: [
                                        ..._buildTextSpans(text, isUser),
                                      ],
                                    ),
                                  ),
                            if (urls.isNotEmpty && message.syncState != AmityMessageSyncState.FAILED) ...[
                              const SizedBox(height: 12),
                              MessageLinkPreviewWidget(
                                key: ValueKey('preview_${message.messageId}_${message.editedAt?.millisecondsSinceEpoch}'),
                                text: text,
                                theme: theme,
                                messageColor: messageColor,
                                isUserMessage: isUser,
                                onTap: () async {
                                  if (await canLaunchUrl(Uri.parse(urls.first))) {
                                    await launchUrl(Uri.parse(urls.first));
                                  }
                                },
                              ),
                            ],
                            if (message.editedAt != null) ...[
                              const SizedBox(
                                height: 12,
                              ),
                              Align(
                                alignment: isUser 
                                    ? Alignment.centerRight 
                                    : Alignment.centerLeft,
                                child: Text(
                                  "Edited",
                                  style: AmityTextStyle.caption(message.userId ==
                                          AmityCoreClient.getUserId()
                                      ? theme.primaryColor
                                          .blend(ColorBlendingOption.shade2)
                                      : theme.baseColorShade1),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      if (isOverflowing)
                        Column(
                          children: [
                            Container(
                              color:
                                  messageColor.bubbleDivider.withOpacity(0.4),
                              height: 1.0,
                              // width: constraints.maxWidth,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  onSeeMoreTap?.call(text);
                                },
                                child: Container(
                                  color: const Color.fromARGB(0, 11, 11, 11),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "See more",
                                        style: TextStyle(
                                          color: isUser
                                              ? messageColor
                                                  .rightBubbleSubtleText
                                              : messageColor
                                                  .leftBubbleSubtleText,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'assets/Icons/amity_ic_seemore_arrow.svg',
                                        package: 'amity_uikit_beta_service',
                                        width: 16,
                                        height: 12,
                                        colorFilter: ColorFilter.mode(
                                          isUser
                                              ? messageColor
                                                  .rightBubbleSubtleText
                                              : messageColor
                                                  .leftBubbleSubtleText,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<TextSpan> _buildTextSpans(String text, bool isUser) {
    final elements = linkify(text);

    return elements.map((element) {
      if (element is LinkableElement) {
        return TextSpan(
          text: element.text,
          style: AmityTextStyle.body(
            isUser ? messageColor.rightBubbleText : theme.highlightColor,
          ).copyWith(decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _onOpenLink(element),
        );
      } else {
        return TextSpan(
          text: element.text,
          style: AmityTextStyle.body(
            isUser
                ? messageColor.rightBubbleText
                : messageColor.leftBubbleText,
          ),
        );
      }
    }).toList();
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch $link';
    }
  }

  Widget _buildMentionText(String text, bool isUser, BuildContext context, {bool hasLinks = false}) {
    try {
      
      if (message.metadata == null || !message.metadata!.containsKey('mentioned')) {
        return RichText(
          maxLines: hasLinks ? 5 : 10,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          text: TextSpan(
            children: _buildTextSpans(text, isUser),
          ),
        );
      }
      
      // Extract all mentions (both users and channels) directly from metadata
      final List<dynamic> mentionedList = message.metadata!['mentioned'] as List<dynamic>;
      List<AmityUserMentionMetadata> allMentions = [];
      
      for (var mention in mentionedList) {
        if (mention is Map<String, dynamic>) {
          try {
            // Extract index and length which are common for all mention types
            final int index = mention['index'] as int;
            final int length = mention['length'] as int;
            final String userId = mention['userId'] as String? ?? ''; // Use empty string if userId is null
                        
            // Create mention metadata for both user and channel mentions
            allMentions.add(AmityUserMentionMetadata(
              userId: userId,
              index: index,
              length: length,
            ));
          } catch (e) {
            debugPrint('Error parsing mention: $e');
          }
        }
      }
      
      if (allMentions.isEmpty) {
        return RichText(
          maxLines: hasLinks ? 5 : 10, // Use 5 lines if message contains link, 10 otherwise
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left, // Ensure text is always left-aligned
          text: TextSpan(
            children: _buildTextSpans(text, isUser),
          ),
        );
      }
      
      // Define text styles
      final normalStyle = TextStyle(
        color: isUser ? messageColor.rightBubbleText : messageColor.leftBubbleText,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
      );

      final mentionStyle = AmityTextStyle.bodyBold(
        isUser ? messageColor.rightBubbleText : theme.primaryColor,
      );

      // Use the ExpandableText widget to handle mentions
      // Add a key based on message ID and edit timestamp to ensure proper rebuilding
      return ExpandableText(
        key: ValueKey('mention_${message.messageId}_${message.editedAt?.millisecondsSinceEpoch}'),
        text: text,
        mentionedUsers: allMentions,
        maxLines: hasLinks ? 5 : 10, // Use 5 lines if message contains link, 10 otherwise
        style: normalStyle,
        linkStyle: mentionStyle,
      );
    } catch (e) {
      debugPrint('Error building mention text: $e');
      // Fallback to regular text display if there's an error
      return RichText(
        maxLines: hasLinks ? 5 : 10, // Use 5 lines if message contains link, 10 otherwise
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left, // Ensure text is always left-aligned
        text: TextSpan(
          children: _buildTextSpans(text, isUser),
        ),
      );
    }
  }
}
