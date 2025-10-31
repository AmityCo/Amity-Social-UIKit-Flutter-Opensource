import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/full_text_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/bloc/amity_group_chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_setting/amity_group_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/channel_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/bounce_animator.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/animation/simple_ticker_provider.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'widgets/group_chat_page_helpers.dart';

// Page for showing group chat messages
// ignore: must_be_immutable
class AmityGroupChatPage extends NewBasePage {
  static double toastBottomPadding = 56;

  final String channelId;
  final String? jumpToMessageId;
  BounceAnimator? bounceAnimator;
  Function? bounceLatestMessage;
  final bool isJustCreated;

  AmityGroupChatPage({
    super.key,
    required this.channelId,
    this.jumpToMessageId,
    this.isJustCreated = false,
  }) : super(pageId: 'group_chat_page');

  @override
  Widget buildPage(BuildContext context) {
    MessageComposerCache().updateText("");

    VisibilityDetectorController.instance.updateInterval =
        const Duration(milliseconds: 50);

    return SimpleTickerProvider(
      onInit: (vsync) {
        bounceAnimator = BounceAnimator(vsync);
        bounceLatestMessage = () {
          bounceAnimator?.animateItem(0);
        };
      },
      child: Stack(
        children: [
          BlocProvider(
            key: Key("$channelId"),
            create: (context) => AmityGroupChatPageBloc(
                channelId, context.read<AmityToastBloc>(),
                jumpToMessageId: jumpToMessageId),
            child: BlocListener<AmityGroupChatPageBloc, GroupChatPageState>(
              listener: (context, state) {
                // Listen for bounceTargetIndex changes and trigger bounce animation
                if (state.bounceTargetIndex != null && bounceAnimator != null) {
                  bounceAnimator!.animateItem(state.bounceTargetIndex!);
                }
              },
              child: BlocBuilder<AmityGroupChatPageBloc, GroupChatPageState>(
                key: Key("$channelId"),
                builder: (context, state) {
                  if (state is GroupChatPageStateInitial && !isJustCreated) {
                    context.read<AmityToastBloc>().add(AmityToastLoading(
                        message: "Loading chat...",
                        icon: AmityToastIcon.loading,
                        bottomPadding: toastBottomPadding));
                  }
                  if (!state.isFetching &&
                      state is! GroupChatPageStateInitial) {
                    context
                        .read<AmityToastBloc>()
                        .add(AmityToastDismissIfLoading());
                    _handleToastDismissal(context, state);
                  }

                  final List<GlobalKey> itemKeys = List.generate(
                      state.messages.length, (index) => GlobalKey());

                  final isScrollable = state.scrollController.hasClients &&
                      state.scrollController.position.maxScrollExtent > 0;

                  final newMessage = state.newMessage;
                  return Scaffold(
                    appBar: AppBar(
                      titleSpacing: -5,
                      surfaceTintColor: theme.backgroundColor,
                      leading: IconButton(
                        icon: SvgPicture.asset(
                          "assets/Icons/amity_ic_back_button.svg",
                          package: 'amity_uikit_beta_service',
                          color: theme.secondaryColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      title: GestureDetector(
                        onTap: () async {
                          final channel = state.channel;
                          if (channel != null) {
                            final updatedChannel = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AmityGroupSettingPage(
                                  channel: channel,
                                  isModerator: state.isModerator,
                                ),
                              ),
                            );

                            if (updatedChannel is AmityChannel) {
                              context.read<AmityGroupChatPageBloc>().add(
                                  GroupChatPageHeaderEventChanged(
                                      channel: updatedChannel));
                            }
                          }
                        },
                        child: Row(
                          children: [
                            AmityChannelAvatar.withChannel(
                              channel: state.channel,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(state.channelDisplayName ?? "",
                                      style: AmityTextStyle.titleBold(
                                          theme.baseColor)),
                                  Visibility(
                                    visible: !state.isConnected,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const CupertinoActivityIndicator(
                                          radius: 8,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Waiting for network...",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.baseColorShade1,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      backgroundColor: theme.backgroundColor,
                      elevation: 0,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(0),
                        child: Container(
                          height: 1,
                          color: theme.baseColorShade4,
                        ),
                      ),
                    ),
                    body: Container(
                      color: theme.backgroundColor,
                      child: Column(
                        children: [
                          Visibility(
                            visible: state.isLoadingMore &&
                                state.messages.isNotEmpty && state.useReverseUI,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              width: 24.0,
                              height: 24.0,
                              child: const CupertinoActivityIndicator(),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                LayoutBuilder(builder: (context, constraints) {
                                  final firstItem = state.messages.isNotEmpty
                                      ? state.messages.first.message
                                      : null;
                                  if (firstItem != null) {
                                    context.read<AmityGroupChatPageBloc>().add(
                                        GroupChatPageEventMarkReadMessage(
                                            message: firstItem));
                                  }

                                  final shouldUseReverse =
                                      state.useReverseUI && state.messages.isNotEmpty &&
                                          state.scrollController.hasClients &&
                                          state.scrollController.position
                                                  .maxScrollExtent >
                                              0;
                                  return ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    controller: state.scrollController,
                                    reverse: shouldUseReverse,
                                    cacheExtent: 1000,
                                    itemCount: state.messages.length,
                                    itemBuilder: (context, index) {
                                      ChatItem item;
                                      if (shouldUseReverse) {
                                        item = state.messages[index];
                                      } else {
                                        final messageIndex =
                                            state.messages.length - 1 - index;
                                        item = state.messages[messageIndex];
                                      }
                                      final message = item.message;
                                      if (message != null) {
                                        if (message.data is MessageVideoData &&
                                            message.syncState !=
                                                AmityMessageSyncState.SYNCED &&
                                            !state.localThumbnails.containsKey(
                                                message.uniqueId)) {
                                          try {
                                            final filePath = (message.data
                                                    as MessageVideoData)
                                                .getVideo()
                                                .getFilePath;
                                            if (filePath != null) {
                                              context
                                                  .read<
                                                      AmityGroupChatPageBloc>()
                                                  .add(
                                                      GroupChatPageEventFetchLocalVideoThumbnail(
                                                          uniqueId:
                                                              message.uniqueId!,
                                                          videoPath: filePath));
                                            }
                                          } catch (e) {}
                                        } else if (message.data
                                                is MessageVideoData &&
                                            message.syncState ==
                                                AmityMessageSyncState.SYNCED &&
                                            !state.localThumbnails.containsKey(
                                                message.uniqueId) &&
                                            (message.data as MessageVideoData)
                                                    .thumbnailImageFile ==
                                                null) {
                                          try {
                                            final filePath = (message.data
                                                    as MessageVideoData)
                                                .getVideo()
                                                .fileProperties
                                                .fileUrl;
                                            if (filePath != null) {
                                              context
                                                  .read<
                                                      AmityGroupChatPageBloc>()
                                                  .add(
                                                      GroupChatPageEventFetchLocalVideoThumbnail(
                                                          uniqueId:
                                                              message.uniqueId!,
                                                          videoPath: filePath));
                                            }
                                          } catch (e) {}
                                        }
                                        return _buildMessageWithAnimation(
                                            context, message, index, state, itemKeys);
                                      } else {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 4.0,
                                                horizontal: 8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4.0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                item.date ?? "",
                                                style: TextStyle(
                                                    color:
                                                        theme.baseColorShade1,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }),
                                if (newMessage != null)
                                  _buildNewMessageNotification(
                                      context, state, newMessage),
                                if (state.showScrollButton &&
                                    isScrollable &&
                                    newMessage == null)
                                  _buildScrollToLatestButton(
                                      state, isScrollable)
                              ],
                            ),
                          ),
                          _buildMessageComposer(context, state),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context, GroupChatPageState state) {
    // Check if the channel is available
    if (state.channel == null) return const SizedBox();

    final currentUserId = AmityCoreClient.getUserId();
    final isUserMuted = state.mutedUsers[currentUserId] ?? false;
    final isMuted = state.channel!.isMuted ?? false;
    final isChannelModerator = state.isModerator;
    bool shouldShowMessageComposer;

    if (isUserMuted) {
      // If user is muted, they cannot send messages regardless of other conditions
      shouldShowMessageComposer = false;
    } else if (isMuted) {
      // If channel is muted but user is not, check if they are a moderator
      if (isChannelModerator) {
        shouldShowMessageComposer = true;
      } else {
        shouldShowMessageComposer = false;
      }
    } else {
      shouldShowMessageComposer = true;
    }

    if (shouldShowMessageComposer) {
      return AmityMessageComposer(
        key: Key('${state.channelId}'),
        pageId: pageId,
        replyingMessage: state.replyingMessage,
        editingMessage: state.editingMessage,
        subChannelId: state.channelId,
        avatarUrl: null,
        action: MessageComposerAction(
          onDissmiss: () {
            context
                .read<AmityGroupChatPageBloc>()
                .add(const GroupChatPageRemoveReplyEvent());
          },
          onMessageCreated: () {
            context
                .read<AmityGroupChatPageBloc>()
                .add(const GroupChatPageRemoveReplyEvent());
            state.scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          },
        ),
        enableMention: true,
      );
    } else {
      // Show appropriate message based on whether the user is muted
      final message = isUserMuted
          ? "You've been muted. You won't be able to send messages."
          : "Members that are not moderators can read but not send any messages.";

      return SafeArea(
        bottom: true,
        child: Container(
          padding:
              const EdgeInsets.only(bottom: 12, top: 12, left: 16, right: 16),
          decoration: BoxDecoration(
            color: theme.backgroundShade1Color,
          ),
          child: Center(
            child: Text(
              message,
              style: AmityTextStyle.caption(theme.baseColorShade1),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  void _handleMessageVisibility(BuildContext context, GroupChatPageState state,
      AmityMessage message, int index, double visiblePercentage) {
    if (visiblePercentage >= 90) {
      final shouldUseReverse = state.useReverseUI && state.messages.isNotEmpty &&
          state.scrollController.hasClients &&
          state.scrollController.position.maxScrollExtent > 0;
          
      if (state.isLoadingToastDismissed) {
        // Stop any ongoing scrolling animation when the target message is found
        if (state.scrollController.hasClients) {
          state.scrollController.animateTo(
            state.scrollController.offset,
            duration: Duration.zero,
            curve: Curves.linear,
          );
        }
        
        context
            .read<AmityGroupChatPageBloc>()
            .add(GroupChatPageTriggerBounceEvent(targetIndex: index));
        context
            .read<AmityGroupChatPageBloc>()
            .add(const GroupChatPageSetAroundMessage(aroundMessageId: null));
        context.read<AmityGroupChatPageBloc>().add(
            const GroupChatPageSetShouldBounceMessage(shouldBounce: false));
      } else {
        // Store shouldUseReverse value for later use when bounce is triggered
        context.read<AmityGroupChatPageBloc>().add(
            GroupChatPageSetShouldUseReverse(shouldUseReverse: shouldUseReverse));
        context.read<AmityGroupChatPageBloc>().add(
            GroupChatPageSetShouldBounceMessage(
                shouldBounce: true, messageIndex: index));
      }
    } else if (visiblePercentage < 5) {
      context.read<AmityGroupChatPageBloc>().add(
          const GroupChatPageSetShouldBounceMessage(shouldBounce: false, messageIndex: null));
      context
          .read<AmityGroupChatPageBloc>()
          .add(const GroupChatPageClearBounceEvent());
    }
  }

  void _handleToastDismissal(BuildContext context, GroupChatPageState state) {
    if (!state.isLoadingToastDismissed) {
      if (state.shouldBounceMessage && state.bounceMessageIndex != null) {
        final shouldUseReverse =
                                      state.shouldUseReverse == (state.useReverseUI && state.messages.isNotEmpty &&
                                          state.scrollController.hasClients &&
                                          state.scrollController.position
                                                  .maxScrollExtent >
                                              0);
        final targetIndex = shouldUseReverse 
            ? state.bounceMessageIndex! 
            : (state.messages.length - 1 - state.bounceMessageIndex!);
                    
        // If we have a pending bounce, trigger it immediately
        context.read<AmityGroupChatPageBloc>().add(
            GroupChatPageTriggerBounceEvent(targetIndex: targetIndex));
        context
            .read<AmityGroupChatPageBloc>()
            .add(const GroupChatPageSetAroundMessage(aroundMessageId: null));
        context.read<AmityGroupChatPageBloc>().add(
            const GroupChatPageSetShouldBounceMessage(shouldBounce: false));
      } else {
        context.read<AmityGroupChatPageBloc>().add(
            const GroupChatPageSetLoadingToastDismissed(isDismissed: true));
      }
    }
  }

  Widget _buildMessageWithAnimation(BuildContext context, AmityMessage message, int index,
      GroupChatPageState state, List<GlobalKey> itemKeys) {
    if (bounceAnimator == null) {
      final isModerator = message.user?.userId != null &&
          state.memberRoles[message.user!.userId]
                  ?.any((role) => role.contains('channel-moderator')) ==
              true;
      return VisibilityDetector(
        key: Key('group_message_${message.uniqueId ?? index}'),
        onVisibilityChanged: (VisibilityInfo info) {
          if (state.aroundMessageId != null &&
              message.messageId == state.aroundMessageId) {
            final visiblePercentage = info.visibleFraction * 100;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleMessageVisibility(
                  context, state, message, index, visiblePercentage);
            });
          }
        },
        child: MessageBubbleView(
          key: message.uniqueId != null
              ? Key(message.uniqueId!)
              : itemKeys[index],
          pageId: pageId,
          isGroupChat: true,
          message: message,
          isModerator: isModerator,
          bounceAnimator: null,
          bounce: 1.0,
          onSeeMoreTap: (text, {isReplied = false}) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullTextScreen(
                  fullText: text,
                  displayName: (!isReplied)
                      ? message.user?.displayName ?? ""
                      : "Replied message",
                  theme: theme,
                ),
              ),
            );
          },
          onResend: (message) {
            context
                .read<AmityGroupChatPageBloc>()
                .add(GroupChatPageEventResendMessage(message: message));
          },
          onReplyMessage: (replyingMessage) {
            context
                .read<AmityGroupChatPageBloc>()
                .add(GroupChatPageReplyEvent(message: replyingMessage));
          },
          onEditMessage: (message) {
            context
                .read<AmityGroupChatPageBloc>()
                .add(GroupChatPageEditEvent(message: message));
          },
          thumbnail: state.localThumbnails[message.uniqueId],
        ),
      );
    }
    return ValueListenableBuilder<int?>(
      valueListenable: bounceAnimator!.animatedIndex,
      builder: (context, animatedIndex, _) {
        return AnimatedBuilder(
          animation: bounceAnimator!.animation,
          builder: (context, _) {
            final bounce = (animatedIndex == index)
                ? (1.0 + (0.1 * bounceAnimator!.animation.value))
                : 1.0;
            final isModerator = message.user?.userId != null &&
                state.memberRoles[message.user!.userId]
                        ?.any((role) => role.contains('channel-moderator')) ==
                    true;

            return VisibilityDetector(
              key: Key('group_message_${message.uniqueId ?? index}'),
              onVisibilityChanged: (VisibilityInfo info) {
                // Only process visibility if loading toast has been dismissed and message is visible on screen
                if (state.aroundMessageId != null &&
                    message.messageId == state.aroundMessageId) {
                  final visiblePercentage = info.visibleFraction * 100;
                  // Use immediate callback to ensure fast detection during rapid scrolling
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleMessageVisibility(
                        context, state, message, index, visiblePercentage);
                  });
                }
              },
              child: MessageBubbleView(
                key: message.uniqueId != null
                    ? Key(message.uniqueId!)
                    : itemKeys[index],
                pageId: pageId,
                isGroupChat: true,
                message: message,
                isModerator: isModerator,
                bounceAnimator: bounceAnimator,
                bounce: bounce,
                onSeeMoreTap: (text, {isReplied = false}) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullTextScreen(
                        fullText: text,
                        displayName: (!isReplied)
                            ? message.user?.displayName ?? ""
                            : "Replied message",
                        theme: theme,
                      ),
                    ),
                  );
                },
                onResend: (message) {
                  context
                      .read<AmityGroupChatPageBloc>()
                      .add(GroupChatPageEventResendMessage(message: message));
                },
                onReplyMessage: (replyingMessage) {
                  context
                      .read<AmityGroupChatPageBloc>()
                      .add(GroupChatPageReplyEvent(message: replyingMessage));
                },
                onEditMessage: (message) {
                  context
                      .read<AmityGroupChatPageBloc>()
                      .add(GroupChatPageEditEvent(message: message));
                },
                thumbnail: state.localThumbnails[message.uniqueId],
              ),
            );
          },
        );
      },
    );
  }
}
