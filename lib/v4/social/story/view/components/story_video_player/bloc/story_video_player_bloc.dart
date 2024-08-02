import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'story_video_player_event.dart';
part 'story_video_player_state.dart';

class StoryVideoPlayerBloc extends Bloc<StoryVideoPlayerEvent, StoryVideoPlayerState> {
  StoryVideoPlayerBloc() : super(const  StoryVideoPlayerInitial(videoController: null , chewieController: null , duration: 0 )) {
    
    on<InitializeStoryVideoPlayerEvent>((event, emit)  async{
      if(state.videoController != null){
        state.videoController?.dispose();
        state.chewieController?.dispose();
      }
      VideoPlayerController videoController;
      if (event.file != null) {
        videoController = VideoPlayerController.file(event.file!);
      } else {
        videoController =  VideoPlayerController.networkUrl(Uri.parse(event.url!));
      }
      await videoController.initialize();
      ChewieController? chewieController = ChewieController(
        showControlsOnInitialize: false,
        videoPlayerController: videoController,
        autoPlay: true,
        showControls: false,
        autoInitialize: true,
        allowFullScreen: true,
        looping: false,
      );

      print("VIDEO DURATION: ${videoController.value.duration.inSeconds}");

      emit(StoryVideoPlayerInitialized(videoController: videoController, chewieController: chewieController , duration: videoController.value.duration.inSeconds ));
    });

    on<PlayStoryVideoEvent>((event, emit) {
      state.videoController?.play();
      emit(StoryVideoPlayerPaused(videoController: state.videoController, chewieController: state.chewieController ,duration: state.videoController!.value.duration.inSeconds ));
    });

    on<PauseStoryVideoEvent>((event, emit) {
      state.videoController?.pause();
      emit(StoryVideoPlayerPaused(videoController: state.videoController, chewieController: state.chewieController, duration: state.videoController!.value.duration.inSeconds));
    });


    on<VolumeChangedEvent>((event, emit) {
      bool isVolumeOn  = state.videoController!.value.volume == 1.0;
      state.videoController!.setVolume(isVolumeOn? 0.0 : 1.0);
    });

    on<DisposeStoryVideoPlayerEvent>((event, emit) {
      print("ShouldPauseStateVideo - > Dispose Bloc");
      state.videoController?.pause();
      state.videoController?.dispose();
      state.chewieController?.dispose();
      emit(const StoryVideoPlayerDisposed(videoController: null, chewieController: null, duration: 0 ));
    });
  }


  @override
  Future<void> close() {
    state.videoController?.dispose();
    state.chewieController?.dispose();
    return super.close();
  }
}
