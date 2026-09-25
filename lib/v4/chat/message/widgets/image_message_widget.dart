part of '../message_bubble_view.dart';

extension ImageMessageWidget on MessageBubbleView {
  Widget _buildImageMessageWidget(BuildContext context, bool isUser,
      MessageBubbleState state, double bounce) {
    final image = (message.data as MessageImageData).image;
    final fileUrl = image?.getUrl(AmityImageSize.MEDIUM) ?? "";
    final filePath = image?.getFilePath;
    return Transform.translate(
      offset: Offset(
          ((bounce * bounceOffset) - bounceOffset) * (isUser ? -1 : 1),
          0), // Bounce effect
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            (message.syncState == AmityMessageSyncState.FAILED)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.end,
        children: [
          if (isUser &&
              message.createdAt != null &&
              message.syncState == AmityMessageSyncState.SYNCED) ...[
            _buildDateWidget(context, message.createdAt!),
            const SizedBox(width: 8),
          ],
          if (isUser &&
              message.syncState != AmityMessageSyncState.SYNCED &&
              message.syncState != AmityMessageSyncState.FAILED) ...[
            _buildSideTextWidget(context, context.l10n.message_sending),
            const SizedBox(width: 8),
          ],
          if (!isUser) ...[
            _buildAvatarWidget(context),
            const SizedBox(width: 8),
          ],
          if (message.syncState == AmityMessageSyncState.FAILED &&
              isUser) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    _showActionSheet(context);
                  },
                  child: const AmityMessageErrorBadge(),
                ),
              ),
            ),
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
                          message.syncState != AmityMessageSyncState.FAILED,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AmityImageViewer(
                          imageUrl:
                              image?.getUrl(AmityImageSize.LARGE) ?? "",
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
                  }, state),
                  if (message.syncState ==
                      AmityMessageSyncState.FAILED) ...[
                    const SizedBox(height: 4),
                    _buildFailToSendText(context),
                  ],
                ],
              ),
              if (message.syncState != AmityMessageSyncState.SYNCED &&
                  message.syncState != AmityMessageSyncState.FAILED)
                _buildUploadingIndicator(context),
              if (message.syncState == AmityMessageSyncState.UPLOADING)
                _buildCancelDownloadButton(),
            ],
          ),
          if (!isUser && message.createdAt != null) ...[
            const SizedBox(width: 8),
            _buildDateWidget(context, message.createdAt!),
          ],
        ],
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
      MessageBubbleState state) {
    Color initialColor = isUser
        ? messageColor.rightBubbleDefault
        : messageColor.leftBubbleDefault;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
          },
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
            if (message.reactionCount != null && message.reactionCount! > 0) {
              height += 26;
            } else {
              height += 4;
            }
            final offset = Offset(
                isUser ? messagePosition!.dx + width : messagePosition!.dx,
                messagePosition.dy + height);

            final reactionActionOffset = Offset(
                isUser ? messagePosition.dx + width - 208 : messagePosition.dx,
                messagePosition.dy - 52);

            final reactions = configProvider.getAllMessageReactions();

            await _showReactionAndMenu(context, offset, reactionActionOffset,
                message, state, reactions);

            setState(() {
              initialColor = isUser
                  ? messageColor.rightBubbleDefault
                  : messageColor.leftBubbleDefault;
            });
          },
          child: FutureBuilder<AmityImageWithSize>(
            future: getImageWithSize(filePath ?? fileUrl, thumbnail),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                messageImage = snapshot.data!.image;

                final Size imageSize = snapshot.data!.size;
                double thumbnailHeight = 50;
                double thumbnailWidth = 50;

                if (imageSize.height >= imageSize.width) {
                  thumbnailHeight = 240;

                  double imageRatio = imageSize.height / imageSize.width;

                  if (imageRatio > 3) {
                    thumbnailWidth = 80;
                  } else {
                    thumbnailWidth = 240 / imageRatio;
                  }
                } else {
                  thumbnailWidth = 240;
                  double imageRatio = imageSize.width / imageSize.height;

                  if (imageRatio > 3) {
                    thumbnailHeight = 80;
                  } else {
                    thumbnailHeight = 240 / imageRatio;
                  }
                }

                if (filePath != null &&
                    !ImageInfoManager().contains(filePath)) {
                  ImageInfoManager()
                      .addImageData(filePath, thumbnailHeight, thumbnailWidth);
                } else if (fileUrl != null &&
                    !ImageInfoManager().contains(fileUrl)) {
                  ImageInfoManager()
                      .addImageData(fileUrl, thumbnailHeight, thumbnailWidth);
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
              // Special case when it transition from local to remote
              // If the image is already cached, use the cached image first
              if (filePath != null && ImageInfoManager().contains(filePath)) {
                final height =
                    ImageInfoManager().messageImageCaches[filePath]?.height;
                final width =
                    ImageInfoManager().messageImageCaches[filePath]?.width;
                final locaImage = Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  width: width,
                  height: height,
                );
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width ?? 240,
                      maxHeight: height ?? 240,
                    ),
                    child: Stack(
                      children: [
                        locaImage,
                      ],
                    ),
                  ),
                );
              }
              return Container(
                height: ImageInfoManager()
                        .messageImageCaches[filePath ?? fileUrl]
                        ?.height ??
                    240,
                width: ImageInfoManager()
                        .messageImageCaches[filePath ?? fileUrl]
                        ?.width ??
                    240,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.amityToken(AmityColorToken.lineDividerContentDefault),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: context.amityToken(
                        AmityColorToken.iconLoadersUploadControllerDefault),
                    backgroundColor: context.amityToken(
                            AmityColorToken.iconLoadersUploadControllerDefault)
                        .withOpacity(0.8),
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
}
