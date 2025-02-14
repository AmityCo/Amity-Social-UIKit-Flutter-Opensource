part of 'post_poll_target_selection_bloc.dart';


class PostPollTargetSelectionState extends Equatable {

  const PostPollTargetSelectionState();

  @override
  List<Object?> get props => [];

}

class PostTargetSelectionLoading extends PostPollTargetSelectionState {}

class PostTargetSelectionLoaded extends PostPollTargetSelectionState {
  final List<AmityCommunity> list;
  final bool hasMoreItems;
  final bool isFetching;

  const PostTargetSelectionLoaded(
      {required this.list,
        required this.hasMoreItems,
        required this.isFetching});

  PostTargetSelectionLoaded copyWith({
    List<AmityCommunity>? list,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return PostTargetSelectionLoaded(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching];
}