import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'post_target_selection_events.dart';
part 'post_target_selection_state.dart';

class PostTargetSelectionBloc
    extends Bloc<PostTargetSelectionEvent, PostTargetSelectionState> {
  late CommunityLiveCollection communityLiveCollection;
  late StreamSubscription<List<AmityCommunity>> _subscription;

  final int postTargetsPageSize = AmityUIKit4Manager
      .freedomBehavior.createPostMenuComponentBehavior.postTargetsPageSize;
  final getPostTargets = AmityUIKit4Manager
      .freedomBehavior.createPostMenuComponentBehavior.getPostTargets;

  PostTargetSelectionBloc() : super(const PostTargetSelectionState()) {
    communityLiveCollection = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .getLiveCollection(pageSize: postTargetsPageSize);

    _subscription = communityLiveCollection
        .getStreamController()
        .stream
        .listen((communities) async {
      if (communityLiveCollection.isFetching == true && communities.isEmpty) {
        emit(PostTargetSelectionLoading());
      } else if (communities.isNotEmpty) {
        final List<AmityCommunity> postTargets = await getPostTargets(
          communities: communities,
        );
        add(CommunitiesLoadedEvent(
          communities: postTargets,
          hasMoreItems: communityLiveCollection.hasNextPage(),
          isFetching: communityLiveCollection.isFetching,
        ));
      }
    });

    on<CommunitiesLoadedEvent>((event, emit) async {
      emit(PostTargetSelectionLoaded(
        list: event.communities,
        hasMoreItems: event.hasMoreItems,
        isFetching: event.isFetching,
      ));
    });

    on<PostTargetSelectionEventInitial>((event, emit) async {
      communityLiveCollection.reset();
      communityLiveCollection.loadNext();
    });

    on<PostTargetSelectionEventLoadMore>((event, emit) async {
      if (communityLiveCollection.hasNextPage()) {
        communityLiveCollection.loadNext();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
