part of 'reaction_list_bloc.dart';

// Define Events
abstract class ReactionListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ReactionListEventInit extends ReactionListEvent {}

class ReactionListEventLoadMore extends ReactionListEvent {}

// New event for filtering by reaction name
class ReactionListEventFilterByName extends ReactionListEvent {
  final String? reactionName;  // null means "all" reactions
  
  ReactionListEventFilterByName(this.reactionName);
  
  @override
  List<Object> get props => [reactionName ?? 'all'];
}
