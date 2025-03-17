part of 'single_video_player_bloc.dart';

class SingleVideoPlayerState extends Equatable {
  final AmityPost post;
  final String url;
  final String thumbnail;
  final VideoPlayerController? videoController;

  const SingleVideoPlayerState({
    required this.post,
    required this.url,
    required this.thumbnail,
    this.videoController,
  });

  SingleVideoPlayerState copyWith({
    AmityPost? post,
    String? url,
    String? thumbnail,
    VideoPlayerController? videoController,
  }) {
    return SingleVideoPlayerStateLoaded(
      post: post ?? this.post,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      videoController: videoController ?? this.videoController,
    );
  }

  @override
  List<Object?> get props => [url];
}

class SingleVideoPlayerStateInitial extends SingleVideoPlayerState {
  SingleVideoPlayerStateInitial(AmityPost post)
      : super(post: post, url: "", thumbnail: "");
}

class SingleVideoPlayerStateLoaded extends SingleVideoPlayerState {
  const SingleVideoPlayerStateLoaded({
    post,
    url,
    thumbnail,
    videoController,
    initializeVideoPlayerFuture,
  }) : super(
          post: post,
          url: url,
          thumbnail: thumbnail,
          videoController: videoController,
        );
}
