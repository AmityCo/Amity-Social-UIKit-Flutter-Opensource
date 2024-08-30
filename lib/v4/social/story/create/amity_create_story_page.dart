import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/create_story_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/camera_preview.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/story_draft_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AmityCreateStoryPage extends NewBasePage {
  final AmityStoryTargetType targetType;
  final String targetId;
  final Function onStoryCreated;
  final AmityStoryTarget storyTarget;
  final Function (AmityStoryTarget  storytarget, AmityStoryMediaType mediaType , AmityStoryImageDisplayMode? imageMode , HyperLink? hyperlionk) createStory;

  AmityCreateStoryPage( {
    super.key,
    required this.targetType,
    required this.createStory,
    required this.targetId,
    required this.onStoryCreated,
    required this.storyTarget,
  }) : super(pageId: 'create_story_page');

  @override
  Widget buildPage(BuildContext context) {
    print('Story ---- CreateStoryConfigProviderWidget ------------ Story Target ${storyTarget.targetId}');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<CreateStoryPageBloc, CreateStoryPageState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: CameraPreviewWidget(
                      isVideoMode: state is VideoSelectedState,
                      onImageCaptured: (image ,  isFromGallery) {
                        AmityStoryMediaType mediaType =
                            AmityStoryMediaTypeImage(file: image);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StoryDraftPage(
                                  mediaType: mediaType,
                                  targetId: targetId,
                                  targetType: targetType,
                                  isFromGallery: isFromGallery,
                                  storyTarget: storyTarget,
                                  createStory: createStory,
                                  onClose: () {
                                    onStoryCreated();
                                    Navigator.pop(context);
                                  },
                                )));
                      },
                      onVideoCaptured: (video) {
                        AmityStoryMediaType mediaType =
                            AmityStoryMediaTypeVideo(file: video);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StoryDraftPage(
                                mediaType: mediaType,
                                targetId: targetId,
                                targetType: targetType,
                                createStory: createStory,
                                storyTarget: storyTarget,
                                isFromGallery: false,
                                onClose: () {
                                  print('Story ---- OnClose ------------ Create Story Page');
                                  onStoryCreated();
                                  Navigator.pop(context);
                                })));
                      },
                      onCloseClicked: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: SizedBox(
                      height: 76,
                      width: 220,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: 44,
                          width: 220,
                          decoration: BoxDecoration(
                            color: Color(0xff292B32),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(
                                  milliseconds: 100,
                                ),
                                left: (state is ImageSelectedState) ? 0 : 110,
                                child: Container(
                                  height: 44,
                                  width: 110,
                                  decoration: getSelectedBoxDecoration(theme),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<CreateStoryPageBloc>()
                                          .add(SelectImageEvent());
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: 110,
                                      height: 44,
                                      child: Center(
                                        child: Text(
                                          'Photo',
                                          style: (state is ImageSelectedState)
                                              ? getSelectedTextStyle(theme)
                                              : getUnselectedTextStyle(theme),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<CreateStoryPageBloc>()
                                          .add(SelectVideoEvent());
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: 110,
                                      height: 44,
                                      child: Center(
                                        child: Text(
                                          'Video',
                                          style: (state is VideoSelectedState)
                                              ? getSelectedTextStyle(theme)
                                              : getUnselectedTextStyle(theme),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration getSelectedBoxDecoration(AmityThemeColor appTheme) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(100),
    );
  }

  TextStyle getSelectedTextStyle(AmityThemeColor appTheme) {
    return const  TextStyle(
      color:   Color(0xff636878),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle getUnselectedTextStyle(AmityThemeColor appTheme) {
    return const TextStyle(
      color:   Color(0xff898E9E),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
  }
}
