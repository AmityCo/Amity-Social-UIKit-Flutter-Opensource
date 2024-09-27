part of 'reaction_list_bloc.dart';

// Define States
abstract class ReactionListState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReactionListLoading extends ReactionListState {}

class ReactionListLoaded extends ReactionListState {
  final List<AmityReaction> list;
  final bool hasMoreItems;
  final bool isFetching;

  ReactionListLoaded(
      {required this.list,
      required this.hasMoreItems,
      required this.isFetching});

  ReactionListLoaded copyWith({
    List<AmityReaction>? list,
    bool? hasMoreItems,
    bool? isFetching,
  }) {
    return ReactionListLoaded(
      list: list ?? this.list,
      hasMoreItems: hasMoreItems ?? this.hasMoreItems,
      isFetching: isFetching ?? this.isFetching,
    );
  }

  @override
  List<Object> get props => [list, hasMoreItems, isFetching];
}

class ReactionListStateInitial extends ReactionListState {}
