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

  ReactionListBloc(
      {required String referenceId,
      required AmityReactionReferenceType referenceType})
      : super(ReactionListStateInitial()) {
    if (referenceType == AmityReactionReferenceType.POST) {
      reactionLiveCollection = AmitySocialClient.newPostRepository()
          .getReaction(postId: referenceId)
          .reactionName("like")
          .getLiveCollection();
    } else if (referenceType == AmityReactionReferenceType.COMMENT) {
      reactionLiveCollection = AmitySocialClient.newCommentRepository()
          .getReaction(commentId: referenceId)
          .reactionName("like")
          .getLiveCollection();
    }

    _subscription = reactionLiveCollection
        .getStreamController()
        .stream
        .listen((reactions) async {
      if (reactionLiveCollection.isFetching == true && reactions.isEmpty) {
        emit(ReactionListLoading());
      } else if (reactions.isNotEmpty) {
        var state = ReactionListLoaded(
          list: reactions,
          hasMoreItems: reactionLiveCollection.hasNextPage(),
          isFetching: reactionLiveCollection.isFetching,
        );

        emit(state);
      }
    });

    on<ReactionListEventInit>((event, emit) async {
      reactionLiveCollection.reset();
      reactionLiveCollection.loadNext();
    });

    on<ReactionListEventLoadMore>((event, emit) async {
      if (reactionLiveCollection.hasNextPage()) {
        reactionLiveCollection.loadNext();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
