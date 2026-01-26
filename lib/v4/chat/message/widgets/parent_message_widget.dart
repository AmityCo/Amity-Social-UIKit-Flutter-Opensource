part of '../message_bubble_view.dart';

extension ParentMessageWidget on MessageBubbleView {
  // Helper method to truncate display names for group chat replies
  String _truncateDisplayName(String displayName, {int maxLength = 10}) {
    if (displayName.length <= maxLength) {
      return displayName;
    }
    return '${displayName.substring(0, maxLength)}...';
  }

  // Helper method to get appropriate reply text based on group chat context
  String _getReplyText(AmityMessage message, AmityMessage parentMessage, BuildContext context) {
    final currentUserId = AmityCoreClient.getUserId();
    final isCurrentUser = message.userId == currentUserId;
    final isParentCurrentUser = parentMessage.userId == currentUserId;

    if (!isGroupChat) {
      // For private chats, use the original logic
      if (isParentCurrentUser) {
        return isCurrentUser ? context.l10n.message_reply_you_to_yourself : context.l10n.message_reply_to_you;
      } else {
        return isCurrentUser ? context.l10n.message_reply_you : context.l10n.message_reply_to_themself;
      }
    } else {
      // For group chats, include display names (truncated)
      final parentUserDisplayName =
          _truncateDisplayName(parentMessage.user?.displayName ?? context.l10n.message_unknown_user);
      final currentUserDisplayName = message.user?.displayName ?? context.l10n.message_unknown_user;

      if (isParentCurrentUser) {
        return isCurrentUser ? context.l10n.message_reply_you_to_yourself : "${_truncateDisplayName(currentUserDisplayName)} ${context.l10n.message_reply_to_you.toLowerCase()}";
      } else {
        if (isCurrentUser) {
          return "${context.l10n.message_reply_you} to $parentUserDisplayName";
        } else {
          if (parentMessage.userId == message.userId) {
            return "${_truncateDisplayName(currentUserDisplayName)} ${context.l10n.message_reply_to_themself.toLowerCase()}";
          } else {
            return "${_truncateDisplayName(currentUserDisplayName)} replied to $parentUserDisplayName";
          }
        }
      }
    }
  }

