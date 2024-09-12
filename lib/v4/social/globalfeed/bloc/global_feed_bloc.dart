import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'global_feed_event.dart';
part 'global_feed_state.dart';

class GlobalFeedBloc extends Bloc<GlobalFeedEvent, GlobalFeedState> {
  late CustomRankingLiveCollection liveCollection;

  final int pageSize = 20;
  GlobalFeedBloc()
      : super(const GlobalFeedState(
          list: [],
          localList: [],
          hasMoreItems: true,
          isFetching: false,
        )) {

    liveCollection = AmitySocialClient.newFeedRepository()
        .getCustomRankingGlobalFeed()
        .getLiveCollection();

    on<GlobalFeedListUpdated>((event, emit) async {
      final list = event.posts.toList();
      list.insertAll(0, state.localList);
      emit(state.copyWith(list: list, hasMoreItems: liveCollection.hasNextPage()));
    });

    on<GlobalFeedAddLocalPost>((event, emit) async {
      final post = event.post;
      final localList = state.localList.toList();
      localList.insert(0, post);
      final list = state.list.toList();
      list.insertAll(0, localList);
      emit(state.copyWith(localList: localList, list: list));
    });

    on<GlobalFeedInit>((event, emit) async {
      liveCollection.reset();
      liveCollection.loadNext();
    });

    on<GlobalFeedLoadNext>((event, emit) async {
      if (liveCollection.hasNextPage()) {
        liveCollection.loadNext();
      }
    });

    on<GlobalFeedLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isFetching: event.isLoading));
    });

    liveCollection.getStreamController().stream.listen((event) {
      if (!isClosed) {
        add(GlobalFeedListUpdated(posts: event));
      }
    });

    liveCollection.observeLoadingState().listen((isLoading) {
      if (!isClosed) {
        add(GlobalFeedLoadingStateUpdated(isLoading: isLoading));
      }
    });
  }

  @override
  Future<void> close() {
    liveCollection.dispose();
    return super.close();
  }
}
