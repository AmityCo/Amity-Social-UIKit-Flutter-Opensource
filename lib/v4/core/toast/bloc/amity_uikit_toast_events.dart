part of 'amity_uikit_toast_bloc.dart';

abstract class AmityToastEvent extends Equatable {
  const AmityToastEvent();

  @override
  List<Object> get props => [];
}

class AmityToastShort extends AmityToastEvent {
  final String message;
  final AmityToastIcon? icon;

  const AmityToastShort({
    required this.message,
    this.icon,
  });

  @override
  List<Object> get props => [message, icon ?? ''];
}

class AmityUIKitToastLong extends AmityToastEvent {
  final String message;

  const AmityUIKitToastLong({required this.message});

  @override
  List<Object> get props => [message];
}


class AmityToastLoading extends AmityToastEvent {
  final String message;
  final AmityToastIcon? icon;

  const AmityToastLoading({required this.message, required this.icon});

  @override
  List<Object> get props => [message, icon ?? ''];
}


class AmityToastDismiss extends AmityToastEvent {}
