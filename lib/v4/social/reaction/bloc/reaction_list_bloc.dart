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

  /// Per-reaction counts read off the message, or null while they have not been
  /// read yet. Null and empty are different states: empty means the message has
  /// no reactions left and the sheet must show its empty state, while null means
  /// the header simply does not know yet and must draw nothing (PDT-5145).
  Map<String, int>? _reactionMap;
  List<AmityReaction> _lastLoadedList = []; // Store the last loaded list

  /// True once the collection has delivered a settled result — empty or not.
  /// Before that, an empty emission means "still loading the first page";
  /// after it, an empty emission means there is nothing left (PDT-5145 case 2).
  bool _hasSettledOnce = false;

  /// Guards against overlapping count refreshes.
  bool _refreshingCounts = false;

  /// Whether an empty emission from the collection could still be followed by
  /// data.
  ///
  /// The message's own counts answer it: for the All tab that is the total, for
  /// a single-reaction tab the count of that reaction. Zero means the empty
  /// result is the answer, so the sheet settles on its empty state instead of
  /// keeping the skeleton. Until the counts have been read there is nothing to
  /// compare against, and only the very first emission is treated as loading.
  bool get _mayStillBeLoading {
    final counts = _reactionMap;
    if (counts == null) return !_hasSettledOnce;
    return _expectedCount(counts) > 0;
  }

  /// How many rows the message's own counts say the current query should
  /// return: the total on the All tab, that reaction's count on a single tab.
  int _expectedCount(Map<String, int> counts) => _currentReactionFilter == null
      ? counts.values.fold<int>(0, (a, b) => a + b)
      : (counts[_currentReactionFilter!] ?? 0);

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
      // A filter change starts a genuinely new first page.
      _hasSettledOnce = false;

      // If we have a previous list, emit a filtering state to keep the UI responsive
      if (_lastLoadedList.isNotEmpty && (_reactionMap?.isNotEmpty ?? false)) {
        emit(ReactionListFiltering(
          previousList: _lastLoadedList,
          reactionMap: _reactionMap!,
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
      if (_lastLoadedList.isEmpty || (_reactionMap?.isEmpty ?? true)) {
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
      _refreshMessageReactions(_referenceId);
    }

    // Setup the subscription for the collection
    _subscription = reactionLiveCollection
        .getStreamController()
        .stream
        .listen((reactions) async {
      // Something changed on the message; re-read its counts so the header
      // cannot go stale (PDT-5145 case 1).
      if (_referenceType == AmityReactionReferenceType.MESSAGE) {
        _refreshMessageReactions(_referenceId);
      }
      // An empty emission only keeps the skeleton up while more is genuinely
      // expected. The collection reports isFetching == true on that first empty
      // emission and then never emits again once there is nothing to fetch, so
      // trusting isFetching alone spins forever (PDT-5145 case 2).
      if (reactions.isEmpty &&
          reactionLiveCollection.isFetching == true &&
          _mayStillBeLoading) {
        // If we have a previous list, emit a filtering state to keep UI responsive
        if (_lastLoadedList.isNotEmpty && (_reactionMap?.isNotEmpty ?? false)) {
          emit(ReactionListFiltering(
            previousList: _lastLoadedList,
            reactionMap: _reactionMap!,
          ));
        } else {
          emit(ReactionListLoading(reactionMap: _reactionMap));
        }
      } else if (reactions.isNotEmpty) {
        _hasSettledOnce = true;
        // Save the loaded list for future filtering states
        _lastLoadedList = List<AmityReaction>.from(reactions);

        emit(ReactionListLoaded(
          list: reactions,
          hasMoreItems: reactionLiveCollection.hasNextPage(),
          isFetching: reactionLiveCollection.isFetching,
          reactionMap: _reactionMap,
        ));
      } else {
        _hasSettledOnce = true;
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

  /// Re-read the message's per-reaction counts.
  ///
  /// Called once when the sheet opens and again on every emission from the
  /// reaction collection — which is exactly when something changed. It used to
  /// be a single read at open time, so a reaction removed by anyone left the
  /// header showing the old number (PDT-5145 case 1).
  ///
  /// Deliberately a one-shot read rather than the message live object:
  /// `newMessageRepository().live.getMessage()` throws
  /// `type 'MessageRepoImpl' is not a subtype of type
  /// 'AmityObjectRepository<MessageHiveEntity, AmityMessage>'` in this SDK
  /// version and red-screens the sheet. Raised separately.
  Future<void> _refreshMessageReactions(String messageId) async {
    if (_refreshingCounts) return;
    _refreshingCounts = true;
    try {
      final amityMessage =
          await AmityChatClient.newMessageRepository().getMessage(messageId);
      final raw = amityMessage.reactions?.reactions ?? {};
      final counts =
          Map.fromEntries(raw.entries.where((entry) => entry.value > 0));
      _reactionMap = counts;

      // The counts say this query has nothing to return — the last reaction was
      // removed, or the selected tab's reaction is gone. Settle on the empty
      // state whatever the collection is doing: it emits once with
      // isFetching == true and then, having nothing to fetch, never again, so
      // waiting on it means waiting forever (PDT-5145 case 2).
      if (_expectedCount(counts) == 0) {
        final settled = state;
        final hasRows = settled is ReactionListLoaded && settled.list.isNotEmpty;
        // Unless rows are already on screen: then the message's counters
        // disagree with its own reaction list, and the rows are the better
        // answer.
        if (!hasRows) {
          _hasSettledOnce = true;
          _lastLoadedList = [];
          emit(ReactionListLoaded(
            list: const [],
            hasMoreItems: false,
            isFetching: false,
            reactionMap: counts,
          ));
          return;
        }
      }

      final current = state;
      if (current is ReactionListLoaded) {
        emit(ReactionListLoaded(
          list: current.list,
          hasMoreItems: current.hasMoreItems,
          isFetching: current.isFetching,
          reactionMap: _reactionMap,
        ));
      } else if (current is ReactionListLoading) {
        emit(ReactionListLoading(reactionMap: _reactionMap));
      } else if (current is ReactionListFiltering) {
        emit(ReactionListFiltering(
          previousList: current.previousList,
          reactionMap: counts,
        ));
      }
    } catch (_) {
      // Counts stop updating; the list itself is unaffected.
    } finally {
      _refreshingCounts = false;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
