part of '../message_bubble_view.dart';

extension GenericWidget on MessageBubbleView {
  Widget _buildFailToSendText(BuildContext context) {
    return Text(
      context.l10n.message_failed_to_send,
      style: TextStyle(
        color: context
            .amityToken(AmityColorToken.textChatBubbleOutboundHelperTextDefault),
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    );
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
                color: token(isUser
                    ? AmityColorToken.iconChatBubbleOutboundMessagesDeleted
                    : AmityColorToken.iconChatBubbleInboundMessagesDeleted),
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                context.l10n.message_deleted,
                style: TextStyle(
                  color: token(isUser
                      ? AmityColorToken.textChatBubbleOutboundMessagesDeleted
                      : AmityColorToken.textChatBubbleInboundMessagesDeleted),
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

  Widget _buildDateWidget(BuildContext context, DateTime timestamp) {
    return _buildSideTextWidget(context, _formatTime(message.createdAt!));
  }

  Widget _buildSideTextWidget(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AmityTextStyle.caption(
            context.amityToken(AmityColorToken.textTimestampDefault)),
      ),
    );
  }

  Widget _buildAvatarWidget(BuildContext context) {
    final avatarUrl = message.user?.avatarUrl;
    final userId = message.user?.userId;
    return GestureDetector(
      onTap: () {
        AmityUIKit4Manager.behavior.messageBubbleBehavior.onAvatarTap(
          context,
          avatarUrl,
          userId,
        );
      },
      child: SizedBox(        
        child: AmityMessageAvatar(
          message: message,
          isModerator: isModerator,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.toLocal().hour}:${timestamp.toLocal().minute.toString().padLeft(2, '0')}";
  }

  Widget _buildUploadingIndicator(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: CircularProgressIndicator(
        color: context.amityToken(AmityColorToken.iconLoadersUploadControllerDefault),
        backgroundColor:
            context.amityToken(AmityColorToken.iconLoadersUploadControllerDefault)
                .withOpacity(0.8),
        strokeWidth: 2,
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
  
}
