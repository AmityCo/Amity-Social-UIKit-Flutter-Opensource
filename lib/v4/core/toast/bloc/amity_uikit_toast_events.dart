part of 'amity_uikit_toast_bloc.dart';

abstract class AmityToastEvent extends Equatable {
  const AmityToastEvent();

  @override
  List<Object> get props => [];
}

class AmityToastShort extends AmityToastEvent {
  final String message;
  final AmityToastIcon? icon;
  final double? bottomPadding;

  const AmityToastShort({required this.message, this.icon, this.bottomPadding});

  @override
  List<Object> get props => [message,icon ?? '', bottomPadding ?? 0.0];
}

class AmityUIKitToastLong extends AmityToastEvent {
  final String message;
  final double? bottomPadding;

  const AmityUIKitToastLong({required this.message, this.bottomPadding});

  @override
  List<Object> get props => [message, bottomPadding ?? 0.0];
}


class AmityToastLoading extends AmityToastEvent {
  final String message;
  final AmityToastIcon? icon;
  final double? bottomPadding;

  const AmityToastLoading({required this.message, required this.icon, this.bottomPadding});

  @override
  List<Object> get props => [message, icon ?? '', bottomPadding ?? 0.0];
}


class AmityToastDismiss extends AmityToastEvent {}