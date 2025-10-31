import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class AmityStoryMediaType{

}


class AmityStoryMediaTypeImage extends AmityStoryMediaType{
  File file;
  AmityStoryMediaTypeImage({ required this.file});
}


class AmityStoryMediaTypeVideo extends AmityStoryMediaType{
  File file;
  StoryVideoMetadata? metadata;

  AmityStoryMediaTypeVideo({
    required this.file,
    this.metadata,
  });
}

class StoryVideoMetadata extends Equatable {
  final bool isBackCamera;

  const StoryVideoMetadata({
    required this.isBackCamera,
  });

  StoryVideoMetadata copyWith({
    bool? isBackCamera,
  }) {
    return StoryVideoMetadata(
      isBackCamera: isBackCamera ?? this.isBackCamera,
    );
  }

  @override
  List<Object?> get props => [isBackCamera];
}