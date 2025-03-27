part of '../message_bubble_view.dart';

extension VideoMessageWidget on MessageBubbleView {
  Widget _buildVideoMessageWidget(BuildContext context, bool isUser,
      Uint8List? thumbnail, MessageBubbleState state) {
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
                }, state),
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
}