  Widget _buildParentMessage(
      message, AmityMessage? parentMessage, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: message.userId == AmityCoreClient.getUserId() ? 32 : 40),
      child: Column(
        crossAxisAlignment: message.userId == AmityCoreClient.getUserId()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (parentMessage == null) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: messageColor.leftBubbleDefault,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 60,
                  width: 228,
                ),
                SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        theme.secondaryColor.withAlpha(60)),
                  ),
                ),
              ],
            ),
          ],
          if (parentMessage != null) ...[
            Row(
              mainAxisAlignment: message.userId == AmityCoreClient.getUserId()
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/Icons/amity_ic_reply_message.svg',
                  package: 'amity_uikit_beta_service',
                  width: 16,
                  height: 12,
                  color: theme.baseColorShade1,
                ),
                const SizedBox(
                  width: 4,
                ),
                if (parentMessage.isDeleted ?? false)
                  Text(
                      message.userId == AmityCoreClient.getUserId()
                          ? context.l10n.message_reply_you_to_deleted
                          : context.l10n.message_reply_to_deleted,
                      style: AmityTextStyle.caption(theme.baseColorShade1))
                else
                  Text(_getReplyText(message, parentMessage, context),
                      style: AmityTextStyle.caption(theme.baseColorShade1)),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            GestureDetector(
              onTap: () {
                // TODO Remove this condition when jump to replied message is implemented
                if (parentMessage.data is MessageTextData) {
                  final parentTextMessage =
                      (parentMessage.data as MessageTextData).text ?? "";
                  onSeeMoreTap?.call(parentTextMessage, isReplied: true);
                } else if (parentMessage.data is MessageImageData) {
                  final image = (parentMessage.data as MessageImageData).image;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AmityImageViewer(
                        imageUrl: image?.getUrl(AmityImageSize.LARGE) ?? "",
                        showDeleteButton:
                            message.userId == AmityCoreClient.getUserId(),
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
                } else if (parentMessage.data is MessageVideoData) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoMessagePlayer(
                        message: parentMessage,
                        onDelete: () {
                          deleteMessage(context, true);
                        },
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (parentMessage.isDeleted ?? false) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.baseColorShade4,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/Icons/amity_ic_deleted_message.svg',
                                package: 'amity_uikit_beta_service',
                                width: 16,
                                height: 14,
                                color: theme.baseColorShade2,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                context.l10n.message_deleted,
                                style: AmityTextStyle.caption(
                                    theme.baseColorShade2),
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (parentMessage.data is MessageTextData) {
                          final parentTextMessage =
                              (parentMessage.data as MessageTextData).text ??
                                  "";
                          final elements = linkify(parentTextMessage);

                          final textSpans = elements.map<TextSpan>((element) {
                            if (element is LinkableElement) {
                              return TextSpan(
                                text: element.text,
                                style: TextStyle(
                                  color: theme.highlightColor,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            } else {
                              return TextSpan(
                                text: element.text,
                                style: AmityTextStyle.body(theme.baseColor),
                              );
                            }
                          }).toList();

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: messageColor.leftBubbleDefault,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: textSpans),
                            ),
                          );
                        } else if (parentMessage.data is MessageCustomData) {
                          final parentCustomMessage =
                              (parentMessage.data as MessageCustomData).rawData?.toString() ?? "";
                          final elements = linkify(parentCustomMessage);

                          final textSpans = elements.map<TextSpan>((element) {
                            if (element is LinkableElement) {
                              return TextSpan(
                                text: element.text,
                                style: TextStyle(
                                  color: theme.highlightColor,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            } else {
                              return TextSpan(
                                text: element.text,
                                style: AmityTextStyle.body(theme.baseColor),
                              );
                            }
                          }).toList();

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: messageColor.leftBubbleDefault,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: textSpans),
                            ),
                          );
                        } else if (parentMessage.data is MessageImageData) {
                          final image =
                              (parentMessage.data as MessageImageData).image;
                          final fileUrl =
                              image?.getUrl(AmityImageSize.MEDIUM) ?? "";
                          final filePath = image?.getFilePath;
                          return FutureBuilder<AmityImageWithSize>(
                            future: getImageWithSize(filePath ?? fileUrl, null),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final Size imageSize = snapshot.data!.size;
                                double thumbnailHeight = 40;
                                double thumbnailWidth = 40;

                                if (imageSize.height >= imageSize.width) {
                                  thumbnailHeight = 120;

                                  double imageRatio =
                                      imageSize.height / imageSize.width;

                                  if (imageRatio > 3) {
                                    thumbnailWidth = 40;
                                  } else {
                                    thumbnailWidth = 120 / imageRatio;
                                  }
                                } else {
                                  thumbnailWidth = 120;
                                  double imageRatio =
                                      imageSize.width / imageSize.height;

                                  if (imageRatio > 3) {
                                    thumbnailHeight = 40;
                                  } else {
                                    thumbnailHeight = 120 / imageRatio;
                                  }
                                }

                                if (!ImageInfoManager()
                                    .contains("${fileUrl}_reply")) {
                                  ImageInfoManager().addImageData(
                                      "${fileUrl}_reply",
                                      thumbnailHeight,
                                      thumbnailWidth);
                                }

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: thumbnailWidth,
                                      maxHeight: thumbnailHeight,
                                    ),
                                    child: Stack(
                                      children: [
                                        snapshot.data!.image,
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    'assets/Icons/amity_ic_media_message_error.png',
                                    package: 'amity_uikit_beta_service',
                                    width: 120,
                                    height: 120,
                                  ),
                                );
                              }
                              return Container(
                                height: ImageInfoManager()
                                        .messageImageCaches["${fileUrl}_reply"]
                                        ?.height ??
                                    60,
                                width: ImageInfoManager()
                                        .messageImageCaches["${fileUrl}_reply"]
                                        ?.width ??
                                    228,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.baseColorShade4,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                              );
                            },
                          );
                        } else if (parentMessage.data is MessageVideoData) {
                          final image = (parentMessage.data as MessageVideoData)
                              .thumbnailImageFile;
                          final fileUrl =
                              image?.getUrl(AmityImageSize.MEDIUM) ?? "";
                          final filePath = image?.getFilePath;
                          final cacheKey = "${fileUrl}_reply";

                          if (image == null) {
                            return FutureBuilder<Uint8List?>(
                              future: FlutterVideoThumbnail.getThumbnail(
                                (parentMessage.data as MessageVideoData)
                                        .fileInfo
                                        .fileUrl ??
                                    "",
                                quality: 75,
                                useCache: true,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return buildPlaceholderWidget(
                                      cacheKey, theme);
                                return FutureBuilder<AmityImageWithSize>(
                                  future: getImageWithSize(null, snapshot.data),
                                  builder: (context, innerSnapshot) {
                                    if (innerSnapshot.hasData) {
                                      return buildThumbnailWidget(
                                          innerSnapshot.data!, cacheKey);
                                    } else if (innerSnapshot.hasError) {
                                      return buildErrorWidget();
                                    }
                                    return buildPlaceholderWidget(
                                        cacheKey, theme);
                                  },
                                );
                              },
                            );
                          } else {
                            return FutureBuilder<AmityImageWithSize>(
                              future: getImageWithSize(
                                  filePath ?? fileUrl, thumbnail),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return buildThumbnailWidget(
                                      snapshot.data!, cacheKey);
                                } else if (snapshot.hasError) {
                                  return buildErrorWidget();
                                }
                                return buildPlaceholderWidget(cacheKey, theme);
                              },
                            );
                          }
                        } else {
                          return Container();
                        }
                      }
                    },
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((255.0 * 0.6).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(
            height: 4,
          ),
        ],
      ),
    );
  }

