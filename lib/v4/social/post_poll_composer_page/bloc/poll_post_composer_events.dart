part of 'poll_post_composer_bloc.dart';


abstract class PollComposerEvent extends Equatable {
  const PollComposerEvent();

  @override
  List<Object?> get props => [];
}

class UpdateQuestionEvent extends PollComposerEvent {
  final String question;

  const UpdateQuestionEvent({required this.question});

  @override
  List<Object?> get props => [question];
}

class UpdateOptionsEvent extends PollComposerEvent {
  final List<String> options;

  const UpdateOptionsEvent({required this.options});

  @override
  List<Object?> get props => [options];
}

class UpdateMultipleChoiceEvent extends PollComposerEvent {
  final bool isMultipleChoice;

  const UpdateMultipleChoiceEvent({required this.isMultipleChoice});

  @override
  List<Object?> get props => [isMultipleChoice];
}

class UpdateDurationEvent extends PollComposerEvent {
  final int durationIndex;

  const UpdateDurationEvent({required this.durationIndex});

  @override
  List<Object?> get props => [durationIndex];
}

class UpdateCustomDateEvent extends PollComposerEvent {
  final DateTime customDate;

  const UpdateCustomDateEvent({required this.customDate});

  @override
  List<Object?> get props => [customDate];
}

class UpdatePostingStateEvent extends PollComposerEvent {
  final bool isPosting;

  const UpdatePostingStateEvent({required this.isPosting});

  @override
  List<Object?> get props => [isPosting];
}

class PostPollEvent extends PollComposerEvent {}
