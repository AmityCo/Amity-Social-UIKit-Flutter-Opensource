import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'single_video_player_state.dart';
part 'single_video_player_event.dart';

class SingleVideoPlayerBloc
    extends Bloc<SingleVideoPlayerEvent, SingleVideoPlayerState> {
  SingleVideoPlayerBloc({required String? filePath, required String? fileUrl})
      : super(VideoPostPlayerStateInitial(filePath, fileUrl)) {
    on<SingleVideoPlayerEventInitial>((event, emit) async {
      if (filePath != null) {
        final controller = VideoPlayerController.file(File(filePath));
        await controller.initialize();
        emit(state.copyWith(
          filePath: filePath,
          fileUrl: null,
          videoController: controller,
        ));
      } else if (fileUrl != null) {
        final uri = Uri.parse(fileUrl);
        final controller = VideoPlayerController.networkUrl(uri);
        await controller.initialize();
        emit(state.copyWith(
          filePath: null,
          fileUrl: fileUrl,
          videoController: controller,
        ));
      }
    });

    on<SingleVideoPlayerEventDispose>((event, emit) async {
      state.videoController?.dispose();
    });
  }
}
