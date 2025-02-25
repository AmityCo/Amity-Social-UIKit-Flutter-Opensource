part of 'info_text_field_bloc.dart';

// ignore: must_be_immutable
class InfoTextFieldState extends Equatable {
  String text;
  late TextEditingController controller;

  InfoTextFieldState(this.text) {
    controller = TextEditingController(text: text);
  }

  InfoTextFieldState copyWith({
    String? text,
    TextEditingController? controller,
  }) {
    return InfoTextFieldState(text ?? this.text)
      ..controller = controller ?? this.controller;
  }

  @override
  List<Object> get props => [text, controller];
}
