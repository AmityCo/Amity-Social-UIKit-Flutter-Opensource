import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
enum SearchTab { chat, message }

class AmitySearchChannelState extends Equatable {
  final List<AmityChannel> channels;
  final List<AmityMessage> messages;
  final Map<int, AmityMessage>
      indexToMessageMap; // Maps channel index to corresponding message
  final Map<String, AmityChannelMember?>
      channelMembers; // Maps channelId to other participant
  final bool isLoading;
  final bool isLoadingMore;
  final String query;
  final String
      lastValidSearchText; // Tracks the last search text that was 3+ characters
  final List<String> archivedChannelIds;
  final SearchTab activeTab;

  const AmitySearchChannelState({
    this.channels = const [],
    this.messages = const [],
    this.indexToMessageMap = const {},
    this.channelMembers = const {},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.query = '',
    this.lastValidSearchText = '',
    this.archivedChannelIds = const [],
    this.activeTab = SearchTab.chat,
  });

  AmitySearchChannelState copyWith({
    List<AmityChannel>? channels,
    List<AmityMessage>? messages,
    Map<int, AmityMessage>? indexToMessageMap,
    Map<String, AmityChannelMember?>? channelMembers,
    bool? isLoading,
    bool? isLoadingMore,
    String? query,
    String? lastValidSearchText,
    List<String>? archivedChannelIds,
    SearchTab? activeTab,
  }) {
    return AmitySearchChannelState(
      channels: channels ?? this.channels,
      messages: messages ?? this.messages,
      indexToMessageMap: indexToMessageMap ?? this.indexToMessageMap,
      channelMembers: channelMembers ?? this.channelMembers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      query: query ?? this.query,
      lastValidSearchText: lastValidSearchText ?? this.lastValidSearchText,
      archivedChannelIds: archivedChannelIds ?? this.archivedChannelIds,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  @override
  List<Object?> get props => [
        channels,
        messages,
        indexToMessageMap,
        channelMembers,
        isLoading,
        isLoadingMore,
        query,
        lastValidSearchText,
        archivedChannelIds,
        activeTab
      ];

  /// Check if a channel is archived
  bool isChannelArchived(String channelId) {
    return archivedChannelIds.contains(channelId);
  }

  /// Get the search message for a specific channel index (when in message search mode)
  AmityMessage? getSearchMessageForIndex(int index) {
    return indexToMessageMap[index];
  }
}

// Cubit
class AmityChatSearchCubit extends Cubit<AmitySearchChannelState> {
  AmityChatSearchCubit() : super(const AmitySearchChannelState()) {
    _fetchArchivedChannelIds();
  }

  SearchChannelLiveCollection? _channelLiveCollection;
  StreamSubscription<List<AmityChannel>>? _channelStreamSubscription;
  StreamSubscription<bool>? _channelLoadingSubscription;

  SearchMessageLiveCollection?
      _messageLiveCollection; // SearchMessageLiveCollection (follows channel pattern)
  StreamSubscription<List<AmityMessage>>? _messageStreamSubscription;
  StreamSubscription<bool>? _messageLoadingSubscription;

  void _fetchArchivedChannelIds() {
    AmityChatClient.newChannelRepository()
        .getArchivedChannelIds()
        .then((value) {
      emit(state.copyWith(archivedChannelIds: value));
    }).catchError((error) {
    });
  }

  void markChannelAsArchived(String channelId) {
    if (!state.archivedChannelIds.contains(channelId)) {
      final updatedIds = List<String>.from(state.archivedChannelIds)
        ..add(channelId);
      emit(state.copyWith(archivedChannelIds: updatedIds));
    }
  }

  /// Public method to mark a channel as unarchived in our local state
  /// No need to fetch from server again
  void markChannelAsUnarchived(String channelId) {
    if (state.archivedChannelIds.contains(channelId)) {
      final updatedIds = List<String>.from(state.archivedChannelIds)
        ..remove(channelId);
      emit(state.copyWith(archivedChannelIds: updatedIds));
    }
  }

  /// Switch between Chat and Message tabs
  void changeTab(SearchTab tab) {
    if (tab != state.activeTab) {
      // First cleanup any existing search
      _cleanupPreviousSearch();
      
      // Clear current results and set new tab
      emit(state.copyWith(
        activeTab: tab,
        channels: [],
        messages: [],
        indexToMessageMap: {},
        channelMembers: {},
        isLoading: false,
      ));

      // Force a fresh search for the new tab if we have a query
      if (state.query.isNotEmpty && state.query.length >= 3) {
        searchChats(state.query);
      }
    }
  }

  @override
  Future<void> close() {
    _channelStreamSubscription?.cancel();
    _channelLoadingSubscription?.cancel();

    _channelLiveCollection?.dispose();
    _messageStreamSubscription?.cancel();
    _messageLiveCollection?.dispose();
    _messageLoadingSubscription?.cancel();

    return super.close();
  }

  void searchChats(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(
          query: query,
          channels: [],
          messages: [],
          indexToMessageMap: {},
          channelMembers: {},
          isLoading: false));
      _cleanupPreviousSearch();
      return;
    }

    if (query.length < 3) {
      emit(state.copyWith(query: query, isLoading: false));
      return;
    }

    emit(state.copyWith(
        isLoading: true, query: query, lastValidSearchText: query));

    _cleanupPreviousSearch();

    try {
      if (state.activeTab == SearchTab.chat) {
        // Search for channels
        _channelLiveCollection = AmityChatClient.newChannelRepository()
            .searchChannels()
            .withQuery(query)
            .types([AmityChannelType.CONVERSATION, AmityChannelType.COMMUNITY])
            .memberOnly(false)
            .sortBy("lastActivity")
            .getLiveCollection();

        _channelLoadingSubscription =
            _channelLiveCollection?.observeLoadingState().listen((isLoading) {          

          emit(state.copyWith(
            isLoading: isLoading,
            isLoadingMore: isLoading ? state.isLoadingMore : false, // Reset isLoadingMore when not loading
          ));
        });
        _channelStreamSubscription = _channelLiveCollection
            ?.getStreamController()
            .stream
            .listen((event) {          

          emit(state.copyWith(
            channels: event,
            indexToMessageMap: {},
            isLoading: state.isLoading,
            isLoadingMore: false, // Reset isLoadingMore when new data arrives
          ));

          // Fetch channel members for conversation channels
          _fetchChannelMembers(event);
        });
        _channelLiveCollection?.reset();
        _channelLiveCollection?.loadNext();
      } else {
        // Search for messages using message repository
        _messageLiveCollection = AmityChatClient.newMessageRepository()
            .searchMessage()
            .withQuery(query)
            .getLiveCollection();

        _messageLoadingSubscription =
            _messageLiveCollection?.observeLoadingState().listen((isLoading) {
          emit(state.copyWith(
            isLoading: isLoading,
            isLoadingMore: isLoading ? state.isLoadingMore : false, // Reset isLoadingMore when not loading
          ));
        });

        _messageStreamSubscription = _messageLiveCollection
            ?.getStreamController()
            .stream
            .listen((event) {

          // Create a list of channels where each message becomes a channel entry
          // This allows us to display the same channel multiple times (once per message)
          final List<AmityChannel> channelsForDisplay = [];
          final Map<int, AmityMessage> indexToMessageMapping = {};

          for (int i = 0; i < event.length; i++) {
            final message = event[i];
            // Use the message.channel property you mentioned is now available            
            if (message.channel != null) {
              // Add the same channel for each message found
              // The UI will show this as a channel entry, but it represents a message
              channelsForDisplay.add(message.channel!);
              // Map the channel index to its corresponding message
              indexToMessageMapping[i] = message;
            }
          }

          emit(state.copyWith(
            messages: event,
            channels:
                channelsForDisplay, // Each message becomes a channel entry

            indexToMessageMap: indexToMessageMapping,
            isLoading: state.isLoading,
            isLoadingMore: false, // Reset isLoadingMore when new data arrives
          ));

          // Fetch channel members for conversation channels in message search too
          _fetchChannelMembers(channelsForDisplay);
        });
        _messageLiveCollection?.reset();
        _messageLiveCollection?.loadNext();
      }
    } catch (e) {
      // Handle any errors
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Fetch channel members for conversation channels to get display names
  void _fetchChannelMembers(List<AmityChannel> channels) async {
    final conversationChannels = channels
        .where((channel) =>
            channel.amityChannelType == AmityChannelType.CONVERSATION &&
            !state.channelMembers.containsKey(channel.channelId))
        .toList();

    if (conversationChannels.isEmpty) return;

    var membersMap =
        Map<String, AmityChannelMember?>.from(state.channelMembers);

    for (final channel in conversationChannels) {
      final channelId = channel.channelId ?? "";
      if (channelId.isEmpty) continue;

      try {
        final List<AmityChannelMember?> members =
            await AmityChatClient.newChannelRepository()
                .membership(channelId)
                .getMembersFromCache();

        // Get other participant for this channel (not the current user)
        AmityChannelMember? otherMember;
        for (var i = 0; i < members.length; i++) {
          if (members[i]?.userId != AmityCoreClient.getUserId()) {
            otherMember = members[i];
            break;
          }
        }

        membersMap[channelId] = otherMember;
      } catch (e) {
        membersMap[channelId] = null;
      }
    }

    emit(state.copyWith(channelMembers: membersMap));
  }

  void loadMore() {
    // Don't load more if already loading more or initial loading
    if (state.isLoadingMore || state.isLoading) return;
    
    emit(state.copyWith(isLoadingMore: true));
    
    if (state.activeTab == SearchTab.chat) {
      // Load more channels
      if (_channelLiveCollection != null &&
          _channelLiveCollection!.hasNextPage()) {
        _channelLiveCollection!.loadNext();
      } else {
        // No more pages available, stop loading
        emit(state.copyWith(isLoadingMore: false));
      }
    } else {
      // Load more messages
      if (_messageLiveCollection != null &&
          _messageLiveCollection!.hasNextPage()) {
        _messageLiveCollection!.loadNext();
      } else {
        // No more pages available, stop loading
        emit(state.copyWith(isLoadingMore: false));
      }
    }
  }

  void _cleanupPreviousSearch() {
    // Clean up previous subscription and collection
    _channelStreamSubscription?.cancel();
    _channelStreamSubscription = null;
    _channelLiveCollection?.dispose();
    _channelLiveCollection = null;
    _channelLoadingSubscription?.cancel();
    _channelLoadingSubscription = null;

    _messageLoadingSubscription?.cancel();
    _messageLoadingSubscription = null;

    _messageStreamSubscription?.cancel();
    _messageStreamSubscription = null;
    _messageLiveCollection?.dispose();
    _messageLiveCollection = null;
  }
}
