part of 'video_post_player_bloc.dart';

class VideoPostPlayerState extends Equatable {
  final List<AmityPost> posts;
  final List<String> urls;
  final List<String> thumbnails;
  final int currentIndex;
  final VideoPlayerController? videoController;

  const VideoPostPlayerState({
    required this.posts,
    required this.urls,
    required this.thumbnails,
    required this.currentIndex,
    this.videoController,
  });

  VideoPostPlayerState copyWith({
    List<AmityPost>? posts,
    List<String>? urls,
    List<String>? thumbnails,
    int? currentIndex,
    VideoPlayerController? videoController,
  }) {
    return VideoPostPlayerStateLoaded(
      posts: posts ?? this.posts,
      urls: urls ?? this.urls,
      thumbnails: thumbnails ?? this.thumbnails,
      currentIndex: currentIndex ?? this.currentIndex,
      videoController: videoController ?? this.videoController,
    );
  }

  @override
  List<Object?> get props => [urls, currentIndex];
}

class VideoPostPlayerStateInitial extends VideoPostPlayerState {
  VideoPostPlayerStateInitial(List<AmityPost> posts, int initialIndex)
      : super(
            posts: posts, urls: [], thumbnails: [], currentIndex: initialIndex);
}

class VideoPostPlayerStateLoaded extends VideoPostPlayerState {
  const VideoPostPlayerStateLoaded({
    posts,
    urls,
    thumbnails,
    currentIndex,
    videoController,
    initializeVideoPlayerFuture,
  }) : super(
          posts: posts,
          urls: urls,
          thumbnails: thumbnails,
          currentIndex: currentIndex,
          videoController: videoController,
        );
}
