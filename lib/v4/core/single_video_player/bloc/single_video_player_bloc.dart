import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'single_video_player_events.dart';
part 'single_video_player_state.dart';

class VideoPostPlayerBloc
    extends Bloc<SingleVideoPlayerEvent, SingleVideoPlayerState> {
  VideoPostPlayerBloc({required AmityPost post})
      : super(SingleVideoPlayerStateInitial(post)) {
    on<SingleVideoPlayerEventInitial>((event, emit) async {
      final AmityVideo video =
          await (post.data as VideoData).getVideo(AmityVideoQuality.HIGH);
      final videoUrl = video.getFileProperties!.fileUrl ?? "";
      final thumbnail = (post.data as VideoData).thumbnail?.fileUrl ?? "";

      final uri = Uri.parse(videoUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();

      emit(state.copyWith(
        url: videoUrl,
        thumbnail: thumbnail,
        videoController: controller,
      ));
    });

    on<SingleVideoPlayerEventDispose>((event, emit) async {
      state.videoController?.dispose();
    });
  }
}
