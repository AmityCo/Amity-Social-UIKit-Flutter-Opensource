import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';

class AmityStoryHelper {

  static Future<void> createStory(
    String targetId,
    AmityStoryTargetType targetType,
    AmityStoryMediaType mediaType,
    AmityStoryImageDisplayMode? imageMode,
    HyperLink? hyperlink,
  ) async {
    if (mediaType is AmityStoryMediaTypeImage) {
      return AmitySocialClient.newStoryRepository().createImageStory(
        targetType: targetType,
        targetId: targetId,
        imageFile: (mediaType).file,
        storyItems: hyperlink != null ? [hyperlink] : [],
        imageDisplayMode: imageMode!,
      );
    } else if (mediaType is AmityStoryMediaTypeVideo) {
      return AmitySocialClient.newStoryRepository().createVideoStory(
        targetType: targetType,
        targetId: targetId,
        storyItems: hyperlink != null ? [hyperlink!] : [],
        videoFile: (mediaType).file,
      );
    }
  }
}
