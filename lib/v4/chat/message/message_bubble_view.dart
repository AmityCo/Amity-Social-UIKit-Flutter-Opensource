import 'dart:async';
import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_avatar.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_cubit.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/replying_message.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/core/single_video_player/pager/video_message_player.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/image_info_manager.dart';
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
import 'package:video_thumbnail/video_thumbnail.dart';

part 'widgets/generic_widget.dart';
part 'widgets/image_message_widget.dart';
part 'widgets/message_popup.dart';
part 'widgets/parent_message_widget.dart';
part 'widgets/reaction_preview.dart';
part 'widgets/text_message_widget.dart';
part 'widgets/video_message_widget.dart';

class MessageBubbleView extends NewBaseComponent {
  final AmityMessage message;
  final AmityChannelMember? channelMember;
  void Function(String, { bool isReplied  } )? onSeeMoreTap;
  void Function(AmityMessage)? onResend;
  final Uint8List? thumbnail;
  late MessageColor messageColor;
  Image? messageImage;

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

    return BlocProvider(
      create: (context) => MessageBubbleCubit(message: message),
      child: BlocBuilder<MessageBubbleCubit, MessageBubbleState>(
        builder: (context, state) {
          AmityMessage? parentMessage;
          if (message.parentId != null) {
            final cacheMessage =
                ParentMessageCache().getMessage(message.parentId!);
            if (cacheMessage != null) {
              parentMessage = cacheMessage;
            } else if (state.parentMessage != null) {
              parentMessage = state.parentMessage;
            } else {
              context.read<MessageBubbleCubit>().fetchParentMessage();
            }
          }

          final reactionMap = message.reactions?.reactions;
          List<String?> imagePaths = [];
          bool showReaction = false;
          if (message.reactionCount != null &&
              message.reactionCount! > 0 &&
              message.isDeleted == false) {
            showReaction = true;
          }
          if (reactionMap != null) {
            final sortedEntries = reactionMap.entries.toList()
              ..sort((a, b) {
                if (a.value == b.value) {
                  return a.key.compareTo(b.key);
                }
                return b.value.compareTo(a.value);
              });
            imagePaths =
                sortedEntries.where((entry) => entry.value > 0).map((entry) {
              return configProvider.getReaction(entry.key).imagePath;
            }).toList();
          }
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
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment:
                        message.userId == AmityCoreClient.getUserId()
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      if (message.parentId != null && message.isDeleted == false)
                        _buildParentMessage(message, parentMessage, context),
                      _buildMessageContent(context, isUser, state),
                      // If message have reaction will reserve space for it
                      if (showReaction)
                        const SizedBox(
                          height: 22,
                          width: 300,
                        ),
                    ],
                  ),
                  // Actual reaction bubble will be rendered here
                  if (showReaction)
                    Positioned(
                      bottom: -4,
                      right: isUser ? 0 : null,
                      child: Container(
                        height: 28,
                        padding: isUser
                            ? const EdgeInsets.only(left: 0)
                            : const EdgeInsets.only(left: 40),
                        child: ReactionBubble(
                          reactions: imagePaths,
                          totalReactionCount: message.reactionCount ?? 0,
                          theme: theme,
                          containMyReations:
                              message.myReactions?.isNotEmpty ?? false,
                          onTap: () {
                            showReactionsBottomSheet(context);
                          },
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildMessageContent(
      BuildContext context, bool isUser, MessageBubbleState state) {
    if (message.isDeleted ?? false) {
      return _buildDeletedMessage(context, theme, isUser);
    } else {
      if (message.data is MessageTextData) {
        return _buildTextMessageWidget(context, isUser, state);
      } else if (message.data is MessageImageData) {
        return _buildImageMessageWidget(context, isUser, state);
      } else if (message.data is MessageVideoData) {
        return _buildVideoMessageWidget(context, isUser, thumbnail, state);
      } else {
        return Container();
      }
    }
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

  bool isColorInitialized() {
    try {
      messageColor;
      return true;
    } catch (e) {
      return false;
    }
  }

  void showReactionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (BuildContext context, scrollController) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: AmityReactionList(
                pageId: '',
                referenceId: message.messageId ?? "",
                referenceType: AmityReactionReferenceType.MESSAGE,
              ),
            );
          },
        );
      },
    );
  }
}
