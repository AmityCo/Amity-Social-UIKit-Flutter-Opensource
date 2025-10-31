part of '../chat_page.dart';

extension ChatPageHelpers on AmityChatPage {
  void _showChatUserActionBottomSheet(
      BuildContext context, ChatPageState state) {
    final chatPageBloc = context.read<ChatPageBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // Provide the bloc to the bottom sheet context
        return BlocProvider.value(
          value: chatPageBloc,
          child: AmityConversationChatUserActionComponent(
            user: state.channelMember!.user!,
            isMute: state.isMute,
            isUserBlocked: state.isUserBlocked,
            onMuteToggleTap: () {
              chatPageBloc.add(const ChatPageEventMuteUnmute());
            },
            onReportUserTap: () {
              final user = state.channelMember!.user!;
              final isFlagging = !user.isFlaggedByMe;
              chatPageBloc.add(ChatPageEventFlagUser(isFlagging: isFlagging));
            },
            onBlockToggleTap: () {
              _handleBlockToggle(context, state);
            },
          ),
        );
      },
    );
  }

  void _handleBlockToggle(BuildContext context, ChatPageState state) {
    final chatPageBloc = context.read<ChatPageBloc>();
    final user = state.channelMember!.user!;
    final isCurrentlyBlocking = state.isUserBlocked;

    if (isCurrentlyBlocking) {
      // Show confirmation dialog for unblocking
      _showUnblockConfirmation(context, user.displayName ?? 'this user', () {
        chatPageBloc.add(const ChatPageEventBlockUser(isUserBlocked: false));
      });
    } else {
      // Show confirmation dialog for blocking
      _showBlockConfirmation(context, user.displayName ?? 'this user', () {
        chatPageBloc.add(const ChatPageEventBlockUser(isUserBlocked: true));
      });
    }
  }

  void _showBlockConfirmation(
      BuildContext context, String displayName, VoidCallback onConfirm) {
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.chat_block_user_title,
      detailText: context.l10n.chat_block_user_description(displayName),
      leftButtonText: context.l10n.general_cancel,
      rightButtonText: context.l10n.user_block,
      leftButtonColor: theme.alertColor,
      onConfirm: onConfirm,
    );
  }

  void _showUnblockConfirmation(
      BuildContext context, String displayName, VoidCallback onConfirm) {
    ConfirmationV4Dialog().show(
      context: context,
      title: context.l10n.chat_unblock_user_title,
      detailText: context.l10n.chat_unblock_user_description(displayName),
      leftButtonText: context.l10n.general_cancel,
      rightButtonText: context.l10n.user_unblock,
      leftButtonColor: theme.alertColor,
      onConfirm: onConfirm,
    );
  }

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
      BuildContext context, ChatPageState state, AmityMessage newMessage) {
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
        child: _buildNewMessageContent(context, state, newMessage),
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
  Widget _buildNewMessageContent(
      BuildContext context, ChatPageState state, AmityMessage message) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _scrollToBottom(state,
                  shouldAnimated: true,
                  millisecBeforeAnimated: (message.data is MessageTextData ||
                          message.data is MessageCustomData)
                      ? 50
                      : 300),
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
                            displayName: message.user?.displayName ??
                                context.l10n.user_profile_unknown_name,
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
                                : message.data is MessageCustomData
                                    ? Text(
                                        (message.data as MessageCustomData)
                                                .rawData
                                                ?.toString() ??
                                            "",
                                        style: AmityTextStyle.body(theme
                                            .secondaryColor
                                            .blend(ColorBlendingOption.shade2)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        message.data is MessageImageData
                                            ? context.l10n.chat_message_photo
                                            : context.l10n.chat_message_video,
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
              child: InkWell(
                  onTap: () => _scrollToBottom(state,
                      shouldAnimated: true,
                      millisecBeforeAnimated:
                          (message.data is MessageTextData ||
                                  message.data is MessageCustomData)
                              ? 50
                              : 300)),
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
  void _scrollToBottom(ChatPageState state,
      {shouldAnimated = false, int millisecBeforeAnimated = 0}) {
    state.scrollController
        .animateTo(
      0.0,
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
