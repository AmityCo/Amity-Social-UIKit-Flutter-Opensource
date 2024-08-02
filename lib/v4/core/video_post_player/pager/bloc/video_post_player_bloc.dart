
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'video_post_player_events.dart';
part 'video_post_player_state.dart';

class VideoPostPlayerBloc extends Bloc<VideoPostPlayerEvent, VideoPostPlayerState> {
  VideoPostPlayerBloc({required List<AmityPost> posts, required int initialIndex})
      : super(VideoPostPlayerStateInitial(posts, initialIndex)) {
    
    on<VideoPostPlayerEventInitial>((event, emit) async {
      var urls = <String>[];
      var thumbnails = <String>[];
      for (var post in posts) {
        final AmityVideo video = await (post.data as VideoData).getVideo(AmityVideoQuality.LOW);
        final videoUrl = video.getFileProperties!.fileUrl ?? "";
        urls.add(videoUrl);
        final String thumbnail = (post.data as VideoData).thumbnail?.fileUrl ?? "";
        thumbnails.add(thumbnail);
      }
      final uri = Uri.parse(urls[initialIndex]);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      emit(
        state.copyWith(
          urls: urls,
          thumbnails: thumbnails,
          currentIndex: initialIndex,
          videoController: controller,
        )
      );
    });

    on<VideoPostPlayerEventPageChanged>((event, emit) async {
      state.videoController?.pause();
      final uri = Uri.parse(state.urls[event.currentIndex]);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      state.videoController?.dispose();
      emit(
        state.copyWith(
          currentIndex: event.currentIndex,
          videoController: controller,
        )
      );
    });

    on<VideoPostPlayerEventDispose>((event, emit) async {
      state.videoController?.dispose();
    });

  }

}