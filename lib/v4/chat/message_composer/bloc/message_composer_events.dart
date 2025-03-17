part of 'message_composer_bloc.dart';

abstract class MessageComposerEvent extends Equatable {
  const MessageComposerEvent();

  @override
  List<Object> get props => [];
}

class MessageComposerTextChage extends MessageComposerEvent {
  final String text;

  const MessageComposerTextChage({required this.text});

  @override
  List<Object> get props => [text];
}

class  MessageComposerCreateTextMessage extends MessageComposerEvent {
  final String text;

  const MessageComposerCreateTextMessage({required this.text});

  @override
  List<Object> get props => [text];
}

class MessageComposerMediaExpanded extends MessageComposerEvent { }
class MessageComposerMediaCollapsed extends MessageComposerEvent { }
class MessageComposerGetAppName extends MessageComposerEvent { }


class MessageComposerSelectImageAndVideoEvent extends MessageComposerEvent {
  final XFile selectedMedia;
  final bool fromCamera;

  const MessageComposerSelectImageAndVideoEvent({required this.selectedMedia, this.fromCamera = false});

  MessageComposerSelectImageAndVideoEvent copyWith({
    AmityFileInfoWithUploadStatus? selectedImage,
    bool? fromCamera,
  }) {
    return MessageComposerSelectImageAndVideoEvent(
      selectedMedia: this.selectedMedia,
      fromCamera: fromCamera ?? this.fromCamera,
    );
  }

  @override
  get props => [selectedMedia, fromCamera];
}

class MessageComposerSelectVideosEvent extends MessageComposerEvent {
  final XFile selectedVideos;

  const MessageComposerSelectVideosEvent({required this.selectedVideos});

  MessageComposerSelectVideosEvent copyWith({
    AmityFileInfoWithUploadStatus? selectedVideos,
  }) {
    return MessageComposerSelectVideosEvent(
      selectedVideos: this.selectedVideos,
    );
  }

  @override
  get props => [selectedVideos];
}