part of 'my_community_bloc.dart';

class MyCommunityState extends Equatable {
  const MyCommunityState();

  @override
  List<Object?> get props => [];
}

class MyCommunityLoading extends MyCommunityState {}

class MyCommunityLoaded extends MyCommunityState {
  final List<AmityCommunity> list;
  final bool hasMoreItems;
  final bool isFetching;

  const MyCommunityLoaded(
      {required this.list,
      required this.hasMoreItems,
      required this.isFetching});

  MyCommunityLoaded copyWith({
    List<AmityCommunity>? list,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return MyCommunityLoaded(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching];
}
