part of '../chat_page.dart';

extension ChatPageHelpers on AmityChatPage {
  Widget skeletonHeader() {
    return Shimmer(
      linearGradient: configProvider.getShimmerGradient(),
      child: const SizedBox(
        child: ShimmerLoading(
          isLoading: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonImage(
                height: 40,
                width: 40,
                borderRadius: 40,
              ),
              SizedBox(
                width: 8,
              ),
              SkeletonText(
                width: 140,
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New message notification widget
  Widget _buildNewMessageNotification(
      ChatPageState state, AmityMessage newMessage) {
    return Positioned(
      right: 16,
      left: 16,
      bottom: 8,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.backgroundColor.blend(ColorBlendingOption.shade1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A292B32),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: theme.baseColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: _buildNewMessageContent(state, newMessage),
      ),
    );
  }

  // Scroll button widget
  Widget _buildScrollToLatestButton(ChatPageState state, bool isScrollable) {
    return Positioned(
      right: 16,
      bottom: 6,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.backgroundColor.blend(ColorBlendingOption.shade1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A292B32),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 1,
            ),
          ],
        ),
        child: _buildScrollButtonContent(state),
      ),
    );
  }

  // Helper method for notification content
  Widget _buildNewMessageContent(ChatPageState state, AmityMessage message) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scrollToBottom(state),
              child: Padding(
                padding: const EdgeInsets.only(left: 6, top: 6, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AmityUserAvatar(
                            avatarUrl: message.user?.avatarUrl,
                            displayName: message.user?.displayName ?? 'Unknown',
                            isDeletedUser: false,
                            avatarSize: Size(28, 28),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: message.data is MessageTextData
                                ? Text(
                                    (message.data as MessageTextData).text ??
                                        "",
                                    style: AmityTextStyle.body(theme
                                        .secondaryColor
                                        .blend(ColorBlendingOption.shade2)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    message.data is MessageImageData
                                        ? "Send a photo"
                                        : "Send a video",
                                    style: AmityTextStyle.body(theme
                                        .secondaryColor
                                        .blend(ColorBlendingOption.shade2)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.data is MessageImageData)
                          _buildImagePreview(message.data as MessageImageData),
                        if (message.data is MessageVideoData)
                          _buildVideoPreview(message.data as MessageVideoData),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_down_arrow.svg',
                            package: 'amity_uikit_beta_service',
                            color: theme.secondaryColor
                                .blend(ColorBlendingOption.shade1),
                            width: 10,
                            height: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: theme.secondaryColor.withOpacity(0.05),
              child: InkWell(onTap: () => _scrollToBottom(state)),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for scroll button content
  Widget _buildScrollButtonContent(ChatPageState state) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scrollToBottom(state),
              child: SizedBox(
                height: 40,
                width: 40,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_down_arrow.svg',
                    package: 'amity_uikit_beta_service',
                    color:
                        theme.secondaryColor.blend(ColorBlendingOption.shade1),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.baseColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipOval(
            child: Material(
              color: theme.secondaryColor.withOpacity(0.05),
              child: InkWell(onTap: () => _scrollToBottom(state)),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to scroll to bottom
  void _scrollToBottom(ChatPageState state) {
    state.scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildImagePreview(MessageImageData imageData) {
    final image = imageData.image;
    final fileUrl = image?.getUrl(AmityImageSize.SMALL) ?? "";
    final filePath = image?.getFilePath;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: theme.baseColorShade4,
      ),
      clipBehavior: Clip.antiAlias,
      child: fileUrl.isNotEmpty || filePath != null
          ? Image.network(
              filePath ?? fileUrl,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.baseColorShade4,
                child:
                    Icon(Icons.image, color: theme.baseColorShade2, size: 18),
              ),
            )
          : Container(
              color: theme.baseColorShade4,
              child: Icon(Icons.image, color: theme.baseColorShade2, size: 18),
            ),
    );
  }

  Widget _buildVideoPreview(MessageVideoData videoData) {
    final thumbnail = videoData.thumbnailImageFile;
    final fileUrl = thumbnail?.getUrl(AmityImageSize.SMALL) ?? "";
    final filePath = thumbnail?.getFilePath;

    if (thumbnail == null) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: theme.baseColorShade4,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_video_play_button.svg',
                package: 'amity_uikit_beta_service',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Image.network(
            filePath ?? fileUrl,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: theme.baseColorShade4,
              child: Icon(Icons.video_file,
                  color: theme.baseColorShade2, size: 18),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_video_reply_play.svg',
              package: 'amity_uikit_beta_service',
              width: 16,
              height: 16,
            ),
          )
        ],
      ),
    );
  }
}
