import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'amity_message_report_component.dart';

part 'amity_message_report_state.dart';

class AmityMessageReportCubit extends Cubit<AmityMessageReportState> {
  final TextEditingController textController = TextEditingController();

  AmityMessageReportCubit() : super(const AmityMessageReportState()) {
    // Listen to text controller changes for the "Others" text input
    textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    emit(state.copyWith(othersText: textController.text));
  }

  void selectReason(AmityContentFlagReason reason) {
    emit(state.copyWith(selectedReason: reason));
  }

  void clearSelection() {
    emit(state.copyWith(selectedReason: null));
  }

  void setOthersText(String text) {
    textController.text = text;
    emit(state.copyWith(othersText: text));
  }

  void clearOthersText() {
    textController.clear();
    emit(state.copyWith(othersText: ''));
  }

  void reset() {
    textController.clear();
    emit(const AmityMessageReportState());
  }

  @override
  Future<void> close() {
    textController.dispose();
    return super.close();
  }
}
