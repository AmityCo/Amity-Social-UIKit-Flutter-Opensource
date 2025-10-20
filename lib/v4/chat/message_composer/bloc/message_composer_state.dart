part of 'message_composer_bloc.dart';

class MessageComposerState extends Equatable {

  final TextEditingController controller;
  final ScrollController scrollController;
  final String text;
  final AmityMessage? replyTo;
  final bool showMediaSection;
  final String appName;

  const MessageComposerState({
    required this.controller,
    required this.scrollController,
    required this.text,
    required this.replyTo,
    required this.showMediaSection,
    required this.appName,
  });
  @override
  List<Object?> get props => [text, replyTo, showMediaSection, appName];

  MessageComposerState copyWith({
    TextEditingController? controller,
    ScrollController? scrollController,
    String? text,
    AmityMessage? replyTo,
    bool? showMediaSection,
    String? appName,
  }) {
    return MessageComposerState(
      controller: controller ?? this.controller,
      scrollController: scrollController ?? this.scrollController,
      text: text ?? this.text,
      replyTo: replyTo ?? this.replyTo,
      showMediaSection: showMediaSection ?? this.showMediaSection,
      appName: appName ?? this.appName,
    );
  }
}
