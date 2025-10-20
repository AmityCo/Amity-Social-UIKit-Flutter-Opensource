part of 'message_composer_bloc.dart';

abstract class MessageComposerEvent extends Equatable {
  const MessageComposerEvent();

  @override
  List<Object> get props => [];
}

class MessageComposerTextChange extends MessageComposerEvent {
  final String text;

  const MessageComposerTextChange({required this.text});

  @override
  List<Object> get props => [text];
}

class MessageComposerCreateTextMessage extends MessageComposerEvent {
  final String text;
  final String? parentId;
  final List<AmityUserMentionMetadata> mentionMetadataList;
  final List<String> mentionUserIds;

  const MessageComposerCreateTextMessage({
    required this.text, 
    this.parentId, 
    this.mentionMetadataList = const [], 
    this.mentionUserIds = const []
  });

  @override
  List<Object> get props => [text];
}

class MessageComposerUpdateTextMessage extends MessageComposerEvent {
  final String text;
  final String messageId;
  final List<AmityUserMentionMetadata> mentionMetadataList;
  final List<String> mentionUserIds;

  const MessageComposerUpdateTextMessage({
    required this.text, 
    required this.messageId, 
    this.mentionMetadataList = const [], 
    this.mentionUserIds = const []
  });

  @override
  List<Object> get props => [text, messageId];
}

class MessageComposerMediaExpanded extends MessageComposerEvent {}

class MessageComposerMediaCollapsed extends MessageComposerEvent {}

class MessageComposerGetAppName extends MessageComposerEvent {}

class MessageComposerSelectImageAndVideoEvent extends MessageComposerEvent {
  final XFile selectedMedia;
  final bool fromCamera;

  const MessageComposerSelectImageAndVideoEvent(
      {required this.selectedMedia, this.fromCamera = false});

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
