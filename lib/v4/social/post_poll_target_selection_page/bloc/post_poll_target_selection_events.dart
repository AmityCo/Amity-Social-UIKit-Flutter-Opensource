part of 'post_poll_target_selection_bloc.dart';

abstract class PostPollTargetSelectionEvent extends Equatable {
  const PostPollTargetSelectionEvent();

  @override
  List<Object> get props => [];
}

class PostTargetSelectionEventInitial extends PostPollTargetSelectionEvent {}

class PostTargetSelectionEventLoadMore extends PostPollTargetSelectionEvent {}

class CommunitiesLoadedEvent extends PostPollTargetSelectionEvent {
  final List<AmityCommunity> communities;
  final bool hasMoreItems;
  final bool isFetching;

  const CommunitiesLoadedEvent({
    required this.communities,
    required this.hasMoreItems,
    required this.isFetching,
  });
}
