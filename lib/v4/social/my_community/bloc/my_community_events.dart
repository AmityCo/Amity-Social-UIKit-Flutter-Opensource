part of 'my_community_bloc.dart';

abstract class MyCommunityEvent extends Equatable {
  const MyCommunityEvent();

  @override
  List<Object> get props => [];
}

class MyCommunityEventInitial extends MyCommunityEvent {}

class MyCommunityEventLoadMore extends MyCommunityEvent {}

class MyCommunityEventLoading extends MyCommunityEvent {}

class MyCommunityEventLoaded extends MyCommunityEvent {
  final MyCommunityLoaded loadedState;

  const MyCommunityEventLoaded(this.loadedState);

  @override
  List<Object> get props => [loadedState];
}
