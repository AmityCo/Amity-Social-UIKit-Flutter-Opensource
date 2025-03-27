import 'dart:async';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/replying_message.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'chat_page_events.dart';
part 'chat_page_state.dart';

class ChatPageBloc extends Bloc<ChatPageEvent, ChatPageState> {
  var messagesCount = 0;
  MessageLiveCollection? liveCollection;

  late final StreamSubscription<List<ConnectivityResult>> subscription;
  late ScrollController _scrollController;
  bool _isScrollListenerAdded = false;

  final AmityToastBloc toastBloc;

  ChatPageBloc(String? channelId, String? userId, String? userDisplayName,
      String? avatarUrl, this.toastBloc)
      : super(ChatPageStateInitial(
            channelId: channelId ?? "",
            userDisplayName: userDisplayName,
            avatarUrl: avatarUrl,
            scrollController: ScrollController())) {
    _scrollController = state.scrollController;
    _setupScrollListener();

    on<ChatPageEventRefresh>((event, emit) async {
      emit(ChatPageStateChanged(
          channelId: state.channelId,
          messages: const [],
          isFetching: true,
          hasNextPage: true,
          scrollController: state.scrollController));
      try {
        liveCollection?.reset();
        liveCollection?.loadNext();
      } catch (e) {
        emit(ChatPageStateChanged(
            channelId: state.channelId,
            messages: const [],
            isFetching: false,
            hasNextPage: false,
            scrollController: state.scrollController));
      }
    });

    on<ChatPageHeaderEventChanged>((event, emit) async {
      emit(state.copyWith(
        avatarUrl: event.channelMember.user?.avatarUrl,
        userDisplayName: event.channelMember.user?.displayName,
        channelMember: event.channelMember,
        hasNextPage: liveCollection?.hasNextPage(),
      ));
    });

    on<ChatPageEventFetchMuteState>((event, emit) async {
      AmityCoreClient()
          .notifications()
          .channel(state.channelId)
          .getSettings()
          .then((value) => {
                addEvent(ChatPageIsMuteEventChanged(
                    isMute: !(value.isEnabled ?? true))),
              });
    });

    on<ChatPageEventMuteUnmute>((event, emit) async {
      if (state.isMute) {
        emit(state.copyWith(isMute: false, isOnMuteChange: true));
        try {
          await AmityCoreClient()
              .notifications()
              .channel(state.channelId)
              .enable();
          addEvent(const ChatPageIsMuteEventChanged(isMute: false));
        } catch (error) {
          emit(state.copyWith(isMute: true, isOnMuteChange: false));
          toastBloc.add(
              const AmityToastShort(message: "Failed to unmute the channel."));
        }
      } else {
        emit(state.copyWith(isMute: true, isOnMuteChange: true));
        try {
          await AmityCoreClient()
              .notifications()
              .channel(state.channelId)
              .disable();
          addEvent(const ChatPageIsMuteEventChanged(isMute: true));
        } catch (error) {
          emit(state.copyWith(isMute: true, isOnMuteChange: false));
          toastBloc.add(
              const AmityToastShort(message: "Failed to mute the channel."));
        }
      }
    });

    on<ChatPageEventChanged>((event, emit) async {
      AmityMessage? newMessage;
      if (event.messages.isNotEmpty && state.messages.isNotEmpty) {
        final firstEventMessage = event.messages.first;
        final firstStateMessage = state.messages.first.message;

        final eventSegment = firstEventMessage.channelSegment;
        final stateSegment = firstStateMessage?.channelSegment;

        if ((eventSegment != null &&
                stateSegment != null &&
                eventSegment > stateSegment &&
                state.showScrollButton) ||
            firstEventMessage.messageId == state.newMessage?.messageId) {
          newMessage = firstEventMessage;
        }
      }
      messagesCount = event.messages.length;

      List<ChatItem> groupedMessages = [];
      DateTime? lastCreatedDate;
      for (var message in event.messages) {
        ParentMessageCache().updateMessageIfExists(message.messageId!, message);
        if (message.createdAt != null) {
          if (lastCreatedDate == null) {
            lastCreatedDate = message.createdAt!.toLocal();
          } else {
            if (lastCreatedDate
                    .difference(message.createdAt!.toLocal())
                    .inDays >
                0) {
              String dateString =
                  DateFormat('EEE, d MMM').format(lastCreatedDate);
              groupedMessages.add(ChatItem.date(dateString));
              lastCreatedDate = message.createdAt!.toLocal();
            }
          }

          groupedMessages.add(ChatItem.message(message));

          if (message == event.messages.last) {
            int currentYear = DateTime.now().year;
            int messageYear = lastCreatedDate.year;

            String dateString = (messageYear == currentYear)
                ? DateFormat('EEE, d MMM').format(lastCreatedDate)
                : DateFormat('EEE, d MMM yyyy').format(lastCreatedDate);

            groupedMessages.add(ChatItem.date(dateString));
            lastCreatedDate = message.createdAt!.toLocal();
          }
        }
      }

      emit(state.copyWith(
        messages: groupedMessages,
        isFetching: event.isFetching,
        hasNextPage: liveCollection?.hasNextPage(),
        newMessage: newMessage,
      ));
    });

    on<ChatPageEventLoadMore>((event, emit) async {
      try {
        if (liveCollection?.hasNextPage() == true) {
          await liveCollection?.loadNext();
        }
      } catch (e) {}
    });

    on<ChatPageEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isFetching));
    });

    on<ChatPageIsMuteEventChanged>((event, emit) async {
      emit(state.copyWith(isMute: event.isMute, isOnMuteChange: false));
    });

    on<ChatPageEventChannelIdChanged>((event, emit) async {
      emit(state.copyWith(channelId: event.channelId));
    });

    on<ChatPageNetworkConnectivityChanged>((event, emit) async {
      emit(state.copyWith(isConnected: event.isConnected));
    });

    on<ChatPageShowScrollButtonEvent>((event, emit) async {
      emit(state.copyWith(showScrollButton: event.showScrollButton));
    });

    on<ChatPageNewMessageUpdated>((event, emit) async {
      emit(state.copyWith(newMessage: event.newMessage));
    });

    on<ChatPageEventFetchLocalVideoThumbnail>((event, emit) async {
      Map<String, Uint8List?> localThumbnails = {...state.localThumbnails};
      if (!localThumbnails.containsKey(event.uniqueId)) {
        localThumbnails[event.uniqueId] = null;
        emit(state.copyWith(localThumbnails: localThumbnails));
        try {
          final Uint8List? uint8list = await VideoThumbnail.thumbnailData(
            video: event.videoPath,
            imageFormat: ImageFormat.PNG,
            maxWidth: 240,
            maxHeight: 240,
            quality: 75,
          );
          if (uint8list != null && uint8list.isNotEmpty) {
            Map<String, Uint8List?> currentLocalThumbnails = {
              ...state.localThumbnails
            };
            currentLocalThumbnails[event.uniqueId] = uint8list;
            emit(state.copyWith(localThumbnails: currentLocalThumbnails));
          }
        } catch (e) {}
      }
    });

    on<ChatPageEventResendMessage>((event, emit) async {
      final message = event.message;
      final messageRepo = AmityChatClient.newMessageRepository();
      final subChannelId = message.subChannelId;
      if (subChannelId == null) {
        return;
      }
      try {
        if (message.data is MessageTextData) {
          final text = (message.data as MessageTextData).text;
          if (text == null) {
            return;
          }
          await message.delete();
          await messageRepo
              .createMessage(subChannelId)
              .text(text)
              .parentId(message.parentId)
              .send();
          await messageRepo
              .createMessage(subChannelId)
              .text(text)
              .parentId(message.parentId)
              .send();
        } else if (message.data is MessageImageData) {
          final localPath =
              (message.data as MessageImageData).image?.getFilePath;
          if (localPath == null) {
            return;
          }
          final uri = Uri.file(localPath);
          await message.delete();
          await messageRepo
              .createMessage(subChannelId)
              .image(uri)
              .parentId(message.parentId)
              .send();
          await messageRepo
              .createMessage(subChannelId)
              .image(uri)
              .parentId(message.parentId)
              .send();
        } else if (message.data is MessageVideoData) {
          final localPath =
              (message.data as MessageVideoData).getVideo().getFilePath;
          if (localPath == null) {
            return;
          }
          final uri = Uri.file(localPath);
          await message.delete();
          await messageRepo
              .createMessage(subChannelId)
              .video(uri)
              .parentId(message.parentId)
              .send();
        }
      } catch (e) {}
    });

    on<ChatPageEventCreateNewChannel>((event, emit) async {
      final channel = await AmityChatClient.newChannelRepository()
          .createChannel()
          .conversationType()
          .withUserId(event.userId)
          .create();

      final channelId = channel.channelId;
      if (channelId != null) {
        initLiveCollection(channelId);
        addEvent(ChatPageEventChannelIdChanged(channelId));
        addEvent(ChatPageEventRefresh());
        addEvent(const ChatPageEventFetchMuteState());
      }
    });

    on<ChatPageReplyEvent>((event, emit) async {
      emit(
          state.copyWith(replyingMessage: event.message, editingMessage: null));
    });

    on<ChatPageRemoveReplyEvent>((event, emit) async {
      emit(state.copyWith(replyingMessage: null, editingMessage: null));
    });

    on<ChatPageEditEvent>((event, emit) async {
      emit(
          state.copyWith(editingMessage: event.message, replyingMessage: null));
    });

    on<ChatPageEventMarkReadMessage>((event, emit) async {
      event.message.markRead();
    });

    if (channelId != null && channelId.isNotEmpty) {
      initLiveCollection(channelId);
      addEvent(ChatPageEventChannelIdChanged(channelId));
      addEvent(ChatPageEventRefresh());
      addEvent(const ChatPageEventFetchMuteState());
    } else if (userId != null && userId.isNotEmpty) {
      addEvent(ChatPageEventCreateNewChannel(userId: userId));
    }
  }

  void _setupScrollListener() {
    if (!_isScrollListenerAdded) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            (_scrollController.position.maxScrollExtent)) {
          add(const ChatPageEventLoadMore());
        }

        if (_scrollController.hasClients && state.messages.isNotEmpty) {
          // For reverse: true lists, position 0 is the latest message at the bottom
          // Check if we've scrolled past seeing the latest message
          final isScrolledUp = _scrollController.position.pixels > 50;

          if (isScrolledUp == false && state.newMessage != null) {
            add(ChatPageNewMessageUpdated(newMessage: null));
          }

          if (isScrolledUp != state.showScrollButton) {
            add(ChatPageShowScrollButtonEvent(showScrollButton: isScrolledUp));
          }
        }
      });
      _isScrollListenerAdded = true;
    }
  }

  @override
  Future<void> close() {
    _scrollController.dispose();
    subscription.cancel();
    liveCollection?.getStreamController().close();
    liveCollection?.dispose();
    return super.close();
  }

  void initLiveCollection(String channelId) async {
    if (liveCollection != null) {
      liveCollection?.getStreamController().close();
      await liveCollection?.dispose();
    }
    liveCollection = AmityChatClient.newMessageRepository()
        .getMessages(channelId)
        .stackFromEnd(true)
        .includingTags([])
        .excludingTags([])
        .includeDeleted(true)
        .filterByParent(false)
        .getLiveCollection();

    final list = await AmityChatClient.newChannelRepository()
        .membership(channelId)
        .getMembersFromCache();
    final otherMember = list
        .firstWhere((element) => element.userId != AmityCoreClient.getUserId());
    if (otherMember.user != null) {
      addEvent(ChatPageHeaderEventChanged(channelMember: otherMember));
    }

    liveCollection?.getStreamController().stream.listen((event) {
      addEvent(
          ChatPageEventChanged(messages: event, isFetching: state.isFetching));
    });

    liveCollection?.observeLoadingState().listen((event) {
      addEvent(ChatPageEventLoadingStateUpdated(isFetching: event));
    });

    // Observe Network Connectivity status here
    subscription =
        Connectivity().onConnectivityChanged.listen((connectivityEvent) {
      if (connectivityEvent.contains(ConnectivityResult.none)) {
        addEvent(const ChatPageNetworkConnectivityChanged(isConnected: false));
      } else {
        addEvent(const ChatPageNetworkConnectivityChanged(isConnected: true));
      }
    });
  }
}

class ChatItem {
  final ChatItemType type;
  final AmityMessage? message;
  final String? date;

  ChatItem.message(this.message)
      : type = ChatItemType.message,
        date = null;

  ChatItem.date(this.date)
      : type = ChatItemType.date,
        message = null;
}

enum ChatItemType {
  message,
  date,
}
