import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/single_video_player/pager/video_message_player.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:amity_uikit_beta_service/v4/utils/message_color.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubbleView extends NewBaseComponent {
  final AmityMessage message;
  final AmityChannelMember? channelMember;
  void Function(String)? onSeeMoreTap;
  void Function(AmityMessage)? onResend;
  final Uint8List? thumbnail;
  late MessageColor messageColor;

  MessageBubbleView(
      {super.key,
      super.pageId,
      required this.message,
      this.channelMember,
      this.onSeeMoreTap,
      this.onResend,
      this.thumbnail})
      : super(componentId: "message_bubble");

  @override
  Widget buildComponent(BuildContext context) {
    if (!isColorInitialized()) {
      messageColor = MessageColor(theme: theme, config: config);
    }
    final isUser = message.userId == AmityCoreClient.getUserId();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 98 : 16,
          right: isUser ? 16 : 58,
          top: 4,
          bottom: 4,
        ),
        child: _buildMessageContent(context, isUser),
      ),
    );
  }

  Widget _buildDateWidget(DateTime timestamp) {
    return _buildSideTextWidget(_formatTime(message.createdAt!));
  }

  Widget _buildSideTextWidget(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
            color: theme.baseColorShade2,
            fontSize: 10,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildAvatarWidget(BuildContext context) {
    final avatarUrl = message.user!.avatarUrl;
    return GestureDetector(
      onTap: () {
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmityImageViewer(
                imageUrl: "$avatarUrl?size=large",
              ),
            ),
          );
        }
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: AmityMessageAvatar(channelMember: channelMember),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String text, bool isUser) {
    final elements = linkify(text);

    return elements.map((element) {
      if (element is LinkableElement) {
        return TextSpan(
          text: element.text,
          style: TextStyle(
            color: isUser ? messageColor.rightBubbleText : theme.highlightColor,
            decoration: TextDecoration.underline,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _onOpenLink(element),
        );
      } else {
        return TextSpan(
          text: element.text,
          style: TextStyle(
            color: isUser ? messageColor.rightBubbleText : messageColor.leftBubbleText,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
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

  Widget _buildMediaOverlay() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: theme.baseColor.withOpacity(0.4),
      ),
      child: const SizedBox(),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.toLocal().hour}:${timestamp.toLocal().minute.toString().padLeft(2, '0')}";
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    if (message.isDeleted ?? false) {
      return _buildDeletedMessage(context, theme, isUser);
    } else {
      if (message.data is MessageTextData) {
        return _buildTextMessageWidget(context, isUser);
      } else if (message.data is MessageImageData) {
        return _buildImageMessageWidget(context, isUser);
      } else if (message.data is MessageVideoData) {
        return _buildVideoMessageWidget(context, isUser, thumbnail);
      } else {
        return Container();
      }
    }
  }

  Widget _buildDeletedMessage(
      BuildContext context, AmityThemeColor theme, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser && message.user != null) ...[
          _buildAvatarWidget(context),
          const SizedBox(width: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isUser
                  ? messageColor.rightBubbleDefault
                  : messageColor.leftBubbleDefault,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_deleted_message.svg',
                package: 'amity_uikit_beta_service',
                width: 16,
                height: 14,
                color: isUser
                    ? messageColor.rightBubbleDefault
                    : messageColor.leftBubbleDefault.darken(25),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: isUser
                      ? messageColor.rightBubbleDefault
                      : messageColor.leftBubbleDefault.darken(25),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextMessageWidget(BuildContext context, bool isUser) {
    final text = (message.data as MessageTextData).text ?? "";

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isUser &&
            message.createdAt != null &&
            message.syncState == AmityMessageSyncState.SYNCED) ...[
          _buildDateWidget(message.createdAt!),
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
        if (!isUser) ...[
          _buildAvatarWidget(context),
          const SizedBox(width: 8),
        ],
        _buildTextWidget(context, text, isUser),
        if (!isUser && message.createdAt != null) ...[
          const SizedBox(width: 8),
          _buildDateWidget(message.createdAt!),
        ],
      ],
    );
  }

  Widget _buildTextWidget(BuildContext context, String text, bool isUser) {
    Color initialColor = isUser
        ? messageColor.rightBubbleDefault
        : messageColor.leftBubbleDefault;

    return StatefulBuilder(
      builder: (context, setState) {
        return Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textPainter = TextPainter(
                text: TextSpan(
                  text: text,
                  style: TextStyle(
                    color: isUser ? messageColor.rightBubbleText : messageColor.leftBubbleText,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                maxLines: 10,
                ellipsis: '...',
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              final isOverflowing = textPainter.didExceedMaxLines;

              return GestureDetector(
                onLongPress: () async {
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
                  final offset = Offset(
                      isUser
                          ? messagePosition!.dx + width
                          : messagePosition!.dx,
                      messagePosition.dy + height);

                  await _showPopupMenu(context, offset, message);

                  setState(() {
                    initialColor = isUser
                        ? messageColor.rightBubbleDefault
                        : messageColor.leftBubbleDefault;
                  });
                },
                child: Container(
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
                        child: RichText(
                          text: TextSpan(
                            children: _buildTextSpans(text, isUser),
                          ),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
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
                                  color: Colors.transparent,
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

  Widget _buildImageMessageWidget(BuildContext context, bool isUser) {
    final image = (message.data as MessageImageData).image;
    final fileUrl = image?.getUrl(AmityImageSize.MEDIUM) ?? "";
    final filePath = image?.getFilePath;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: (message.syncState == AmityMessageSyncState.FAILED)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.end,
      children: [
        if (isUser &&
            message.createdAt != null &&
            message.syncState == AmityMessageSyncState.SYNCED) ...[
          _buildDateWidget(message.createdAt!),
          const SizedBox(width: 8),
        ],
        if (isUser &&
            message.syncState != AmityMessageSyncState.SYNCED &&
            message.syncState != AmityMessageSyncState.FAILED) ...[
          _buildSideTextWidget("Sending..."),
          const SizedBox(width: 8),
        ],
        if (message.syncState == AmityMessageSyncState.FAILED && isUser) ...[
          Center(
            child: Container(
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
                  colorFilter: ColorFilter.mode(
                    theme.baseColorShade2,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (!isUser) ...[
          _buildAvatarWidget(context),
          const SizedBox(width: 8),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildImageWidget(
                    context,
                    fileUrl,
                    filePath,
                    null,
                    isUser,
                    message.syncState != AmityMessageSyncState.SYNCED &&
                        message.syncState != AmityMessageSyncState.FAILED, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AmityImageViewer(
                        imageUrl: image?.getUrl(AmityImageSize.LARGE) ?? "",
                        showDeleteButton: isUser,
                        showSaveButton: true,
                        onDelete: () {
                          deleteMessage(context, true);
                        },
                        onSave: () async {
                          await saveImage(context);
                        },
                      ),
                    ),
                  );
                }),
                if (message.syncState == AmityMessageSyncState.FAILED) ...[
                  const SizedBox(height: 4),
                  _buildFailToSendText(),
                ],
              ],
            ),
            if (message.syncState != AmityMessageSyncState.SYNCED &&
                message.syncState != AmityMessageSyncState.FAILED)
              _buildUploadingIndicator(),
            if (message.syncState == AmityMessageSyncState.UPLOADING)
              _buildCancelDownloadButton(),
          ],
        ),
        if (!isUser && message.createdAt != null) ...[
          const SizedBox(width: 8),
          _buildDateWidget(message.createdAt!),
        ],
      ],
    );
  }

  Widget _buildVideoMessageWidget(
      BuildContext context, bool isUser, Uint8List? thumbnail) {
    final videoData = (message.data as MessageVideoData);
    final thumbnailFile = videoData.thumbnailImageFile;
    final filePath = thumbnailFile?.getFilePath;
    final fileUrl = thumbnailFile?.fileUrl;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: (message.syncState == AmityMessageSyncState.FAILED)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.end,
      children: [
        if (isUser &&
            message.createdAt != null &&
            message.syncState == AmityMessageSyncState.SYNCED) ...[
          _buildDateWidget(message.createdAt!),
          const SizedBox(width: 8),
        ],
        if (isUser &&
            message.syncState != AmityMessageSyncState.SYNCED &&
            message.syncState != AmityMessageSyncState.FAILED) ...[
          _buildSideTextWidget("Sending..."),
          const SizedBox(width: 8),
        ],
        if (message.syncState == AmityMessageSyncState.FAILED && isUser) ...[
          Center(
            child: Container(
              alignment: Alignment.center,
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
                  colorFilter: ColorFilter.mode(
                    theme.baseColorShade2,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (!isUser) ...[
          _buildAvatarWidget(context),
          const SizedBox(width: 8),
        ],
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildImageWidget(
                    context,
                    fileUrl,
                    filePath,
                    thumbnail,
                    isUser,
                    message.syncState != AmityMessageSyncState.SYNCED &&
                        message.syncState != AmityMessageSyncState.FAILED, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoMessagePlayer(
                        message: message,
                        onDelete: () {
                          deleteMessage(context, true);
                        },
                      ),
                    ),
                  );
                }),
                if (message.syncState == AmityMessageSyncState.FAILED) ...[
                  const SizedBox(height: 4),
                  _buildFailToSendText(),
                ],
              ],
            ),
            if (message.syncState != AmityMessageSyncState.SYNCED &&
                message.syncState != AmityMessageSyncState.FAILED)
              _buildUploadingIndicator(),
            if (message.syncState == AmityMessageSyncState.UPLOADING)
              _buildCancelDownloadButton(),
            if (message.syncState == AmityMessageSyncState.SYNCED)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoMessagePlayer(
                      message: message,
                      onDelete: () {
                        deleteMessage(context, true);
                      },
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_video_play_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
          ],
        ),
        if (!isUser && message.createdAt != null) ...[
          const SizedBox(width: 8),
          _buildDateWidget(message.createdAt!),
        ],
      ],
    );
  }

  Widget _buildUploadingIndicator() {
    return SizedBox(
      width: 38,
      height: 38,
      child: CircularProgressIndicator(
        color: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.8),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildFailToSendText() {
    return const Text(
      'Failed to send message.',
      style: TextStyle(
        color: Color(0xFFFA4D30),
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildCancelDownloadButton() {
    return GestureDetector(
      onTap: () {
        final uploadId = message.uniqueId;
        if (uploadId != null) {
          AmityCoreClient.newFileRepository().cancelUpload(uploadId);
        }
      },
      child: SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_close_button.svg',
          package: 'amity_uikit_beta_service',
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildImageWidget(
    BuildContext context,
    String? fileUrl,
    String? filePath,
    Uint8List? thumbnail,
    bool isUser,
    bool shouldShowOverlay,
    Function()? onTap,
  ) {
    Color initialColor = isUser
        ? messageColor.rightBubbleDefault
        : messageColor.leftBubbleDefault;
    bool onLongPress = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
          },
          onLongPress: () async {
            HapticFeedback.heavyImpact();
            setState(() {
              onLongPress = true;
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
            final offset = Offset(
                isUser ? messagePosition!.dx + width : messagePosition!.dx,
                messagePosition.dy + height);

            await _showPopupMenu(context, offset, message);

            setState(() {
              onLongPress = false;
              initialColor = isUser
                  ? messageColor.rightBubbleDefault
                  : messageColor.leftBubbleDefault;
            });
          },
          child: FutureBuilder<AmityImageWithSize>(
            future: getImageWithSize(filePath ?? fileUrl, thumbnail),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final Size imageSize = snapshot.data!.size;
                final double aspectRatio = imageSize.width / imageSize.height;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 240,
                      maxHeight: 240,
                    ),
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Stack(
                        children: [
                          snapshot.data!.image,
                          if (shouldShowOverlay || onLongPress)
                            _buildMediaOverlay(),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/Icons/amity_ic_media_message_error.png',
                    package: 'amity_uikit_beta_service',
                    width: 240,
                    height: 240,
                  ),
                );
              }
              return Container(
                height: 240,
                width: 240,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.baseColorShade4,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.8),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Your message wasn’t sent',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              onResend?.call(message);
              Navigator.pop(context);
            },
            child: const Text(
              'Resend',
              style: TextStyle(
                  color: Color(0xff007AFF),
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              deleteMessage(context, true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                  color: Color(0xffFF3B30),
                  fontSize: 17,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                  color: Color(0xff007AFF),
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            )),
      ),
    );
  }

  Future<String?> _showPopupMenu(
      BuildContext context, Offset? offset, AmityMessage message) async {
    final isUser = message.userId == AmityCoreClient.getUserId();

    final screenHeight = MediaQuery.of(context).size.height;

    if (offset != null) {
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
        position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy > screenHeight - 88 ? screenHeight - 88 : offset.dy,
            offset.dx + 1,
            offset.dy),
        items: [
          if (message.syncState == AmityMessageSyncState.SYNCED &&
              (message.data is MessageImageData ||
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
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 12),
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

      if (result == 'copy') {
        if (message.data is MessageTextData) {
          final text = (message.data as MessageTextData).text ?? "";
          context.read<AmityToastBloc>().add(AmityToastShort(
              message: "Copied.",
              icon: AmityToastIcon.success,
              bottomPadding: AmityChatPage.toastBottomPadding));
          Clipboard.setData(ClipboardData(text: text));
        }
      } else if (result == 'delete') {
        deleteMessage(context, false);
      } else if (result == 'save') {
        if (message.data is MessageImageData) {
          saveImage(context);
        } else if (message.data is MessageVideoData) {
          saveVideo(context);
        }
      }
      return result;
    }
    return null;
  }

  Future saveImage(BuildContext context) async {
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

  Future saveVideo(BuildContext context) async {
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

  bool isColorInitialized() {
    try {
      messageColor;
      return true;
    } catch (e) {
      return false;
    }
  }
}
