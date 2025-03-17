import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/full_text_message.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/message_bubble_view.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer_action.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityChatPage extends NewBasePage {
  static double toastBottomPadding = 56;

  final String? channelId;
  final String? userId;
  final String? userDisplayName;
  final String? avatarUrl;
  final ScrollController scrollController = ScrollController();

  AmityChatPage(
      {super.key,
      this.channelId,
      this.userId,
      this.userDisplayName,
      this.avatarUrl})
      : super(pageId: 'chat_page');

  @override
  Widget buildPage(BuildContext context) {
    return Stack(
      children: [
        BlocProvider(
          key: Key("${channelId ?? ""}_${userId ?? ""}"),
          create: (context) => ChatPageBloc(channelId, userId, userDisplayName,
              avatarUrl, context.read<AmityToastBloc>()),
          child: BlocBuilder<ChatPageBloc, ChatPageState>(
              key: Key("${channelId ?? ""}_${userId ?? ""}"),
              builder: (context, state) {
                if (state is ChatPageStateInitial) {
                  context.read<AmityToastBloc>().add(AmityToastLoading(
                      message: "Loading chat...",
                      icon: AmityToastIcon.loading,
                      bottomPadding: toastBottomPadding));
                }

                if (!state.isFetching && state is! ChatPageStateInitial) {
                  context.read<AmityToastBloc>().add(AmityToastDismiss());
                }

                scrollController.addListener(() {
                  if ((scrollController.position.pixels >=
                      (scrollController.position.maxScrollExtent))) {
                    context
                        .read<ChatPageBloc>()
                        .add(const ChatPageEventLoadMore());
                  }
                });

                final isLoadingUserAvatar =
                    state.avatarUrl == null && state.userDisplayName == null;

                final List<GlobalKey> itemKeys = List.generate(
                    state.messages.length, (index) => GlobalKey());

                final isScrollable = scrollController.hasClients &&
                    scrollController.position.maxScrollExtent > 0;

                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: -5,
                    surfaceTintColor: theme.backgroundColor,
                    title: Row(
                      children: [
                        if (isLoadingUserAvatar)
                          skeletonHeader()
                        else ...[
                          GestureDetector(
                            onTap: () {
                              final avatarUrl = state.avatarUrl;
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
                            child: AmityUserAvatar.withChannelMember(
                                channelMember: state.channelMember),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.userDisplayName ?? "",
                                  style: TextStyle(
                                    color: theme.baseColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Visibility(
                                  visible: !state.isConnected,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                        ],
                      ],
                    ),
                    actions: [
                      if (!isLoadingUserAvatar) ...[
                        IconButton(
                          icon: SizedBox(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              state.isMute
                                  ? 'assets/Icons/amity_ic_chat_mute.svg'
                                  : 'assets/Icons/amity_ic_chat_unmute.svg',
                              package: 'amity_uikit_beta_service',
                            ),
                          ),
                          color: theme.secondaryColor,
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            context
                                .read<ChatPageBloc>()
                                .add(const ChatPageEventMuteUnmute());
                          },
                        ),
                        const SizedBox(width: 8),
                      ]
                    ],
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
                          visible:
                              state.isFetching && state.messages.isNotEmpty,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            width: 24.0,
                            height: 24.0,
                            child: const CupertinoActivityIndicator(),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(builder: (context, constraints) {
                            return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                              controller: scrollController,
                              reverse: isScrollable,
                              cacheExtent: 1000,
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                ChatItem item;
                                if (isScrollable) {
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
                                      !state.localThumbnails
                                          .containsKey(message.uniqueId)) {
                                    try {
                                      final filePath =
                                          (message.data as MessageVideoData)
                                              .getVideo()
                                              .getFilePath;
                                      if (filePath != null) {
                                        context.read<ChatPageBloc>().add(
                                            ChatPageEventFetchLocalVideoThumbnail(
                                                uniqueId: message.uniqueId!,
                                                videoPath: filePath));
                                      }
                                    } catch (e) {}
                                  } else if (message.data is MessageVideoData &&
                                      message.syncState ==
                                          AmityMessageSyncState.SYNCED &&
                                      !state.localThumbnails
                                          .containsKey(message.uniqueId) &&
                                      (message.data as MessageVideoData)
                                              .thumbnailImageFile ==
                                          null) {
                                    try {
                                      final filePath =
                                          (message.data as MessageVideoData)
                                              .getVideo()
                                              .fileProperties
                                              .fileUrl;
                                      if (filePath != null) {
                                        context.read<ChatPageBloc>().add(
                                            ChatPageEventFetchLocalVideoThumbnail(
                                                uniqueId: message.uniqueId!,
                                                videoPath: filePath));
                                      }
                                    } catch (e) {}
                                  }
                                  return MessageBubbleView(
                                    key: message.uniqueId != null
                                        ? Key(message.uniqueId!)
                                        : itemKeys[index],
                                    pageId: pageId,
                                    message: message,
                                    channelMember: state.channelMember,
                                    onSeeMoreTap: (text) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullTextScreen(
                                            fullText: text,
                                            displayName:
                                                state.userDisplayName ?? "",
                                            theme: theme,
                                          ),
                                        ),
                                      );
                                    },
                                    onResend: (message) {
                                      context.read<ChatPageBloc>().add(
                                          ChatPageEventResendMessage(
                                              message: message));
                                    },
                                    thumbnail: state.localThumbnails[
                                        item.message!.uniqueId],
                                  );
                                } else {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                          horizontal: 8.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          item.date ?? "",
                                          style: TextStyle(
                                              color: theme.baseColorShade1,
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
                        ),
                        AmityMessageComposer(
                          key: UniqueKey(),
                          pageId: pageId,
                          subChannelId: state.channelId,
                          avatarUrl: avatarUrl,
                          action: MessageComposerAction(
                            onDissmiss: () {},
                            onMessageCreated: () {
                              scrollController.animateTo(
                                0.0,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        AmityToast(elementId: "toast"),
      ],
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
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
