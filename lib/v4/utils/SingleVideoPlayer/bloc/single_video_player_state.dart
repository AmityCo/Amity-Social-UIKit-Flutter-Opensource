part of 'single_video_player_bloc.dart';

class SingleVideoPlayerState extends Equatable {
  final String? filePath;
  final String? fileUrl;
  final VideoPlayerController? videoController;

  const SingleVideoPlayerState({
    required this.filePath,
    required this.fileUrl,
    this.videoController,
  });

  SingleVideoPlayerState copyWith({
    required String? filePath,
    required String? fileUrl,
    VideoPlayerController? videoController,
  }) {
    return VideoPostPlayerStateLoaded(
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      videoController: videoController ?? this.videoController,
    );
  }

  @override
  List<Object?> get props => [filePath, fileUrl];
}

class VideoPostPlayerStateInitial extends SingleVideoPlayerState {
  VideoPostPlayerStateInitial(String? filePath, String? fileUrl)
      : super(filePath: filePath, fileUrl: fileUrl);
}

class VideoPostPlayerStateLoaded extends SingleVideoPlayerState {
  const VideoPostPlayerStateLoaded({
    filePath,
    fileUrl,
    videoController,
    initializeVideoPlayerFuture,
  }) : super(
          filePath: filePath,
          fileUrl: fileUrl,
          videoController: videoController,
        );
}
