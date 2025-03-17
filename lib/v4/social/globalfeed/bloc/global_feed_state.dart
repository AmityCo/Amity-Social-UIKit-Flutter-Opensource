part of 'global_feed_bloc.dart';

class GlobalFeedState extends Equatable {
  final List<AmityPost> list;
  final List<AmityPost> localList;
  final bool hasMoreItems;
  final bool isFetching;
  final List<AmityPinnedPost> pinnedPosts;
  final Set<String> pinnedPostIds; // For quick access

  const GlobalFeedState({
    required this.list,
    required this.localList,
    required this.hasMoreItems,
    required this.isFetching,
    required this.pinnedPosts,
    required this.pinnedPostIds,
  });

  GlobalFeedState copyWith({
    List<AmityPost>? list,
    List<AmityPost>? localList,
    bool? hasMoreItems,
    bool? isFetching,
    List<AmityPinnedPost>? pinnedPosts,
    Set<String>? pinnedPostIds,
  }) {
    return GlobalFeedState(
      list: list ?? this.list,
      localList: localList ?? this.localList,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
      pinnedPosts: pinnedPosts ?? this.pinnedPosts,
      pinnedPostIds: pinnedPostIds ?? this.pinnedPostIds,
    );
  }

  @override
  List<Object> get props => [list, localList, hasMoreItems, isFetching, pinnedPosts, pinnedPostIds];
}
