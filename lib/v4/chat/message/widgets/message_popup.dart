part of '../message_bubble_view.dart';
// Import already included in the parent file:
// import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
// import 'package:amity_uikit_beta_service/v4/core/theme.dart';
// import 'package:flutter/material.dart';

class ReactionItem {
  final AmityReactionType reaction;
  bool isSelected;

  ReactionItem({
    required this.reaction,
    this.isSelected = false,
  });
}

class ReactionRow extends StatefulWidget {
  final List<ReactionItem> reactions;
  final Function(AmityReactionType, bool) onReactionSelected;
  final AmityThemeColor theme;
  final bool showTooltipBelow;

  const ReactionRow({
    Key? key,
    required this.reactions,
    required this.onReactionSelected,
    required this.theme,
    this.showTooltipBelow = false,
  }) : super(key: key);

  @override
  _ReactionRowState createState() => _ReactionRowState();
}

class _ReactionRowState extends State<ReactionRow> {
  int? highlightedIndex;

  void _updateHighlight(Offset globalPos) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalPos);
    if (localPos.dx < 0 ||
        localPos.dx > renderBox.size.width ||
        localPos.dy < 0 ||
        localPos.dy > renderBox.size.height) {
      if (highlightedIndex != null) {
        setState(() => highlightedIndex = null);
      }
      return;
    }
    final itemWidth = renderBox.size.width / widget.reactions.length;
    int index = (localPos.dx / itemWidth).floor();
    index = index.clamp(0, widget.reactions.length - 1);
    if (index != highlightedIndex) {
      setState(() => highlightedIndex = index);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _updateHighlight(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateHighlight(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (highlightedIndex != null) {
      final reactionItem = widget.reactions[highlightedIndex!];
      if (reactionItem.isSelected) {
        widget.onReactionSelected(reactionItem.reaction, true);
      } else {
        widget.onReactionSelected(reactionItem.reaction, false);
      }
    }
    setState(() => highlightedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: () => setState(() => highlightedIndex = null),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.reactions.length, (index) {
          final active = index == highlightedIndex;
          final reactionItem = widget.reactions[index];

          return Container(
            width: 42,
            height: 52,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (reactionItem.isSelected)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.theme.baseColorShade4,
                    ),
                  ),
                if (active)
                  Positioned(
                    top: widget.showTooltipBelow ? 53 : -33,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: active ? 1.0 : 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            constraints: const BoxConstraints(maxWidth: 64),
                            height: 17,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _capitalizeFirstLetter(
                                  reactionItem.reaction.name),
                              style: AmityTextStyle.captionSmall(Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(
                    0,
                    active ? (widget.showTooltipBelow ? 10 : -10) : 0,
                    0,
                  ),
                  child: SvgPicture.asset(
                    reactionItem.reaction.imagePath,
                    package: 'amity_uikit_beta_service',
                    width: active ? 36 : 30,
                    height: active ? 36 : 30,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

extension MessagePopup on MessageBubbleView {
  Future<String?> _showReactionAndMenu(
    BuildContext context,
    Offset offset,
    Offset reactionActionOffset,
    AmityMessage message,
    MessageBubbleState state,
    List<AmityReactionType> reactions,
  ) async {
    final screenHeight = MediaQuery.of(context).size.height - 50;
    final screenThreshold = (screenHeight) - ((screenHeight) * 0.3);

    final isInLowerPortion = offset.dy > screenThreshold;

    const tooltipHeightWithPadding = 40;
    final isTooCloseToTop = reactionActionOffset.dy < tooltipHeightWithPadding;

    // Check if the message is from the current user
    final isUserMessage = message.userId == AmityCoreClient.getUserId();

    // Show tooltip below if either in lower portion OR too close to top
    final bool showTooltipBelow = isInLowerPortion || isTooCloseToTop;

    // Create an array of ReactionItem and check if it matches with message.myReactions
    final reactionItems = reactions.map((reaction) {
      bool isSelected = message.myReactions?.contains(reaction.name) ?? false;
      return ReactionItem(reaction: reaction, isSelected: isSelected);
    }).toList();

    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          left: reactionActionOffset.dx,
          top: reactionActionOffset.dy < 62 ? 62 : reactionActionOffset.dy,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 150),
            builder: (context, value, child) {
              return Transform(
                alignment: isUserMessage
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                transform: Matrix4.identity()
                  ..scale(value)
                  ..translate(0.0, (1.0 - value) * 20.0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReactionRow(
                      onReactionSelected:
                          (AmityReactionType reaction, bool isSelected) async {
                        HapticFeedback.heavyImpact();

                        if (isSelected) {
                          await message.react().removeReaction(reaction.name);
                        } else {
                          for (var item in reactionItems) {
                            if (item.isSelected) {
                              await message
                                  .react()
                                  .removeReaction(item.reaction.name);
                            }
                          }
                          await message.react().addReaction(reaction.name);
                        }
                        Navigator.of(context).pop();
                      },
                      reactions: reactionItems,
                      theme: theme,
                      showTooltipBelow: showTooltipBelow,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // 2) Insert the overlay
    Overlay.of(context).insert(overlayEntry);

    // 3) Show your existing popup menu
    final result = await _showPopupMenu(context, offset, reactionActionOffset,
        screenThreshold, message, state, isUserMessage);

    // 4) Remove the overlay once showMenu is dismissed
    overlayEntry.remove();

    // 5) Return the user’s selection
    return result;
  }

  Future<String?> _showPopupMenu(
    BuildContext context,
    Offset? offset,
    Offset? reactionActionOffset,
    double screenThreshold,
    AmityMessage message,
    MessageBubbleState state,
    bool isUser,
  ) async {
    if (offset != null) {
      // Adjust the vertical position based on screen position
      final yPos = offset.dy;
      final isInLowerPortion = yPos > screenThreshold;

      // Calculate more accurate menu item count based on message type and ownership
      const menuItemHeight = 48.0;
      const menuPadding = 8.0;

      // Menu item count calculation:
      // 1. Reply (always present for synced messages)
      // 2. Edit (only for own text messages)
      // 3. Copy (only for text messages)
      // 4. Save (only for image/video messages)
      // 5. Delete (only for own messages)
      int itemCount = 0;

      if (message.syncState == AmityMessageSyncState.SYNCED) {
        itemCount += 1; // Reply option always present for synced messages

        if (isUser && message.type == AmityMessageDataType.TEXT) {
          itemCount += 1; // Edit option for own text messages
        }

        if (message.data is MessageTextData) {
          itemCount += 1; // Copy option for any text messages
        }

        if (message.data is MessageImageData ||
            message.data is MessageVideoData) {
          itemCount += 1; // Save option for media messages
        }

        itemCount +=
            1; // Delete option for own messages or report option for others
      }

      final popupHeight = (menuItemHeight * itemCount) + menuPadding;

      final RelativeRect position;
      if (isInLowerPortion) {
        // For lower portion: position menu right above the reaction overlay
        final reactY = reactionActionOffset?.dy ?? yPos;

        position = RelativeRect.fromLTRB(
          offset.dx,
          reactY - popupHeight - 4, // Position above reaction with some spacing
          offset.dx + 1,
          reactY, // Bottom aligns with reaction Y position
        );
      } else {
        // For upper portion: position menu BELOW the tap point
        position = RelativeRect.fromLTRB(
          offset.dx,
          yPos,
          offset.dx + 1,
          yPos + 10, // Small offset to position properly
        );
      }

      final result = await showMenu(
        context: context,
        surfaceTintColor: theme.backgroundColor,
        color: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.4),
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        position: position,
        items: [
          if (message.syncState == AmityMessageSyncState.SYNCED) ...[
            if (isUser && message.type == AmityMessageDataType.TEXT)
              PopupMenuItem(
                value: 'edit',
                child: Container(
                  width: 100,
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/amity_ic_edit_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 20,
                        height: 18,
                        color: theme.baseColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Edit",
                        style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            PopupMenuItem(
              value: 'reply',
              child: Container(
                width: 100,
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/Icons/amity_ic_reply_button.svg',
                      package: 'amity_uikit_beta_service',
                      width: 20,
                      height: 18,
                      color: theme.baseColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Reply",
                      style: TextStyle(
                          color: theme.baseColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            if ((message.data is MessageImageData ||
                message.data is MessageVideoData))
              PopupMenuItem(
                value: 'save',
                child: Container(
                  width: 100,
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/amity_ic_save_image.svg',
                        package: 'amity_uikit_beta_service',
                        width: 20,
                        height: 18,
                        color: theme.baseColor,
                      ),
                      const SizedBox(width: 13),
                      Text(
                        "Save",
                        style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          if (message.data is MessageTextData)
            PopupMenuItem(
              value: 'copy',
              child: Container(
                width: 100,
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/Icons/amity_ic_message_copy.svg',
                      package: 'amity_uikit_beta_service',
                      width: 20,
                      height: 18,
                      color: theme.baseColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Copy",
                      style: TextStyle(
                          color: theme.baseColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          if (!isUser)
            PopupMenuItem(
              value: message.isFlaggedByMe == true ? 'unreport' : 'report',
              child: Container(
                // width: 100,
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      message.isFlaggedByMe == true
                          ? 'assets/Icons/amity_ic_unreport_user_button.svg'
                          : 'assets/Icons/amity_ic_report_user_button.svg',
                      package: 'amity_uikit_beta_service',
                      width: 20,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      message.isFlaggedByMe == true ? "Unreport" : "Report",
                      style: TextStyle(
                        color: theme.baseColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isUser)
            PopupMenuItem(
              value: 'delete',
              child: Container(
                width: 100,
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/Icons/amity_ic_deleted_message.svg',
                      package: 'amity_uikit_beta_service',
                      width: 20,
                      height: 18,
                      color: theme.alertColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: theme.alertColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

      switch (result) {
        case 'copy':
          if (message.data is MessageTextData) {
            final text = (message.data as MessageTextData).text ?? "";
            context.read<AmityToastBloc>().add(AmityToastShort(
                message: "Copied.",
                icon: AmityToastIcon.success,
                bottomPadding: AmityChatPage.toastBottomPadding));
            Clipboard.setData(ClipboardData(text: text));
          }
          break;
        case 'delete':
          deleteMessage(context, false);
          break;
        case 'save':
          if (message.data is MessageImageData) {
            saveImage(context);
          } else if (message.data is MessageVideoData) {
            saveVideo(context);
          }
          break;
        case 'reply':
          replyMessage(context);
          break;
        case 'edit':
          editMessage(context);
          break;
        case 'report':
          flagMessage(context);
          break;
        case 'unreport':
          unflagMessage(context);
          break;
      }
      return result;
    }
    return null;
  }

  Future saveImage(BuildContext context) async {
    await saveImageMessage(context, message);
  }

  Future saveVideo(BuildContext context) async {
    await saveVideoMessage(context, message);
  }

  replyMessage(BuildContext context) {
    final replyingMessage =
        ReplyingMesage(message: message, previewImage: messageImage);
    onReplyMessage?.call(replyingMessage);
  }

  editMessage(BuildContext context) {
    onEditMessage?.call(message);
  }

  flagMessage(BuildContext context) async {
    // Show message report component to select reason
    _showMessageReportBottomSheet(context);
  }

  void _showMessageReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return AmityMessageReportComponent(
          message: message,
          onCancel: () {
            Navigator.pop(modalContext);
          },
        );
      },
    );
  }

  unflagMessage(BuildContext context) async {
    try {
      if (message.user?.userId != null) {
        final messageId = message.messageId ?? "";

        // Unflag the message
        await AmityChatClient.newMessageRepository().unflag(messageId);

        context.read<AmityToastBloc>().add(AmityToastShort(
            message: "Message unreported.",
            icon: AmityToastIcon.success,
            bottomPadding: AmityChatPage.toastBottomPadding));
      } else {
        context.read<AmityToastBloc>().add(AmityToastShort(
            message:
                "Unable to unreport message - user information not available.",
            icon: AmityToastIcon.warning,
            bottomPadding: AmityChatPage.toastBottomPadding));
      }
    } catch (e) {
      context.read<AmityToastBloc>().add(AmityToastShort(
          message: "Failed to unreport message. Please try again.",
          icon: AmityToastIcon.warning,
          bottomPadding: AmityChatPage.toastBottomPadding));
    }
  }

  Future deleteMessage(BuildContext context, bool shouldPop) async {
    showPermissionDialog() async {
      ConfirmationV4Dialog().show(
        context: context,
        title: 'Delete this message?',
        detailText:
            'This message will also be removed from your friend’s devices.',
        leftButtonText: 'Cancel',
        rightButtonText: 'Delete',
        onConfirm: () async {
          try {
            await message.delete();
          } catch (e) {
            context.read<AmityToastBloc>().add(AmityToastShort(
                message: "Failed to delete message.",
                icon: AmityToastIcon.warning,
                bottomPadding: AmityChatPage.toastBottomPadding));
          }
          if (shouldPop) {
            Navigator.pop(context);
          }
        },
      );
    }

    await showPermissionDialog();
  }
}

Future saveImageMessage(BuildContext context, AmityMessage message) async {
  if (message.data is MessageImageData) {
    final permissionHandler = MediaPermissionHandler();
    final bool mediaPermissionGranted =
        await permissionHandler.handleMediaPermissions();
    if (mediaPermissionGranted == false) {
      context.read<AmityToastBloc>().add(AmityToastShort(
          message: "Permission denied.",
          icon: AmityToastIcon.warning,
          bottomPadding: AmityChatPage.toastBottomPadding));
      return;
    }
    final fileInfo = (message.data as MessageImageData).fileInfo;
    final fileUrl = fileInfo.fileUrl;
    final filePath = fileInfo.getFileProperties?.filePath;
    if (await MediaPermissionHandler()
        .downloadAndSaveImage("${fileUrl ?? filePath ?? ''}/?size=large")) {
      context.read<AmityToastBloc>().add(AmityToastShort(
          message: "Saved photo.",
          icon: AmityToastIcon.success,
          bottomPadding: AmityChatPage.toastBottomPadding));
    } else {
      context.read<AmityToastBloc>().add(AmityToastShort(
          message: "Failed to save image.",
          icon: AmityToastIcon.warning,
          bottomPadding: AmityChatPage.toastBottomPadding));
    }
  }
}

Future saveVideoMessage(BuildContext context, AmityMessage message) async {
  if (message.data is MessageVideoData) {
    final videoData = (message.data as MessageVideoData);
    final videoUrl =
        videoData.getVideo().getVideoUrl(AmityVideoResolution.ORIGINAL) ??
            videoData.getVideo().fileUrl;
    if (videoUrl != null) {
      final result =
          await MediaPermissionHandler().downloadAndSaveVideo(videoUrl);
      if (result) {
        context.read<AmityToastBloc>().add(AmityToastShort(
            message: "Saved video.",
            icon: AmityToastIcon.success,
            bottomPadding: AmityChatPage.toastBottomPadding));
      } else {
        context.read<AmityToastBloc>().add(AmityToastShort(
            message: "Failed to save video.",
            icon: AmityToastIcon.warning,
            bottomPadding: AmityChatPage.toastBottomPadding));
      }
    }
  }
}

/// A PageView wrapper for message reporting with slide animation between report screens
/// Note: MessageReportPageView has been moved and renamed to MessageReportComponent
/// Path: /lib/v4/chat/message/components/message_report_component.dart
