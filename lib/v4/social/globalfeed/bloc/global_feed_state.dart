part of 'global_feed_bloc.dart';

class GlobalFeedState extends Equatable {
  final List<AmityPost> list;
  final bool hasMoreItems;
  final bool isFetching;

  const GlobalFeedState({required this.list, required this.hasMoreItems, required this.isFetching});

  GlobalFeedState copyWith({
    List<AmityPost>? list,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return GlobalFeedState(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching];
}
