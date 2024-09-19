import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_story_event.dart';
part 'create_story_state.dart';

class CreateStoryBloc extends Bloc<CreateStoryEvent, CreateStoryState> {
  CreateStoryBloc() : super(CreateStoryInitial()) {
    on<CreateStorySuccessEvent>((event, emit) {
      emit(CreateStorySuccess());
    });

    on<CreateStoryFailEvent>((event, emit) {
      emit(CreateStoryFailure());
    });

    on<CreateStory>((event, emit) {
      emit(CreateStoryLoading());
      if (event.mediaType is AmityStoryMediaTypeImage) {
        var file = (event.mediaType as AmityStoryMediaTypeImage).file;
        return AmitySocialClient.newStoryRepository()
            .createImageStory(
          targetType: event.targetType,
          targetId: event.targetId,
          imageFile: file,
          storyItems: event.hyperlink != null ? [event.hyperlink!] : [],
          imageDisplayMode: event.imageMode!,
        )
            .then((value) {
          add(CreateStorySuccessEvent());
        }).onError((error, stackTrace) => null);
      } else if (event.mediaType is AmityStoryMediaTypeVideo) {
        var file = (event.mediaType as AmityStoryMediaTypeVideo).file;
        return AmitySocialClient.newStoryRepository()
            .createVideoStory(
          targetType: event.targetType,
          targetId: event.targetId,
          storyItems: event.hyperlink != null ? [event.hyperlink!] : [],
          videoFile: file,
        )
            .then((value) {
          add(CreateStorySuccessEvent());
        }).onError((error, stackTrace) => null);
      }
    });
  }
}
