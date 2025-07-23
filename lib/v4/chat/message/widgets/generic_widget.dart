part of '../message_bubble_view.dart';

extension GenericWidget on MessageBubbleView {
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
