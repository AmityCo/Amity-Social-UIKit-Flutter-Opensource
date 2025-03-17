part of 'video_message_player_bloc.dart';


class VideoMessagePlayerState extends Equatable {
  final AmityVideo video;
  final String videoUrl;
  final String thumbnailUrl;
  final VideoPlayerController? videoController;
  
  const  VideoMessagePlayerState({
    required this.video,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.videoController,
  });

   VideoMessagePlayerState copyWith({
    AmityVideo? video,
    String? videoUrl,
    String? thumbnailUrl,
    VideoPlayerController? videoController,
  }) {
    return  VideoMessagePlayerStateLoaded(
      video: video ?? this.video,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoController: videoController ?? this.videoController,
    );
  }

  @override
  List<Object?> get props => [videoUrl];
}

class  VideoMessagePlayerStateInitial extends  VideoMessagePlayerState {
   const VideoMessagePlayerStateInitial(AmityVideo video, String thumbnailUrl) : super(video: video, videoUrl: "", thumbnailUrl: thumbnailUrl);
}

class  VideoMessagePlayerStateLoaded extends  VideoMessagePlayerState {

  const  VideoMessagePlayerStateLoaded({
    required video,
    required videoUrl,
    required thumbnailUrl,
    required videoController,
    initializeVideoPlayerFuture,
  }) : super(
    video: video,
    videoUrl: videoUrl,
    thumbnailUrl: thumbnailUrl,
    videoController: videoController,
  );
}

