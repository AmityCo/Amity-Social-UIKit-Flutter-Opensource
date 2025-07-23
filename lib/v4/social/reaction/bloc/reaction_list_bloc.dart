import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'reaction_list_events.dart';
part 'reaction_list_state.dart';

class ReactionListBloc extends Bloc<ReactionListEvent, ReactionListState> {
  final int pageSize = 20;
  late ReactionLiveCollection reactionLiveCollection;
  late StreamSubscription<List<AmityReaction>> _subscription;
  Map<String, int> _reactionMap = {};
  List<AmityReaction> _lastLoadedList = []; // Store the last loaded list

  // Store the reference data to facilitate re-initialization
  final String _referenceId;
  final AmityReactionReferenceType _referenceType;
  String? _currentReactionFilter;

  ReactionListBloc(
      {required String referenceId,
      required AmityReactionReferenceType referenceType})
      : _referenceId = referenceId,
        _referenceType = referenceType,
        super(ReactionListStateInitial()) {
    _initReactionCollection();

    on<ReactionListEventInit>((event, emit) async {
      reactionLiveCollection.reset();
      reactionLiveCollection.loadNext();
    });

    on<ReactionListEventLoadMore>((event, emit) async {
      if (reactionLiveCollection.hasNextPage()) {
        reactionLiveCollection.loadNext();
      }
    });

    // Handle the filter by reaction name event
    on<ReactionListEventFilterByName>((event, emit) async {
      _currentReactionFilter = event.reactionName;

      // If we have a previous list, emit a filtering state to keep the UI responsive
      if (_lastLoadedList.isNotEmpty && _reactionMap.isNotEmpty) {
        emit(ReactionListFiltering(
          previousList: _lastLoadedList,
          reactionMap: _reactionMap,
        ));
      }

      // Cancel the existing subscription first
      await _subscription.cancel();

      // Re-initialize the reaction collection with the new filter
      _initReactionCollection();

      // Reset and load the new collection
      reactionLiveCollection.reset();
      reactionLiveCollection.loadNext();

      // We don't need to emit a loading state here since we've already emitted
      // ReactionListFiltering if we had previous data
      if (_lastLoadedList.isEmpty || _reactionMap.isEmpty) {
        emit(ReactionListLoading(reactionMap: _reactionMap));
      }
    });
  }

  // Method to initialize or re-initialize the reaction collection
  void _initReactionCollection() {
    if (_referenceType == AmityReactionReferenceType.POST) {
      var query = AmitySocialClient.newPostRepository()
          .getReaction(postId: _referenceId);

      if (_currentReactionFilter != null) {
        query = query.reactionName(_currentReactionFilter!);
      }

      reactionLiveCollection = query.getLiveCollection();
    } else if (_referenceType == AmityReactionReferenceType.COMMENT) {
      var query = AmitySocialClient.newCommentRepository()
          .getReaction(commentId: _referenceId);

      if (_currentReactionFilter != null) {
        query = query.reactionName(_currentReactionFilter!);
      }

      reactionLiveCollection = query.getLiveCollection();
    } else if (_referenceType == AmityReactionReferenceType.MESSAGE) {
      var query = AmityChatClient.newMessageRepository()
          .getReaction(messageId: _referenceId);

      if (_currentReactionFilter != null) {
        query = query.reactionName(_currentReactionFilter!);
      }

      reactionLiveCollection = query.getLiveCollection();

      // Only fetch reactions for messages since they support multiple reaction types
      _fetchMessageReactions(_referenceId);
    }

    // Setup the subscription for the collection
    _subscription = reactionLiveCollection
        .getStreamController()
        .stream
        .listen((reactions) async {
      if (reactionLiveCollection.isFetching == true && reactions.isEmpty) {
        // If we have a previous list, emit a filtering state to keep UI responsive
        if (_lastLoadedList.isNotEmpty && _reactionMap.isNotEmpty) {
          emit(ReactionListFiltering(
            previousList: _lastLoadedList,
            reactionMap: _reactionMap,
          ));
        } else {
          emit(ReactionListLoading(reactionMap: _reactionMap));
        }
      } else if (reactions.isNotEmpty) {
        // Save the loaded list for future filtering states
        _lastLoadedList = List<AmityReaction>.from(reactions);

        emit(ReactionListLoaded(
          list: reactions,
          hasMoreItems: reactionLiveCollection.hasNextPage(),
          isFetching: reactionLiveCollection.isFetching,
          reactionMap: _reactionMap,
        ));
      } else {
        // For empty results but not loading
        _lastLoadedList = [];
        emit(ReactionListLoaded(
          list: [],
          hasMoreItems: false,
          isFetching: false,
          reactionMap: _reactionMap,
        ));
      }
    });
  }

  // Updated method to fetch message reactions and store the reaction map
  Future<void> _fetchMessageReactions(String messageId) async {
    try {
      final messageRepository = AmityChatClient.newMessageRepository();
      final amityMessage = await messageRepository.getMessage(messageId);

      if (amityMessage.reactions?.reactions != null) {
        final rawReactionMap = amityMessage.reactions!.reactions!;

        // Filter reactions with positive counts
        _reactionMap = Map.fromEntries(
            rawReactionMap.entries.where((entry) => entry.value > 0));

        // Emit the state with the updated reaction map
        if (state is ReactionListLoaded) {
          final currentState = state as ReactionListLoaded;
          emit(ReactionListLoaded(
            list: currentState.list,
            hasMoreItems: currentState.hasMoreItems,
            isFetching: currentState.isFetching,
            reactionMap: _reactionMap,
          ));
        } else if (state is ReactionListLoading) {
          emit(ReactionListLoading(reactionMap: _reactionMap));
        }
      }
    } catch (e) {
      print('Error fetching message reactions: $e');
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
