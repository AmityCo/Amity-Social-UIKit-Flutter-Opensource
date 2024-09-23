import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'global_feed_event.dart';
part 'global_feed_state.dart';

class GlobalFeedBloc extends Bloc<GlobalFeedEvent, GlobalFeedState> {
  late PagingController<AmityPost> _controller;

  final int pageSize = 20;
  GlobalFeedBloc()
      : super(const GlobalFeedState(
          list: [],
          hasMoreItems: true,
          isFetching: true,
        )) {
    _controller = PagingController(
      pageFuture: (token) => AmitySocialClient.newFeedRepository()
          .getCustomRankingGlobalFeed()
          .getPagingData(token: token, limit: pageSize),
      pageSize: pageSize,
    )..addListener(
        () {
          if (_controller.isFetching == true &&
              _controller.loadedItems.isEmpty) {
            emit(state.copyWith(isFetching: true));
          } else if (_controller.error == null) {
            // Distinct post list
            List<AmityPost> distinctList = _controller.loadedItems;
            final postIds = distinctList.map((post) => post.postId).toSet();
            distinctList.retainWhere((post) => postIds.remove(post.postId));
            emit(state.copyWith(
                list: _controller.loadedItems,
                hasMoreItems: _controller.hasMoreItems,
                isFetching: _controller.isFetching));
          }
        },
      );

    on<GlobalFeedInit>((event, emit) async {
      _controller.reset();
      _controller.fetchNextPage();
    });

    on<GlobalFeedFetch>((event, emit) async {
      if (_controller.hasMoreItems && !_controller.isFetching) {
        _controller.fetchNextPage();
      }
    });

    on<GlobalFeedReactToPost>((event, emit) async {
      AmityPost post = event.post;
      if (post.myReactions?.isNotEmpty ?? false) {
        await post.react().removeReaction(post.myReactions!.first);
      }
      await post.react().addReaction(event.reactionType);
    });

    on<GlobalFeedReloadThePost>((event, emit) async {
      var updatedPost =
          await AmitySocialClient.newPostRepository().getPost(event.postId);
      List<AmityPost> updatedList = [];
      for (var element in state.list) {
        if (element.postId == updatedPost.postId) {
          updatedList.add(updatedPost);
        } else {
          updatedList.add(element);
        }
      }
      emit(state.copyWith(list: updatedList));
    });
  }
}
