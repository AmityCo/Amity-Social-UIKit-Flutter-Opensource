import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/user/feed/user_feed_empty_state_info.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_image_feed_events.dart';
part 'user_image_feed_state.dart';

class UserImageFeedBloc extends Bloc<UserImageFeedEvent, UserImageFeedState> {
  final String userId;
  final ScrollController scrollController;
  late final PostLiveCollection feedLiveCollection;

  UserImageFeedBloc({required this.userId, required this.scrollController})
      : super(const UserImageFeedState()) {
    feedLiveCollection = AmitySocialClient.newPostRepository()
        .getPosts()
        .targetUser(userId)
        .sortBy(AmityPostSortOption.LAST_CREATED)
        .types([AmityDataType.IMAGE]).getLiveCollection();

    on<UserImageFeedEventPostUpdated>((event, emit) async {
      emit(state.copyWith(posts: event.posts, emptyState: event.emptyState));
    });

    on<UserImageFeedEventLoadingStateUpdated>((event, emit) async {
      emit(state.copyWith(isLoading: event.isLoading));
    });

    on<UserImageFeedEventJoinedStateUpdated>((event, emit) async {
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
      addEvent(UserImageFeedEventPostUpdated(
          posts: posts,
          emptyState: posts.isEmpty ? UserFeedEmptyStateType.empty : null));
    });

    feedLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(UserImageFeedEventLoadingStateUpdated(isLoading: isLoading));
    });

    feedLiveCollection.onError((error, stackTrace) {
      if (error != null && error is AmityException) {
        if (error.code ==
            error.getErrorCode(AmityErrorCode.NO_USER_ACCESS_PERMISSION)) {
          addEvent(const UserImageFeedEventPostUpdated(
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
