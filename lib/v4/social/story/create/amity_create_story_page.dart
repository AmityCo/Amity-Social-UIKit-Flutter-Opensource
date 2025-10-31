import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/create_story_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/camera_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/bloc/story_draft_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/story_draft_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCreateStoryPage extends NewBasePage {
  final AmityStoryTargetType targetType;
  final String targetId;

  AmityCreateStoryPage({
    super.key,
    required this.targetType,
    required this.targetId,
  }) : super(pageId: 'camera_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocListener<CreateStoryBloc, CreateStoryState>(
      listener: (context, state) {
        if (state is CreateStoryLoading) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
                      child: AmityCameraPage(
                        isVideoMode: state is VideoSelectedState,
                        onImageCaptured: (image, isFromGallery) {
                          AmityStoryMediaType mediaType = AmityStoryMediaTypeImage(file: image);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (context) => StoryDraftBloc()),
                                  BlocProvider(create: (context) => StoryVideoPlayerBloc()),
                                ],
                                child: StoryDraftPage(
                                  mediaType: mediaType,
                                  targetId: targetId,
                                  targetType: targetType,
                                  isFromGallery: isFromGallery,
                                ),
                              ),
                            ),
                          );
                        },
                        onVideoCaptured: (video, metadata, isFromGallery) {
                          AmityStoryMediaType mediaType = AmityStoryMediaTypeVideo(
                            file: video,
                            metadata: metadata,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                providers: [
                                  BlocProvider(create: (context) => StoryDraftBloc()),
                                  BlocProvider(create: (context) => StoryVideoPlayerBloc()),
                                ],
                                child: StoryDraftPage(
                                  mediaType: mediaType,
                                  targetId: targetId,
                                  targetType: targetType,
                                  isFromGallery: isFromGallery,
                                ),
                              ),
                            ),
                          );
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
                              color: const Color(0xff292B32),
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
                                        context.read<CreateStoryPageBloc>().add(SelectImageEvent());
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        width: 110,
                                        height: 44,
                                        child: Center(
                                          child: Text(
                                            'Photo',
                                            style: (state is ImageSelectedState) ? getSelectedTextStyle(theme) : getUnselectedTextStyle(theme),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<CreateStoryPageBloc>().add(SelectVideoEvent());
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        width: 110,
                                        height: 44,
                                        child: Center(
                                          child: Text(
                                            'Video',
                                            style: (state is VideoSelectedState) ? getSelectedTextStyle(theme) : getUnselectedTextStyle(theme),
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
    return const TextStyle(
      color: Color(0xff636878),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle getUnselectedTextStyle(AmityThemeColor appTheme) {
    return const TextStyle(
      color: Color(0xff898E9E),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
  }
}
