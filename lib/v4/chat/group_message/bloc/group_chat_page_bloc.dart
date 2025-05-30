import 'dart:async';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/bloc/chat_page_bloc.dart';
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

part 'group_chat_page_events.dart';
part 'group_chat_page_state.dart';

class GroupChatPageBloc extends Bloc<GroupChatPageEvent, GroupChatPageState> {
  var messagesCount = 0;
  MessageLiveCollection? liveCollection;

  late final StreamSubscription<List<ConnectivityResult>> subscription;
  late ScrollController _scrollController;
  bool _isScrollListenerAdded = false;

  final AmityToastBloc toastBloc;

  GroupChatPageBloc(String? channelId, this.toastBloc)
      : super(GroupChatPageStateInitial(
            channelId: channelId ?? "", scrollController: ScrollController())) {
    _scrollController = state.scrollController;
    _setupScrollListener();

    AmityChatClient.newChannelRepository()
        .getChannel(channelId!)
        .then((channel) {
      addEvent(GroupChatPageHeaderEventChanged(channel: channel));
      addEvent(GroupChatPageEventCheckModeratorStatus(channel: channel));
    });

    on<GroupChatPageEventRefresh>((event, emit) async {
      emit(GroupChatPageStateChanged(
          channelId: state.channelId,
          messages: const [],
          isFetching: true,
          hasNextPage: true,
          scrollController: state.scrollController));
      try {
        liveCollection?.reset();
        liveCollection?.loadNext();
      } catch (e) {
        emit(GroupChatPageStateChanged(
            channelId: state.channelId,
            messages: const [],
            isFetching: false,
            hasNextPage: false,
            scrollController: state.scrollController));
      }
    });

    on<GroupChatPageHeaderEventChanged>((event, emit) async {
      emit(state.copyWith(
        avatarUrl: event.channel.avatar?.fileUrl,
        channelDisplayName: event.channel.displayName,
        channel: event.channel,
        hasNextPage: liveCollection?.hasNextPage(),
      ));
      
      // When channel changes, check moderator status and load member roles
      addEvent(GroupChatPageEventCheckModeratorStatus(channel: event.channel));
      addEvent(const GroupChatPageLoadMemberRoles());
    });

    on<GroupChatPageEventFetchMuteState>((event, emit) async {
      AmityCoreClient()
          .notifications()
          .channel(state.channelId)
          .getSettings()
          .then((value) => {
                addEvent(GroupChatPageIsMuteEventChanged(
                    isMute: !(value.isEnabled ?? true))),
              });
    });

    on<GroupChatPageEventMuteUnmute>((event, emit) async {
      if (state.isMute) {
        emit(state.copyWith(isMute: false, isOnMuteChange: true));
        try {
          await AmityCoreClient()
              .notifications()
              .channel(state.channelId)
              .enable();
          addEvent(const GroupChatPageIsMuteEventChanged(isMute: false));
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
          addEvent(const GroupChatPageIsMuteEventChanged(isMute: true));
        } catch (error) {
          emit(state.copyWith(isMute: true, isOnMuteChange: false));
          toastBloc.add(
              const AmityToastShort(message: "Failed to mute the channel."));
        }
      }
    });

    on<GroupChatPageEventChanged>((event, emit) async {
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

    on<GroupChatPageEventLoadMore>((event, emit) async {
      try {
        if (liveCollection?.hasNextPage() == true) {
          await liveCollection?.loadNext();
        }
      } catch (e) {}
    });

    on<GroupChatPageEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isFetching));
    });

    on<GroupChatPageIsMuteEventChanged>((event, emit) async {
      emit(state.copyWith(isMute: event.isMute, isOnMuteChange: false));
    });

    on<GroupChatPageEventChannelIdChanged>((event, emit) async {
      emit(state.copyWith(channelId: event.channelId));
    });

    on<GroupChatPageNetworkConnectivityChanged>((event, emit) async {
      emit(state.copyWith(isConnected: event.isConnected));
    });

    on<GroupChatPageShowScrollButtonEvent>((event, emit) async {
      emit(state.copyWith(showScrollButton: event.showScrollButton));
    });

    on<GroupChatPageNewMessageUpdated>((event, emit) async {
      emit(state.copyWith(newMessage: event.newMessage));
    });

    on<GroupChatPageEventFetchLocalVideoThumbnail>((event, emit) async {
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

    on<GroupChatPageEventResendMessage>((event, emit) async {
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

    on<GroupChatPageEventCreateNewChannel>((event, emit) async {
      final channel = await AmityChatClient.newChannelRepository()
          .createChannel()
          .conversationType()
          .withUserId(event.userId)
          .create();

      final channelId = channel.channelId;
      if (channelId != null) {
        initLiveCollection(channelId);
        addEvent(GroupChatPageEventChannelIdChanged(channelId));
        addEvent(GroupChatPageEventRefresh());
        addEvent(const GroupChatPageEventFetchMuteState());
      }
    });

    on<GroupChatPageReplyEvent>((event, emit) async {
      emit(
          state.copyWith(replyingMessage: event.message, editingMessage: null));
    });

    on<GroupChatPageRemoveReplyEvent>((event, emit) async {
      emit(state.copyWith(replyingMessage: null, editingMessage: null));
    });

    on<GroupChatPageEditEvent>((event, emit) async {
      emit(
          state.copyWith(editingMessage: event.message, replyingMessage: null));
    });

    on<GroupChatPageEventCheckModeratorStatus>((event, emit) async {
      try {
        final isModerator = await _checkIfUserIsModerator(event.channel);
        addEvent(GroupChatPageModeratorStatusUpdated(isModerator: isModerator));
      } catch (e) {
        // If there's an error, default to false
        addEvent(const GroupChatPageModeratorStatusUpdated(isModerator: false));
      }
    });

    on<GroupChatPageModeratorStatusUpdated>((event, emit) {
      emit(state.copyWith(isModerator: event.isModerator));
    });

    on<GroupChatPageLoadMemberRoles>((event, emit) async {
      try {
        final memberRoles = await _loadMemberRoles();
        addEvent(GroupChatPageMemberRolesUpdated(memberRoles: memberRoles));
      } catch (e) {
        // If there's an error, keep empty member roles
        addEvent(const GroupChatPageMemberRolesUpdated(memberRoles: {}));
      }
    });

    on<GroupChatPageMemberRolesUpdated>((event, emit) {
      emit(state.copyWith(memberRoles: event.memberRoles));
    });
    
    on<GroupChatPageEventMarkReadMessage>((event, emit) async {
      event.message.markRead();
    });

    if (channelId.isNotEmpty) {
      initLiveCollection(channelId);
      addEvent(GroupChatPageEventChannelIdChanged(channelId));
      addEvent(GroupChatPageEventRefresh());
      addEvent(const GroupChatPageEventFetchMuteState());
    }
    //  else if (userId != null && userId.isNotEmpty) {
    //   addEvent(GroupChatPageEventCreateNewChannel(userId: userId));
    // }
  }

  void _setupScrollListener() {
    if (!_isScrollListenerAdded) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            (_scrollController.position.maxScrollExtent)) {
          add(const GroupChatPageEventLoadMore());
        }

        if (_scrollController.hasClients && state.messages.isNotEmpty) {
          // For reverse: true lists, position 0 is the latest message at the bottom
          // Check if we've scrolled past seeing the latest message
          final isScrolledUp = _scrollController.position.pixels > 50;

          if (isScrolledUp == false && state.newMessage != null) {
            add(GroupChatPageNewMessageUpdated(newMessage: null));
          }

          if (isScrolledUp != state.showScrollButton) {
            add(GroupChatPageShowScrollButtonEvent(
                showScrollButton: isScrolledUp));
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

    // final list = await AmityChatClient.newChannelRepository()
    //     .membership(channelId)
    //     .getMembersFromCache();
    // final otherMember = list
    //     .firstWhere((element) => element.userId != AmityCoreClient.getUserId());
    // if (otherMember.user != null) {
    //   addEvent(GroupChatPageHeaderEventChanged(channelMember: otherMember));
    // }

    liveCollection?.getStreamController().stream.listen((event) {
      addEvent(GroupChatPageEventChanged(
          messages: event, isFetching: state.isFetching));
    });

    liveCollection?.observeLoadingState().listen((event) {
      addEvent(GroupChatPageEventLoadingStateUpdated(isFetching: event));
    });

    // Observe Network Connectivity status here
    subscription =
        Connectivity().onConnectivityChanged.listen((connectivityEvent) {
      if (connectivityEvent.contains(ConnectivityResult.none)) {
        addEvent(
            const GroupChatPageNetworkConnectivityChanged(isConnected: false));
      } else {
        addEvent(
            const GroupChatPageNetworkConnectivityChanged(isConnected: true));
      }
    });
  }

  // Helper method to load member roles
  Future<Map<String, List<String>>> _loadMemberRoles() async {
    try {
      if (state.channel?.channelId == null) return {};
      
      final memberLiveCollection = AmityChatClient.newChannelRepository()
          .membership(state.channel!.channelId!)
          .searchMembers('')
          .getLiveCollection();

      final completer = Completer<Map<String, List<String>>>();
      final memberRolesMap = <String, List<String>>{};

      // Subscribe to the stream to get member data
      final subscription = memberLiveCollection.getStreamController().stream.listen((members) {
        // Populate member roles map with each member's roles
        for (var member in members) {
          if (member.userId != null && member.roles != null) {
            memberRolesMap[member.userId!] = member.roles!.roles ?? [];
          }
        }
        // Only complete if not already completed
        if (!completer.isCompleted) {
          completer.complete(memberRolesMap);
        }
      });

      // Load the first batch
      await memberLiveCollection.loadNext();
      
      // Wait for the result or timeout after 5 seconds
      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => <String, List<String>>{},
      );
      
      subscription.cancel();
      return result;
    } catch (e) {
      return {};
    }
  }

  // Helper method to check if current user is a moderator
  Future<bool> _checkIfUserIsModerator(AmityChannel channel) async {
    try {
      final roles = await channel.getCurentUserRoles();
      return roles.contains('moderator') ||
             roles.contains('community-moderator') ||
             roles.contains('channel-moderator');
    } catch (e) {
      return false; // Default to false if there's an error
    }
  }
}
