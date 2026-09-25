part of '../amity_group_chat_page.dart';

extension GroupChatPageHelpers on AmityGroupChatPage {
  Widget _buildNewMessageNotification(BuildContext context,
      GroupChatPageState state, AmityMessage newMessage) {
    return Positioned(
      right: 16,
      left: 16,
      bottom: 8,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: token(AmityColorToken.surfaceSheetsBackgroundGeneral),
          boxShadow: [
            BoxShadow(
              color: token(AmityColorToken.lineDividerContentDefault),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: token(AmityColorToken.textListHeaderDefaultDefault).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: _buildNewMessageContent(context, state, newMessage),
      ),
    );
  }

  Widget _buildNewMessageContent(BuildContext context,
      GroupChatPageState state, AmityMessage message) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scrollToBottom(state,
                  shouldAnimated: true,
                  millisecBeforeAnimated:
                      (message.data is MessageTextData || message.data is MessageCustomData) ? 50 : 300),
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
                                    style: AmityTextStyle.body(token(AmityColorToken
                                        .textListTextDescriptionDefaultDefault)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : message.data is MessageCustomData
                                    ? Text(
                                        (message.data as MessageCustomData).rawData?.toString() ??
                                            "",
                                        style: AmityTextStyle.body(token(AmityColorToken
                                        .textListTextDescriptionDefaultDefault)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        message.data is MessageImageData
                                            ? context.l10n.chat_message_photo
                                            : context.l10n.chat_message_video,
                                        style: AmityTextStyle.body(token(AmityColorToken
                                        .textListTextDescriptionDefaultDefault)),
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
                            'assets/Icons/amity_ic_chevron_down.svg',
                            package: 'amity_uikit_beta_service',
                            color: token(AmityColorToken.textListSubheadDefaultDefault),
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
              color: token(AmityColorToken.textListHeaderDefaultDefault).withOpacity(0.05),
              child: InkWell(
                  onTap: () => _scrollToBottom(state,
                      shouldAnimated: true,
                      millisecBeforeAnimated:
                          (message.data is MessageTextData || message.data is MessageCustomData) ? 50 : 300)),
            ),
          ),
        ),
      ],
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
          color: token(AmityColorToken.lineDividerContentDefault),
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
              color: token(AmityColorToken.lineDividerContentDefault),
              child: Icon(Icons.video_file,
                  color: token(AmityColorToken.textListSubheadDefaultDefault), size: 18),
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

  Widget _buildImagePreview(MessageImageData imageData) {
    final image = imageData.image;
    final fileUrl = image?.getUrl(AmityImageSize.SMALL) ?? "";
    final filePath = image?.getFilePath;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: token(AmityColorToken.lineDividerContentDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: fileUrl.isNotEmpty || filePath != null
          ? Image.network(
              filePath ?? fileUrl,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: token(AmityColorToken.lineDividerContentDefault),
                child:
                    Icon(Icons.image, color: token(AmityColorToken.textListSubheadDefaultDefault), size: 18),
              ),
            )
          : Container(
              color: token(AmityColorToken.lineDividerContentDefault),
              child: Icon(Icons.image, color: token(AmityColorToken.textListSubheadDefaultDefault), size: 18),
            ),
    );
  }

  Widget _buildScrollToLatestButton(GroupChatPageState state, bool isScrollable) {
    return Positioned(
      right: 16,
      bottom: 6,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Same filled/secondary icon button the 1-1 chat and Android use
          // (AmityButton ICON/FILLED/SECONDARY). This was the sheet background,
          // so the group chat's button was #191919 on a #191919 page — a disc
          // you could only see by its 1px ring (PDT-5046).
          color: token(AmityColorToken.surfaceIconButtonFilledSecondaryEnabled),
          boxShadow: [
            BoxShadow(
              color: token(AmityColorToken.lineDividerContentDefault),
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

  Widget _buildScrollButtonContent(GroupChatPageState state) {
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
                    'assets/Icons/amity_ic_chevron_down.svg',
                    package: 'amity_uikit_beta_service',
                    // Explicit 24: Android pins the 40 icon button to a 24
                    // glyph with an 8 inset, and leaving it unset made the
                    // glyph size an accident of the asset's own viewBox.
                    width: 24,
                    height: 24,
                    color: token(
                        AmityColorToken.iconIconButtonFilledSecondaryDefault),
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
                color: token(AmityColorToken.textListHeaderDefaultDefault).withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipOval(
            child: Material(
              color: token(AmityColorToken.textListHeaderDefaultDefault).withOpacity(0.05),
              child: InkWell(
                onTap: () => _scrollToBottom(state),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // Helper method to scroll to bottom
  void _scrollToBottom(GroupChatPageState state,
      {shouldAnimated = false, int millisecBeforeAnimated = 0}) {
    state.scrollController
        .animateTo(
      state.useReverseUI && state.contentOverflowsScreen ? 0.0 : state.scrollController.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    )
        .then((_) {
      if (shouldAnimated) {
        if (millisecBeforeAnimated > 0) {
          // Delay the bounce animation to allow the media content to load
          // before the animation starts
          Future.delayed(Duration(milliseconds: millisecBeforeAnimated), () {
            bounceLatestMessage?.call();
          });
        } else {
          bounceLatestMessage?.call();
        }
      }
    });
  }
}
