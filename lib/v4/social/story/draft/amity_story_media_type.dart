import 'dart:io';

abstract class AmityStoryMediaType{

}


class AmityStoryMediaTypeImage extends AmityStoryMediaType{
  File file;
  AmityStoryMediaTypeImage({ required this.file});
}


class AmityStoryMediaTypeVideo extends AmityStoryMediaType{
  File file;
  AmityStoryMediaTypeVideo({ required this.file});
}