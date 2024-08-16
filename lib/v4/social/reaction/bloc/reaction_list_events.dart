part of 'reaction_list_bloc.dart';

// Define Events
abstract class ReactionListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ReactionListEventInit extends ReactionListEvent {}

class ReactionListEventLoadMore extends ReactionListEvent {}
