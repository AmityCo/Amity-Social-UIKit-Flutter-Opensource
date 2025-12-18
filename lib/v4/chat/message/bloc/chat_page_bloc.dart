import 'dart:async';
import 'dart:typed_data';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/replying_message.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
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
  bool _isJumpScrollInProgress = false; // Flag to track jump scroll state
  Timer? _jumpToMessageTimeoutTimer;

  final AmityToastBloc toastBloc;
  BuildContext _context;

  ChatPageBloc(String? channelId, String? userId, String? userDisplayName,
      String? avatarUrl, this.toastBloc, this._context,
      {String? jumpToMessageId})
      : super(ChatPageStateInitial(
            channelId: channelId ?? "",
            userDisplayName: userDisplayName,
            avatarUrl: avatarUrl,
            scrollController: ScrollController())) {
    _scrollController = state.scrollController;
    _setupScrollListener();

    on<ChatPageEventRefresh>((event, emit) async {
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

    on<ChatPageHeaderEventChanged>((event, emit) async {
      emit(state.copyWith(
        avatarUrl: event.channelMember.user?.avatarUrl,
        userDisplayName: event.channelMember.user?.displayName,
        channelMember: event.channelMember,
        user: event.channelMember.user,
        hasNextPage: liveCollection?.hasNextPage(),
      ));

      // Fetch follow info to determine blocking status
      if (event.channelMember.user != null) {
        addEvent(const ChatPageEventFetchFollowInfo());
      }
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
        try {
          await AmityCoreClient()
              .notifications()
              .channel(state.channelId)
              .enable();
          addEvent(const ChatPageIsMuteEventChanged(isMute: false));

          await Future.delayed(const Duration(milliseconds: 300));

          toastBloc.add(AmityToastShort(
            message: _context.l10n.notification_turn_on_success,
            icon: AmityToastIcon.success,
          ));
        } catch (error) {
          toastBloc.add(AmityToastShort(
              message: _context.l10n.notification_turn_on_error));
        }
      } else {
        try {
          await AmityCoreClient()
              .notifications()
              .channel(state.channelId)
              .disable();
          addEvent(const ChatPageIsMuteEventChanged(isMute: true));

          await Future.delayed(const Duration(milliseconds: 300));

          toastBloc.add(AmityToastShort(
            message: _context.l10n.notification_turn_off_success,
            icon: AmityToastIcon.success,
          ));
        } catch (error) {
          toastBloc.add(AmityToastShort(
              message: _context.l10n.notification_turn_off_error));
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
        isLoadingMore: false, // Reset load more state when new messages arrive
        hasNextPage: liveCollection?.hasNextPage(),
        hasPrevious: liveCollection?.hasPreviousPage(),
        newMessage: newMessage,
      ));
    });

    on<ChatPageEventLoadMore>((event, emit) async {
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

    on<ChatPageEventLoadPrevious>((event, emit) async {
      try {
        if (liveCollection?.hasPreviousPage() == true) {
          emit(state.copyWith(useReverseUI: false, isLoadingMore: true));
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
          await liveCollection?.loadPrevious();

          add(ChatPageShowScrollButtonEvent(showScrollButton: false));
        }
      } catch (e) {}
    });

    on<ChatPageEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isFetching));

      if (!event.isFetching && state is! ChatPageStateInitial && state.aroundMessageId != null && !_isJumpScrollInProgress) {
        _isJumpScrollInProgress = true;
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!_isJumpScrollInProgress || state.aroundMessageId == null) return;
          _startProgressiveScrollToTop(state.aroundMessageId!);
        });
      }
    });

    on<ChatPageIsMuteEventChanged>((event, emit) async {
      emit(state.copyWith(isMute: event.isMute));
    });

    on<ChatPageUserFlagStateChanged>((event, emit) async {
      emit(state.copyWith(user: event.user));
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

    on<ChatPageEventFlagUser>((event, emit) async {
      // Use our dedicated user property first, fallback to channelMember.user if needed
      AmityUser? user = state.user ?? state.channelMember?.user;
      if (user == null) {
        return;
      }

      if (event.isFlagging) {
        try {
          // First flag the user
          final updatedUser = await user.report().flag();

          // Dispatch the state change event
          addEvent(
              ChatPageUserFlagStateChanged(isFlagged: true, user: updatedUser));

          // Use a small delay before showing toast
          await Future.delayed(const Duration(milliseconds: 300));

          // Then show toast message
          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_report_success,
            icon: AmityToastIcon.success,
          ));
        } catch (error) {
          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_report_error,
            icon: AmityToastIcon.warning,
          ));
        }
      } else {
        try {
          // First unflag the user
          final updatedUser = await user.report().unflag();

          // Dispatch the state change event
          addEvent(ChatPageUserFlagStateChanged(
              isFlagged: false, user: updatedUser));

          // Use a small delay before showing toast
          await Future.delayed(const Duration(milliseconds: 300));

          // Then show toast message
          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_unreport_success,
            icon: AmityToastIcon.success,
          ));
        } catch (error) {
          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_unreport_error,
            icon: AmityToastIcon.warning,
          ));
        }
      }
    });

    on<ChatPageEventFetchFollowInfo>((event, emit) async {
      // Use our dedicated user property first, fallback to channelMember.user if needed
      String? userId = event.userId ?? state.user?.userId ?? state.channelMember?.user?.userId;
      if (userId == null) {
        return;
      }

      try {
        final followInfo = await AmityCoreClient.newUserRepository()
            .relationship()
            .getFollowInfo(userId);

        final isBlocking = followInfo.status == AmityFollowStatus.BLOCKED;
        addEvent(ChatPageFollowInfoUpdated(isUserBlocked: isBlocking));
      } catch (error) {
        // If there's an error fetching follow info, default to not blocking
        addEvent(const ChatPageFollowInfoUpdated(isUserBlocked: false));
      }
    });

    on<ChatPageFollowInfoUpdated>((event, emit) async {
      emit(state.copyWith(isUserBlocked: event.isUserBlocked));
    });

    on<ChatPageEventBlockUser>((event, emit) async {
      // Use our dedicated user property first, fallback to channelMember.user if needed
      AmityUser? user = state.user ?? state.channelMember?.user;
      if (user == null) {
        return;
      }

      try {
        if (event.isUserBlocked) {
          // Block the user
          await AmityCoreClient.newUserRepository()
              .relationship()
              .blockUser(user.userId!);

          // Update state to reflect blocking
          addEvent(const ChatPageFollowInfoUpdated(isUserBlocked: true));

          // Use a small delay before showing toast
          await Future.delayed(const Duration(milliseconds: 300));

          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_block_success,
            icon: AmityToastIcon.success,
          ));
        } else {
          // Unblock the user
          await AmityCoreClient.newUserRepository()
              .relationship()
              .unblockUser(user.userId!);

          // Update state to reflect unblocking
          addEvent(const ChatPageFollowInfoUpdated(isUserBlocked: false));

          // Use a small delay before showing toast
          await Future.delayed(const Duration(milliseconds: 300));

          toastBloc.add(AmityToastShort(
            message: _context.l10n.user_unblock_success,
            icon: AmityToastIcon.success,
          ));
        }
      } catch (error) {
        toastBloc.add(AmityToastShort(
          message: event.isUserBlocked
              ? _context.l10n.user_block_error
              : _context.l10n.user_unblock_error,
          icon: AmityToastIcon.warning,
        ));
      }
    });

    on<ChatPageEventJumpToMessage>((event, emit) async {
      // Set the aroundMessageId in state and reinitialize live collection
      addEvent(ChatPageSetAroundMessage(
          aroundMessageId: event.aroundMessageId));

      // Reinitialize the live collection with the aroundMessageId
      initLiveCollection(state.channelId,
          aroundMessageId: event.aroundMessageId);

      // Refresh to load messages around the target message
      addEvent(ChatPageEventRefresh());
    });

    on<ChatPageSetAroundMessage>((event, emit) async {
      // Reset jump scroll flag when setting new aroundMessageId
      if (event.aroundMessageId != null) {
        _isJumpScrollInProgress = false;
        
        // Start timeout timer for jump-to-message (10 seconds)
        _jumpToMessageTimeoutTimer?.cancel();
        _jumpToMessageTimeoutTimer = Timer(const Duration(seconds: 10), () {
          // If message still not found after timeout, clear aroundMessageId
          if (state.aroundMessageId != null) {
            add(const ChatPageSetAroundMessage(aroundMessageId: null));
          }
        });
      } else {
        // Clear timeout timer when aroundMessageId is cleared
        _jumpToMessageTimeoutTimer?.cancel();
        _jumpToMessageTimeoutTimer = null;
      }
      
      emit(state.copyWith(aroundMessageId: event.aroundMessageId));
    });

    on<ChatPageTriggerBounceEvent>((event, emit) async {
      // emit(state.copyWith(bounceTargetIndex: event.targetIndex));
      
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   if (state.bounceTargetIndex == event.targetIndex) {
      //     add(const ChatPageClearBounceEvent());
      //   }
      // });
    });

    on<ChatPageClearBounceEvent>((event, emit) async {
      emit(state.copyWith(bounceTargetIndex: null));
    });

    if (channelId != null && channelId.isNotEmpty) {
      addEvent(ChatPageSetAroundMessage(aroundMessageId: jumpToMessageId));
      
      initLiveCollection(channelId, aroundMessageId: jumpToMessageId);
      addEvent(ChatPageEventChannelIdChanged(channelId));
      addEvent(ChatPageEventRefresh());
      addEvent(const ChatPageEventFetchMuteState());
    } else if (userId != null && userId.isNotEmpty) {
      addEvent(ChatPageEventCreateNewChannel(userId: userId));
    }
    if (userId != null && userId.isNotEmpty) {
      fetchFellowInfo(userId);
    }
  }

  void fetchFellowInfo(String userId) {
    addEvent(ChatPageEventFetchFollowInfo(userId: userId));
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
            add(const ChatPageEventLoadPrevious());
            return;
          }
          if (position.pixels >= (position.maxScrollExtent - 100)) {
            add(const ChatPageEventLoadMore());
            return;
          }
        } else {
          if (position.pixels <= 50) {
            add(const ChatPageEventLoadMore());
            return;
          }
          if (position.pixels >= (position.maxScrollExtent + 50)) {
            add(const ChatPageEventLoadPrevious());
            return;
          }
        }

        if (_scrollController.hasClients && state.messages.isNotEmpty) {
          if (state.useReverseUI) {
            final isScrolledUp = _scrollController.position.pixels > 50;

            if (isScrolledUp == false && state.newMessage != null) {
              add(const ChatPageNewMessageUpdated(newMessage: null));
            }

            if (isScrolledUp != state.showScrollButton) {
              add(ChatPageShowScrollButtonEvent(showScrollButton: isScrolledUp));
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
    subscription.cancel();
    _jumpToMessageTimeoutTimer?.cancel();
    liveCollection?.getStreamController().close();
    liveCollection?.dispose();
    return super.close();
  }

  void initLiveCollection(String channelId, {String? aroundMessageId}) async {
    if (liveCollection != null) {
      liveCollection?.getStreamController().close();
      await liveCollection?.dispose();
    }
    
    MessageGetQueryBuilder query = AmityChatClient.newMessageRepository()
        .getMessages(channelId)
        .stackFromEnd(true)
        .includingTags([])
        .excludingTags([])
        .includeDeleted(true)
        .filterByParent(false);
    
    // Use aroundMessageId if provided to load messages around a specific message
    if (aroundMessageId != null) {
      query = query.aroundMessageId(aroundMessageId);
    }
    
    liveCollection = query.getLiveCollection();

    final list = await AmityChatClient.newChannelRepository()
        .membership(channelId)
        .getMembersFromCache();
    final otherMember = list
        .firstWhere((element) => element.userId != AmityCoreClient.getUserId());

    if (otherMember.user != null) {
      addEvent(ChatPageHeaderEventChanged(channelMember: otherMember));
      // User will be updated in the HeaderEventChanged handler
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

  /// Start progressive scroll animation to find and highlight target message
  /// 
  /// This method smoothly scrolls through the chat to locate a specific message
  /// identified by [targetMessageId]. Once found, the message will be highlighted
  /// with a bounce animation.
  void _startProgressiveScrollToTop(String targetMessageId) {
    // Only start scrolling if data is loaded and page is initialized
    if (!(!state.isFetching && state is! ChatPageStateInitial)) {
      _isJumpScrollInProgress = false;
      return;
    }
    
    if (!_scrollController.hasClients) {
      _isJumpScrollInProgress = false;
      add(const ChatPageSetAroundMessage(aroundMessageId: null));
      return;
    }
    
    final position = _scrollController.position;
    final maxScrollExtent = position.maxScrollExtent;
    
    if (maxScrollExtent > 0) {
      _isJumpScrollInProgress = true;
      
      // Use linear curve for smoother and more predictable scrolling
      _scrollController.animateTo(
        maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      ).then((_) {
        _isJumpScrollInProgress = false;
      });
    } else {
      _isJumpScrollInProgress = false;
      add(const ChatPageSetAroundMessage(aroundMessageId: null));
    }
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
