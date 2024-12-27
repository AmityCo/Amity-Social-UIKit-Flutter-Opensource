part of 'global_feed_bloc.dart';

class GlobalFeedState extends Equatable {
  final List<AmityPost> list;
  final List<AmityPost> localList;
  final bool hasMoreItems;
  final bool isFetching;

  const GlobalFeedState({
    required this.list,
    required this.localList,
    required this.hasMoreItems,
    required this.isFetching,
  });

  GlobalFeedState copyWith({
    List<AmityPost>? list,
    List<AmityPost>? localList,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return GlobalFeedState(
      list: list ?? this.list,
      localList: localList ?? this.localList,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, localList, hasMoreItems, isFetching];
}
