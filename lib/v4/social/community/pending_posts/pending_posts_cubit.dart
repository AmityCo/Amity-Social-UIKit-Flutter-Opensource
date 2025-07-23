import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_posts_state.dart';

class PendingPostsCubit extends Cubit<PendingPostsState> {
  final AmityCommunity community;
  late final PostLiveCollection postLiveCollection;
  StreamSubscription<List<AmityPost>>? _postsSubscription;
  StreamSubscription<bool>? _loadingSubscription;

  PendingPostsCubit({
    required this.community,
  }) : super(PendingPostsState(
          isLoading: true,
          hasError: false,
          posts: const [],
          communityId: community.communityId!,
          isCheckingRole: true,
          isModerator: false,
        )) {
    getPendingCommunityFeedPosts();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    // If not joined, user can't be a moderator
    if (community.isJoined != true) {
      emit(state.copyWith(isCheckingRole: false, isModerator: false));
      return;
    }

    try {
      // Check if user has moderator role
      final roles = await community.getCurentUserRoles();
      final isModerator = roles.contains("community-moderator");

      // Update state with role check result and also set isLoading to false
      // since we've finished loading all required data
      emit(state.copyWith(
          isCheckingRole: false, isModerator: isModerator, isLoading: false));
    } catch (e) {
      // If there's an error checking roles, default to joined status
      // Also set isLoading to false to complete the loading state
      emit(state.copyWith(
        isCheckingRole: false,
        isModerator: false,
        isLoading: false,
      ));
    }
  }

  Future<void> getPendingCommunityFeedPosts() async {
    if (!state.isCheckingRole) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      postLiveCollection = AmitySocialClient.newPostRepository()
          .getPosts()
          .targetCommunity(community.communityId!)
          .feedType(AmityFeedType.REVIEWING)
          .sortBy(AmityPostSortOption.LAST_CREATED)
          .includeDeleted(false)
          .getLiveCollection();

      // Cancel existing subscriptions before creating new ones
      _loadingSubscription?.cancel();
      _postsSubscription?.cancel();

      // Subscribe to loading state changes
      _loadingSubscription =
          postLiveCollection.observeLoadingState().listen((isLoading) {
        // Only update isLoading if we're not checking role
        if (!state.isCheckingRole) {
          emit(state.copyWith(isLoading: isLoading));
        }
      });

      // Subscribe to data changes
      _postsSubscription =
          postLiveCollection.getStreamController().stream.listen((posts) {
        emit(state.copyWith(
          posts: posts,
          hasMoreData: postLiveCollection.hasNextPage(),
          isLoading: false,
        ));
      });

      // Reset and load data
      postLiveCollection.reset();
      postLiveCollection.loadNext();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      ));
    }
  }

  void loadMorePosts() {
    if (state.loadingMore && state.hasMoreData) return;

    emit(state.copyWith(loadingMore: true));
    try {
      // For LiveCollection, just call loadNext()
      postLiveCollection.loadNext();
    } catch (e) {
      emit(state.copyWith(
        loadingMore: false,
        hasError: true,
        errorMessage: "Failed to load more posts: ${e.toString()}",
      ));
    }
  }

  void handlePostAction(String postId, bool wasSuccessful) {
    if (wasSuccessful) {
      final updatedPosts = List<AmityPost>.from(
          state.posts.where((post) => post.postId != postId).toList());

      emit(state.copyWith(posts: updatedPosts));

      Future.microtask(() {
        emit(state.copyWith());
      });
    }
  }

  Future<void> recheckUserRole() async {
    emit(state.copyWith(isCheckingRole: true, isLoading: true));
    await _checkUserRole();
  }

  @override
  Future<void> close() {
    _loadingSubscription?.cancel();
    _postsSubscription?.cancel();
    return super.close();
  }
}
