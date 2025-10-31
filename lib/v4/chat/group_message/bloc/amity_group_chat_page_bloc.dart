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

part 'amity_group_chat_page_events.dart';
part 'amity_group_chat_page_state.dart';

class AmityGroupChatPageBloc
    extends Bloc<GroupChatPageEvent, GroupChatPageState> {
  var messagesCount = 0;
  MessageLiveCollection? liveCollection;

  StreamSubscription<List<ConnectivityResult>>? subscription;
  late ScrollController _scrollController;
  bool _isScrollListenerAdded = false;
  bool _isJumpScrollInProgress = false;
  Timer? _jumpToMessageTimeoutTimer;

  final AmityToastBloc toastBloc;

  AmityGroupChatPageBloc(String? channelId, this.toastBloc,
      {String? jumpToMessageId})
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
      emit(state.copyWith(
          messages: const [],
          isFetching: true,
          isLoadingMore: false,
          hasNextPage: true,
          hasPrevious: false));
      try {
        liveCollection?.reset();
        liveCollection?.loadNext();
      } catch (e) {
        emit(state.copyWith(
            messages: const [],
            isFetching: false,
            isLoadingMore: false,
            hasNextPage: false,
            hasPrevious: false));
      }
    });

    on<GroupChatPageHeaderEventChanged>((event, emit) async {
      emit(state.copyWith(
        avatarUrl: event.channel.avatar?.fileUrl,
        channelDisplayName: event.channel.displayName,
        channel: event.channel,
        hasNextPage: liveCollection?.hasNextPage(),
        hasPrevious: liveCollection?.hasPreviousPage(),
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

      for (var i = 0; i < event.messages.length; i++) {
        var message = event.messages[i];
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
        isLoadingMore: false,
        hasNextPage: liveCollection?.hasNextPage(),
        hasPrevious: liveCollection?.hasPreviousPage(),
        newMessage: newMessage,
      ));
      
    });

    on<GroupChatPageEventLoadMore>((event, emit) async {
      try {
        if (liveCollection?.hasNextPage() == true) {
          emit(state.copyWith(useReverseUI: true, isLoadingMore: true));
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
          await liveCollection?.loadNext();
        }
      } catch (e) {}
    });

    on<GroupChatPageEventLoadPrevious>((event, emit) async {
      try {
        if (liveCollection?.hasPreviousPage() == true) {
          emit(state.copyWith(useReverseUI: false, isLoadingMore: true));
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
          await liveCollection?.loadPrevious();

          add(GroupChatPageShowScrollButtonEvent(showScrollButton: false));
        }
      } catch (e) {}
    });

    on<GroupChatPageEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isFetching));

      if (!event.isFetching && state is! GroupChatPageStateInitial && state.aroundMessageId != null && !_isJumpScrollInProgress && state.shouldBounceMessage == false) {
        _isJumpScrollInProgress = true;
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!_isJumpScrollInProgress && state.aroundMessageId == null) return;
          _startProgressiveScrollToTop(state.aroundMessageId!);
        });
      }
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
        final result = await _loadMemberRolesAndMutedStatus();
        final memberRoles = result['memberRoles'] as Map<String, List<String>>;
        final mutedUsers = result['mutedUsers'] as Map<String, bool>;

        addEvent(GroupChatPageMemberRolesUpdated(memberRoles: memberRoles));
        addEvent(GroupChatPageMutedUsersUpdated(mutedUsers: mutedUsers));
      } catch (e) {
        // If there's an error, keep empty member roles and muted users
        addEvent(const GroupChatPageMemberRolesUpdated(memberRoles: {}));
        addEvent(const GroupChatPageMutedUsersUpdated(mutedUsers: {}));
      }
    });

    on<GroupChatPageMemberRolesUpdated>((event, emit) {
      emit(state.copyWith(memberRoles: event.memberRoles));
    });

    on<GroupChatPageMutedUsersUpdated>((event, emit) {
      emit(state.copyWith(mutedUsers: event.mutedUsers));
    });

    on<GroupChatPageEventMarkReadMessage>((event, emit) async {
      event.message.markRead();
    });

    on<GroupChatPageEventJumpToMessage>((event, emit) async {
      // TO DO
    });

    on<GroupChatPageSetAroundMessage>((event, emit) async {
      if (event.aroundMessageId != null) {
        _isJumpScrollInProgress = false;
        
        _jumpToMessageTimeoutTimer?.cancel();
        _jumpToMessageTimeoutTimer = Timer(const Duration(seconds: 10), () {
          if (state.aroundMessageId != null) {
            add(const GroupChatPageSetAroundMessage(aroundMessageId: null));
          }
        });
      } else {
        _jumpToMessageTimeoutTimer?.cancel();
        _jumpToMessageTimeoutTimer = null;
      }
      
      emit(state.copyWith(aroundMessageId: event.aroundMessageId));
    });

    on<GroupChatPageTriggerBounceEvent>((event, emit) async {
      // emit(state.copyWith(bounceTargetIndex: event.targetIndex));
      
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   if (!isClosed) {
      //     add(const GroupChatPageClearBounceEvent());
      //   }
      // });
    });

    on<GroupChatPageClearBounceEvent>((event, emit) async {
      emit(state.copyWith(bounceTargetIndex: null));
    });

    on<GroupChatPageSetLoadingToastDismissed>((event, emit) async {
      emit(state.copyWith(isLoadingToastDismissed: event.isDismissed));
    });

    on<GroupChatPageSetShouldBounceMessage>((event, emit) async {
      emit(state.copyWith(
        shouldBounceMessage: event.shouldBounce,
        bounceMessageIndex: event.messageIndex,
      ));
    });

    on<GroupChatPageSetShouldUseReverse>((event, emit) async {
      emit(state.copyWith(shouldUseReverse: event.shouldUseReverse));
    });

    if (channelId.isNotEmpty) {
      addEvent(GroupChatPageSetAroundMessage(aroundMessageId: jumpToMessageId));

      initLiveCollection(channelId, aroundMessageId: jumpToMessageId);
      addEvent(GroupChatPageEventChannelIdChanged(channelId));
      addEvent(GroupChatPageEventRefresh());
      addEvent(const GroupChatPageEventFetchMuteState());
    }
  }

  void _setupScrollListener() {
    if (!_isScrollListenerAdded) {
      _scrollController.addListener(() {
        if (!_scrollController.hasClients) return;

        if (state.aroundMessageId != null) {
          return;
        }

        final position = _scrollController.position;
        
        if (state.useReverseUI) {
          if (position.pixels <= -50) {
            add(const GroupChatPageEventLoadPrevious());
            return;
          }
          if (position.pixels >= (position.maxScrollExtent - 100)) {
            add(const GroupChatPageEventLoadMore());
            return;
          }
        } else {
          if (position.pixels <= 50) {
            add(const GroupChatPageEventLoadMore());
            return;
          }
          if (position.pixels >= (position.maxScrollExtent + 50)) {
            add(const GroupChatPageEventLoadPrevious());
            return;
          }
        }

        if (_scrollController.hasClients && state.messages.isNotEmpty) {
          if (state.useReverseUI) {
            final isScrolledUp = _scrollController.position.pixels > 50;

            if (isScrolledUp == false && state.newMessage != null) {
              add(GroupChatPageNewMessageUpdated(newMessage: null));
            }

            if (isScrolledUp != state.showScrollButton) {
              add(GroupChatPageShowScrollButtonEvent(
                  showScrollButton: isScrolledUp));
            }
          }
        }
      });
      _isScrollListenerAdded = true;
    }
  }

  @override
  Future<void> close() {
    _scrollController.dispose();
    subscription?.cancel();
    _jumpToMessageTimeoutTimer?.cancel();
    liveCollection?.getStreamController().close();
    liveCollection?.dispose();
    return super.close();
  }

  void initLiveCollection(String channelId, {String? aroundMessageId}) async {
    liveCollection?.getStreamController().close();
    liveCollection?.dispose();
    liveCollection = null;

    MessageGetQueryBuilder query = AmityChatClient.newMessageRepository()
        .getMessages(channelId)
        .stackFromEnd(true)
        .includingTags([])
        .excludingTags([])
        .includeDeleted(true)
        .filterByParent(false);

    if (aroundMessageId != null) {
      query = query.aroundMessageId(aroundMessageId);
    }

    liveCollection = query.getLiveCollection();

    liveCollection?.getStreamController().stream.listen((event) {
      addEvent(GroupChatPageEventChanged(
          messages: event, isFetching: state.isFetching));
    });

    liveCollection?.observeLoadingState().listen((event) {
      addEvent(GroupChatPageEventLoadingStateUpdated(isFetching: event));
    });

    // Observe Network Connectivity status here
    // Cancel existing subscription before creating a new one
    subscription?.cancel();
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

  // Helper method to load member roles and muted status
  Future<Map<String, dynamic>> _loadMemberRolesAndMutedStatus() async {
    try {
      if (state.channel?.channelId == null) return {};

      final members = await AmityChatClient.newChannelRepository()
          .membership(state.channel!.channelId!)
          .getMembersFromCache();

      final memberRolesMap = <String, List<String>>{};
      final mutedUsersMap = <String, bool>{};
      
      // Populate member roles map with each member's roles and muted status
      for (var member in members) {
        if (member.userId != null) {
          // Add roles
          if (member.roles != null) {
            memberRolesMap[member.userId!] = member.roles!.roles ?? [];
          }
          // Check if member is muted using the isMuted property directly
          mutedUsersMap[member.userId!] = member.isMuted ?? false;
        }
      }

      return {'memberRoles': memberRolesMap, 'mutedUsers': mutedUsersMap};
    } catch (e) {
      return {
        'memberRoles': <String, List<String>>{},
        'mutedUsers': <String, bool>{}
      };
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
      return false;
    }
  }

  void _startProgressiveScrollToTop(String targetMessageId) {
    // Only start scrolling if data is loaded and page is initialized (same condition as toast dismiss)
    if (!(!state.isFetching && state is! GroupChatPageStateInitial)) {
      _isJumpScrollInProgress = false;
      return;
    }
    
    if (!_scrollController.hasClients) {
      _isJumpScrollInProgress = false;
      addEvent(const GroupChatPageSetAroundMessage(aroundMessageId: null));
      return;
    }
    
    final position = _scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    
    // Just scroll to the top with constant speed linear animation
    _scrollController.animateTo(
      maxScrollExtent,
      duration: const Duration(milliseconds: 300), // Fast 500ms scroll
      curve: Curves.linear, // Constant speed linear animation
    ).then((_) {
      // Clean up scroll state - bounce will be triggered when message becomes visible
      _isJumpScrollInProgress = false;
    });
  }



  @override
  void onTransition(
      Transition<GroupChatPageEvent, GroupChatPageState> transition) {
    super.onTransition(transition);
  }
}
