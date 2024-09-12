import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';

typedef CreateStoryCallBack = void Function(
  String targetId,
  AmityStoryTargetType targetType,
  AmityStoryMediaType mediaType,
  AmityStoryImageDisplayMode? imageMode,
  HyperLink? hyperlink,
);
