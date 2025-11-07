import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State
class ChatSearchArchiveState extends Equatable {
  final bool isArchiving;
  final bool showArchiveErrorDialog;
  final String? errorTitle;
  final String? errorMessage;

  const ChatSearchArchiveState({
    this.isArchiving = false,
    this.showArchiveErrorDialog = false,
    this.errorTitle,
    this.errorMessage,
  });

  ChatSearchArchiveState copyWith({
    bool? isArchiving,
    bool? showArchiveErrorDialog,
    String? errorTitle,
    String? errorMessage,
  }) {
    return ChatSearchArchiveState(
      isArchiving: isArchiving ?? this.isArchiving,
      showArchiveErrorDialog: showArchiveErrorDialog ?? this.showArchiveErrorDialog,
      errorTitle: errorTitle ?? this.errorTitle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isArchiving, showArchiveErrorDialog, errorTitle, errorMessage];
}

// Cubit
class ChatSearchArchiveCubit extends Cubit<ChatSearchArchiveState> {
  final AmityToastBloc toastBloc;
  
  ChatSearchArchiveCubit({required this.toastBloc}) : super(const ChatSearchArchiveState());
  
  Future<bool> archiveChannel(
    String channelId, {
    required String successMessage,
    required String errorMessage,
    required String limitErrorTitle,
    required String limitErrorMessage,
  }) async {
    emit(state.copyWith(isArchiving: true));
    
    try {
      await AmityChatClient.newChannelRepository().archiveChannel(channelId);
      toastBloc.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));
      emit(state.copyWith(isArchiving: false));
      return true;
    } catch (error) {
      String errorString = error.toString();
      if (errorString.contains('Archive limit exceeded')) {
        emit(state.copyWith(
          isArchiving: false,
          showArchiveErrorDialog: true,
          errorTitle: limitErrorTitle,
          errorMessage: limitErrorMessage,
        ));
      } else {
        toastBloc.add(AmityToastShort(
            message: errorMessage, 
            icon: AmityToastIcon.warning));
        emit(state.copyWith(isArchiving: false));
      }
      return false;
    }
  }
  
  Future<bool> unarchiveChannel(
    String channelId, {
    required String successMessage,
    required String errorMessage,
  }) async {
    emit(state.copyWith(isArchiving: true));
    
    try {
      await AmityChatClient.newChannelRepository().unarchiveChannel(channelId);
      toastBloc.add(AmityToastShort(
          message: successMessage, icon: AmityToastIcon.success));
      emit(state.copyWith(isArchiving: false));
      return true;
    } catch (error) {
      toastBloc.add(AmityToastShort(
          message: errorMessage, 
          icon: AmityToastIcon.warning));
      emit(state.copyWith(isArchiving: false));
      return false;
    }
  }
  
  void resetDialogState() {
    emit(state.copyWith(
      showArchiveErrorDialog: false,
      errorTitle: null,
      errorMessage: null,
    ));
  }
}
