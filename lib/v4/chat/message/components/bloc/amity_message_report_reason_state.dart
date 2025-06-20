part of 'amity_message_report_reason_cubit.dart';

class AmityMessageReportReasonState extends Equatable {
  final int characterCount;
  final bool isSubmitEnabled;
  final bool isSubmitting;
  final bool isSuccess;

  const AmityMessageReportReasonState({
    this.characterCount = 0,
    this.isSubmitEnabled = false,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  AmityMessageReportReasonState copyWith({
    int? characterCount,
    bool? isSubmitEnabled,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return AmityMessageReportReasonState(
      characterCount: characterCount ?? this.characterCount,
      isSubmitEnabled: isSubmitEnabled ?? this.isSubmitEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        characterCount,
        isSubmitEnabled,
        isSubmitting,
        isSuccess,
      ];
}
