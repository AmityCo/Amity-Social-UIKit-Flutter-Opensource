part of 'poll_post_composer_bloc.dart';

class PollComposerState extends Equatable {
  final String question;
  final List<String> options;
  final bool isMultipleChoice;
  final int selectedPollDurationIndex;
  final DateTime? customDate;
  final bool isPosting;
  final List<String> durationOptions;

  const PollComposerState({
    this.question = '',
    this.options = const ['', ''], // Default with two empty options
    this.isMultipleChoice = false,
    this.selectedPollDurationIndex = 4, // Default to the first duration option
    this.customDate,
    this.isPosting = false,
    this.durationOptions = const ['1 day', '3 days', '7 days', '14 days', '30 days'],
  });

  int get pollDurationInMilliseconds {
    if (selectedPollDurationIndex == -1 && customDate != null) {
      // Calculate duration from custom date
      final now = DateTime.now();
      final difference = customDate!.difference(now);
      return difference.isNegative ? 0 : difference.inMilliseconds;
    } else if (selectedPollDurationIndex >= 0 && selectedPollDurationIndex < durationOptions.length) {
      // Calculate duration from predefined options
      final days = int.parse(durationOptions[selectedPollDurationIndex].split(' ')[0]);
      return Duration(days: days).inMilliseconds;
    }
    return 0; // Default to 0 if no valid duration is found
  }

  PollComposerState copyWith({
    String? question,
    List<String>? options,
    bool? isMultipleChoice,
    int? selectedPollDurationIndex,
    DateTime? customDate,
    bool? isPosting,
    List<String>? durationOptions,
  }) {
    return PollComposerState(
      question: question ?? this.question,
      options: options ?? this.options,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      selectedPollDurationIndex: selectedPollDurationIndex ?? this.selectedPollDurationIndex,
      customDate: customDate ?? this.customDate,
      isPosting: isPosting ?? this.isPosting,
      durationOptions: durationOptions ?? this.durationOptions,
    );
  }

  @override
  List<Object?> get props => [
    question,
    options,
    isMultipleChoice,
    selectedPollDurationIndex,
    customDate,
    isPosting,
    durationOptions,
  ];
}

class PollComposerInitial extends PollComposerState {
  const PollComposerInitial()
      : super(
    question: '',
    options: const ['', ''],
    isMultipleChoice: false,
    selectedPollDurationIndex: 0,
    customDate: null,
    isPosting: false,
    durationOptions: const ['1 day', '3 days', '7 days', '14 days', '30 days'],
  );
}
