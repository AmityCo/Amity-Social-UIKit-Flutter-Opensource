part of 'post_composer_bloc.dart';

abstract class PostComposerEvent extends Equatable {
  const PostComposerEvent();

  @override
  List<Object> get props => [];
}

class PostComposerSelectImagesEvent extends PostComposerEvent {
  final XFile selectedImage;

  const PostComposerSelectImagesEvent({required this.selectedImage});

  PostComposerSelectImagesEvent copyWith({
    AmityFileInfoWithUploadStatus? selectedImage,
  }) {
    return PostComposerSelectImagesEvent(
      selectedImage: this.selectedImage,
    );
  }

  @override
  get props => [selectedImage];
}

class PostComposerSelectVideosEvent extends PostComposerEvent {
  final XFile selectedVideos;

  const PostComposerSelectVideosEvent({required this.selectedVideos});

  PostComposerSelectVideosEvent copyWith({
    AmityFileInfoWithUploadStatus? selectedVideos,
  }) {
    return PostComposerSelectVideosEvent(
      selectedVideos: this.selectedVideos,
    );
  }

  @override
  get props => [selectedVideos];
}

class PostComposerTextChangeEvent extends PostComposerEvent {
  final String text;

  const PostComposerTextChangeEvent({
    required this.text,
  });
}

class PostComposerDeleteFileEvent extends PostComposerEvent {
  final String filePath;

  const PostComposerDeleteFileEvent({required this.filePath});

  PostComposerDeleteFileEvent copyWith({
    AmityFileInfoWithUploadStatus? fileInfo,
  }) {
    return PostComposerDeleteFileEvent(
      filePath: this.filePath,
    );
  }

  @override
  get props => [filePath];
}

class PostComposerGetImageUrlsEvent extends PostComposerEvent {
  final List<String> urls;

  const PostComposerGetImageUrlsEvent({required this.urls});

  PostComposerGetImageUrlsEvent copyWith({
    List<String>? url,
  }) {
    return PostComposerGetImageUrlsEvent(
      urls: this.urls,
    );
  }

  @override
  List<Object> get props => [urls];
}

class PostComposerGetVideoUrlsEvent extends PostComposerEvent {
  final List<VideoData> videos;

  const PostComposerGetVideoUrlsEvent({required this.videos});

  PostComposerGetVideoUrlsEvent copyWith({
    List<String>? url,
  }) {
    return PostComposerGetVideoUrlsEvent(
      videos: this.videos,
    );
  }

  @override
  List<Object> get props => [videos];
}