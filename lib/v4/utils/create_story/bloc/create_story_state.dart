part of 'create_story_bloc.dart';

abstract class CreateStoryState extends Equatable {
  const CreateStoryState();
  
  @override
  List<Object> get props => [];
}

class CreateStoryInitial extends CreateStoryState {}

class CreateStorySuccess extends CreateStoryState {
}

class CreateStoryLoading extends CreateStoryState {
}

class CreateStoryFailure extends CreateStoryState {
}
