part of 'post_target_selection_bloc.dart';

abstract class PostTargetSelectionEvent extends Equatable {
  const PostTargetSelectionEvent();

  @override
  List<Object> get props => [];
}

class PostTargetSelectionEventInitial extends PostTargetSelectionEvent {}

class PostTargetSelectionEventLoadMore extends PostTargetSelectionEvent {}

class CommunitiesLoadedEvent extends PostTargetSelectionEvent {
  final List<AmityCommunity> communities;
  final bool hasMoreItems;
  final bool isFetching;

  const CommunitiesLoadedEvent({
    required this.communities,
    required this.hasMoreItems,
    required this.isFetching,
  });
}
