import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_empty_state_info.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_feed_events.dart';
part 'user_feed_state.dart';

class UserFeedBloc extends Bloc<UserFeedEvent, UserFeedState> {
  final String userId;
  final ScrollController scrollController;
  late final PostLiveCollection feedLiveCollection;

  UserFeedBloc({required this.userId, required this.scrollController})
      : super(const UserFeedState()) {
    feedLiveCollection = AmitySocialClient.newPostRepository()
        .getPosts()
        .targetUser(userId)
        .sortBy(AmityPostSortOption.LAST_CREATED)
        .getLiveCollection();

    on<UserFeedEventPostUpdated>((event, emit) async {
      emit(state.copyWith(posts: event.posts, emptyState: event.emptyState));
    });

    on<UserFeedEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    feedLiveCollection.loadNext();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        feedLiveCollection.loadNext();
      }
    });

    feedLiveCollection.getStreamController().stream.listen((posts) {
      addEvent(UserFeedEventPostUpdated(
          posts: posts,
          emptyState: posts.isEmpty ? UserFeedEmptyStateType.empty : null));
    });

    feedLiveCollection.onError((error, stackTrace) {
      if (error != null && error is AmityException) {
        if (error.code ==
            error.getErrorCode(AmityErrorCode.NO_USER_ACCESS_PERMISSION)) {
          addEvent(const UserFeedEventPostUpdated(
              posts: [], emptyState: UserFeedEmptyStateType.private));
        }
      }
    });

    feedLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(UserFeedEventLoadingStateUpdated(isLoading: isLoading));
    });
  }

  @override
  Future<void> close() {
    feedLiveCollection.dispose();
    return super.close();
  }
}