// Extracted helper to calculate thumbnail size
  Size calculateThumbnailSize(Size imageSize) {
    double thumbnailHeight, thumbnailWidth;
    if (imageSize.height >= imageSize.width) {
      thumbnailHeight = 120;
      final ratio = imageSize.height / imageSize.width;
      thumbnailWidth = ratio > 3 ? 40 : 120 / ratio;
    } else {
      thumbnailWidth = 120;
      final ratio = imageSize.width / imageSize.height;
      thumbnailHeight = ratio > 3 ? 40 : 120 / ratio;
    }
    return Size(thumbnailWidth, thumbnailHeight);
  }

// Helper to build the video thumbnail widget
  Widget buildThumbnailWidget(AmityImageWithSize imageData, String cacheKey) {
    final thumbSize = calculateThumbnailSize(imageData.size);
    if (!ImageInfoManager().contains(cacheKey)) {
      ImageInfoManager()
          .addImageData(cacheKey, thumbSize.height, thumbSize.width);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: thumbSize.width,
          maxHeight: thumbSize.height,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageData.image,
            SizedBox(
              width: 40,
              height: 40,
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_video_play_button.svg',
                package: 'amity_uikit_beta_service',
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper for the error widget
  Widget buildErrorWidget() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/Icons/amity_ic_media_message_error.png',
        package: 'amity_uikit_beta_service',
        width: 120,
        height: 120,
      ),
    );
  }

// Helper for the placeholder widget
  Widget buildPlaceholderWidget(String cacheKey, AmityThemeColor theme) {
    final cache = ImageInfoManager().messageImageCaches[cacheKey];
    return Container(
      height: cache?.height ?? 60,
      width: cache?.width ?? 228,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.baseColorShade4,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }
}
