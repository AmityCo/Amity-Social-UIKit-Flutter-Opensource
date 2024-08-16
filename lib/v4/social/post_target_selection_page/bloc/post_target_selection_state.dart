part of 'post_target_selection_bloc.dart';

class PostTargetSelectionState extends Equatable {

  const PostTargetSelectionState();
  
  @override
  List<Object?> get props => [];
  
}

class PostTargetSelectionLoading extends PostTargetSelectionState {}

class PostTargetSelectionLoaded extends PostTargetSelectionState {
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