part of 'reaction_list_bloc.dart';

abstract class ReactionListState extends Equatable {
  final Map<String, int>? reactionMap;
  
  const ReactionListState({this.reactionMap});
  
  @override
  List<Object?> get props => [reactionMap];
}

class ReactionListStateInitial extends ReactionListState {
  ReactionListStateInitial() : super(reactionMap: null);
  
  @override
  List<Object?> get props => [];
}

class ReactionListLoading extends ReactionListState {
  ReactionListLoading({Map<String, int>? reactionMap}) : super(reactionMap: reactionMap);
  
  @override
  List<Object?> get props => [reactionMap];
}

// New filtering state that preserves both the reaction map and the previous list
class ReactionListFiltering extends ReactionListState {
  final List<AmityReaction> previousList; // Keep the previous list

  const ReactionListFiltering({
    required this.previousList, 
    required Map<String, int> reactionMap,
  }) : super(reactionMap: reactionMap);
  
  @override
  List<Object?> get props => [previousList, reactionMap];
}

class ReactionListLoaded extends ReactionListState {
  final List<AmityReaction> list;
  final bool hasMoreItems;
  final bool isFetching;

  const ReactionListLoaded({
    required this.list,
    required this.hasMoreItems, 
    required this.isFetching,
    Map<String, int>? reactionMap,
  }) : super(reactionMap: reactionMap);
  
  @override
  List<Object?> get props => [list, hasMoreItems, isFetching, reactionMap];
}
