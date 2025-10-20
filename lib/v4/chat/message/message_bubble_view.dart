import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/bloc/amity_group_chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/components/message_report_component.dart';
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
import 'package:amity_uikit_beta_service/v4/core/ui/animation/bounce_animator.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/expandable_text.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/widgets/message_link_preview_widget.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/image_info_manager.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:amity_uikit_beta_service/v4/utils/message_color.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/utils/processed_text_cache.dart';
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
  void Function(String, {bool isReplied})? onSeeMoreTap;
  void Function(AmityMessage)? onResend;
  void Function(ReplyingMesage)? onReplyMessage;
  void Function(AmityMessage)? onEditMessage;
  final Uint8List? thumbnail;
  final bool isModerator;
  late MessageColor messageColor;
  final int bounceOffset = 50;
  Image? messageImage;
  BounceAnimator? bounceAnimator;
  double bounce;
  bool isGroupChat;

  MessageBubbleView({
    super.key,
    super.pageId,
    required this.message,
    this.channelMember,
    this.onSeeMoreTap,
    this.onResend,
    this.onReplyMessage,
    this.onEditMessage,
    this.thumbnail,
    this.bounceAnimator,
    this.bounce = 0.0,
    this.isGroupChat = false,
    this.isModerator = false,
  }) : super(componentId: "message_bubble");

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
                maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% for the whole container including avatar
              ),
              margin: EdgeInsets.only(
                left: isUser ? 50 : 16,
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
                      if (message.parentId != null &&
                          message.isDeleted == false)
                        _buildParentMessage(message, parentMessage, context),
                      if (!isUser && (isGroupChat && message.parentId == null))
                        Container(
                          margin: EdgeInsets.only(left: isModerator ? 44 : 40, bottom: 4), // 44px for moderator (36px avatar + 8px spacing), 40px for regular (32px avatar + 8px spacing)
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6, // Same as bubble width
                          ),
                          child: Text(
                            message.user?.displayName ?? "",
                            style: AmityTextStyle.captionBold(
                                theme.baseColorShade1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      _buildMessageContent(
                          context, isUser, state, bounceAnimator, bounce),
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

  Widget _buildMessageContent(BuildContext context, bool isUser,
      MessageBubbleState state, BounceAnimator? bounceAnimator, double bounce) {
    if (message.isDeleted ?? false) {
      return _buildDeletedMessage(context, theme, isUser);
    } else {
      if (message.data is MessageTextData) {
        return _buildTextMessageWidget(context, isUser, state);
      } else if (message.data is MessageImageData) {
        return _buildImageMessageWidget(context, isUser, state, bounce);
      } else if (message.data is MessageVideoData) {
        return _buildVideoMessageWidget(context, isUser, thumbnail, state);
      } else if (message.data is MessageCustomData) {
        return _buildCustomMessageWidget(context, isUser, state);
      } else {
        return Container();
      }
    }
  }

  Widget _buildCustomMessageWidget(BuildContext context, bool isUser, MessageBubbleState state) {
    final customData = message.data as MessageCustomData;
    // Convert the custom data to a string representation
    final dataString = customData.rawData;
    
    // Use yellow color for custom messages
    Color initialColor = Colors.yellow;

    return Transform.translate(
      offset: Offset(
          ((bounce * bounceOffset) - bounceOffset) * (isUser ? -1 : 1),
          0), // Bounce effect
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser &&
              message.createdAt != null &&
              message.syncState == AmityMessageSyncState.SYNCED) ...[
            _buildDateWidget(message.createdAt!),
            const SizedBox(width: 8),
          ],
          if (!isUser) ...[
            _buildAvatarWidget(context),
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
          Flexible(
            child: StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  onLongPress: () async {
                    if (message.syncState == AmityMessageSyncState.FAILED) {
                      return;
                    }
                    HapticFeedback.heavyImpact();
                    setState(() {
                      initialColor = Colors.yellow.shade600; // Darker yellow when pressed
                    });
                    final RenderBox? messageBox =
                        context.findRenderObject() as RenderBox?;
                    final Offset? messagePosition =
                        messageBox?.localToGlobal(Offset.zero);
                    double height = messageBox?.size.height ?? 0;
                    double width = messageBox?.size.width ?? 0;
                    if (message.reactionCount != null &&
                        message.reactionCount! > 0) {
                      height += 26;
                    } else {
                      height += 4;
                    }
                    final offset = Offset(
                        isUser
                            ? messagePosition!.dx + width
                            : messagePosition!.dx,
                        messagePosition.dy + height);

                    final reactions = configProvider.getAllMessageReactions();
                    final reactionActionOffset = Offset(
                        isUser
                            ? messagePosition.dx + width - 208
                            : messagePosition.dx,
                        messagePosition.dy - 52);
                    await _showReactionAndMenu(context, offset,
                        reactionActionOffset, message, state, reactions);

                    setState(() {
                      initialColor = Colors.yellow; // Back to yellow when released
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: initialColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dataString.toString(),
                      style: TextStyle(
                        color: Colors.black, // Use black text for better contrast on yellow background
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!isUser && message.createdAt != null) ...[
            const SizedBox(width: 8),
            _buildDateWidget(message.createdAt!),
          ],
        ],
      ),
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
