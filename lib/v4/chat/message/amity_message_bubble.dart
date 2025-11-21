import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/replying_message.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/bounce_animator.dart';
import 'package:flutter/material.dart';

/// Message bubble component for displaying chat messages
/// 
/// This is the recommended component for rendering individual chat messages.
/// It supports various message types including text, images, and videos,
/// with features like reactions, replies, and animations.
class AmityMessageBubble extends NewBaseComponent {
  final AmityMessage message;
  final AmityChannelMember? channelMember;
  void Function(String, {bool isReplied})? onSeeMoreTap;
  void Function(AmityMessage)? onResend;
  void Function(ReplyingMesage)? onReplyMessage;
  void Function(AmityMessage)? onEditMessage;
  final Uint8List? thumbnail;
  final bool isModerator;
  BounceAnimator? bounceAnimator;
  double bounce;
  bool isGroupChat;

  AmityMessageBubble({
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
    return MessageBubbleView(
      key: key,
      pageId: pageId,
      message: message,
      channelMember: channelMember,
      onSeeMoreTap: onSeeMoreTap,
      onResend: onResend,
      onReplyMessage: onReplyMessage,
      onEditMessage: onEditMessage,
      thumbnail: thumbnail,
      bounceAnimator: bounceAnimator,
      bounce: bounce,
      isGroupChat: isGroupChat,
      isModerator: isModerator,
    );
  }
}
