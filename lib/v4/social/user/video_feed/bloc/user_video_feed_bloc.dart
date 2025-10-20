import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_empty_state_info.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_video_feed_events.dart';
part 'user_video_feed_state.dart';

class UserVideoFeedBloc extends Bloc<UserVideoFeedEvent, UserVideoFeedState> {
  final String userId;
  final ScrollController scrollController;
  late final PostLiveCollection feedLiveCollection;

  UserVideoFeedBloc({required this.userId, required this.scrollController})
      : super(const UserVideoFeedState()) {
    feedLiveCollection = AmitySocialClient.newPostRepository()
        .getPosts()
        .targetUser(userId)
        .sortBy(AmityPostSortOption.LAST_CREATED)
        .types([AmityDataType.VIDEO]).getLiveCollection();

    on<UserVideoFeedEventPostUpdated>((event, emit) async {
      emit(state.copyWith(posts: event.posts, emptyState: event.emptyState));
    });

    on<UserVideoFeedEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<UserVideoFeedEventJoinedStateUpdated>((event, emit) async {
      emit(state.copyWith(isJoined: event.isJoined));
    });

    feedLiveCollection.loadNext();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        feedLiveCollection.loadNext();
      }
    });

    feedLiveCollection.getStreamController().stream.listen((posts) {
      addEvent(UserVideoFeedEventPostUpdated(posts: posts));
    });

    feedLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(UserVideoFeedEventLoadingStateUpdated(isLoading: isLoading));
    });

    feedLiveCollection.onError((error, stackTrace) {
      if (error != null && error is AmityException) {
        if (error.code ==
            error.getErrorCode(AmityErrorCode.NO_USER_ACCESS_PERMISSION)) {
          addEvent(const UserVideoFeedEventPostUpdated(
              posts: [], emptyState: UserFeedEmptyStateType.private));
        }
      }
    });
  }

  @override
  Future<void> close() {
    feedLiveCollection.dispose();
    return super.close();
  }
}
