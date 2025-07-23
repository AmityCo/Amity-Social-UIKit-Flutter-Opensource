import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'amity_message_report_reason_state.dart';

class AmityMessageReportReasonCubit extends Cubit<AmityMessageReportReasonState> {
  final AmityMessage? message;
  final Function()? onCancel;
  final Function()? onBack;
  final AmityToastBloc toastBloc;
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  AmityMessageReportReasonCubit({
    required this.message,
    required this.onCancel,
    required this.onBack,
    required this.toastBloc,
  }) : super(const AmityMessageReportReasonState()) {
    // Add listener to text controller to update button state
    textController.addListener(_onTextChanged);
    
    // Auto-focus the text field when the component loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    final currentLength = textController.text.length;
    final isValid = textController.text.trim().isNotEmpty;
    
    emit(state.copyWith(
      characterCount: currentLength,
      isSubmitEnabled: isValid,
    ));
  }

  /// Flags a message with the custom reason text
  Future<void> flagMessage() async {
    if (state.isSubmitting || textController.text.trim().isEmpty) return;

    emit(state.copyWith(isSubmitting: true));

    try {
      if (message?.user?.userId != null) {
        final messageId = message!.messageId ?? "";
        final customReason = textController.text.trim();

        // Flag the message with the custom reason
        await AmityChatClient.newMessageRepository().flagMessage(
            messageId: messageId,
            reason: AmityContentFlagReason.others(customReason));

        toastBloc.add(AmityToastShort(
            message: "Message reported.",
            icon: AmityToastIcon.success,
            bottomPadding: AmityChatPage.toastBottomPadding));

        emit(state.copyWith(isSubmitting: false, isSuccess: true));
        
        // Close the dialog after successful submission
        onCancel?.call();
      } else {
        _showErrorToast("Failed to report message. Please try again.");
        emit(state.copyWith(isSubmitting: false));
      }
    } catch (e) {
      _showErrorToast("Failed to report message. Please try again.");
      emit(state.copyWith(isSubmitting: false));
    }
  }

  void _showErrorToast(String message) {
    toastBloc.add(AmityToastShort(
        message: message,
        icon: AmityToastIcon.warning,
        bottomPadding: AmityChatPage.toastBottomPadding));
  }

  @override
  Future<void> close() {
    textController.dispose();
    focusNode.dispose();
    return super.close();
  }
}
