part of 'info_text_field_bloc.dart';

class InfoTextFieldEvent extends Equatable {
  final String text;

  const InfoTextFieldEvent(this.text);

  @override
  List<Object> get props => [text];
}