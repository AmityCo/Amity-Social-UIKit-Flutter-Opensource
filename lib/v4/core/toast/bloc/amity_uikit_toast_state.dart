part of 'amity_uikit_toast_bloc.dart';

enum AmityToastStyle { hidden, short, long, persistent, loading }
// Short is 5 seconds toast, long is 10 seconds toast, persistent is toast that will not disappear until calling dismiss it  

class AmityToastState extends Equatable {
  const AmityToastState({
    required this.message,
    required this.style,
    this.icon,
    this.key,
    this.bottomPadding = 0.0,
  });

  final String message;
  final AmityToastStyle style;
  final AmityToastIcon? icon;
  final Key? key;
  final double bottomPadding;

  @override
  List<Object?> get props => [message, style, icon, key, bottomPadding];

  AmityToastState copyWith({
    AmityToastStyle? style,
    String? message,
    AmityToastIcon? icon,
    Key? key,
    double? bottomPadding,
  }) {
    return AmityToastState(
      message: message ?? this.message,
      style: style ?? this.style,
      icon: icon ?? this.icon,
      key: key ?? this.key,
      bottomPadding: bottomPadding ?? this.bottomPadding,
    );
  }
}