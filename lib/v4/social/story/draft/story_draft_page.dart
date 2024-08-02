import 'dart:ui';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/bloc/story_draft_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/amity_story_hyperlink_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_story_hyperlink_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/story_video_player_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class StoryDraftPage extends StatefulWidget {
  final AmityStoryMediaType mediaType;
  final String targetId;
  final AmityStoryTargetType targetType;
  final AmityStoryTarget storyTarget;
  final Function onClose;
  final bool isFromGallery;
  final Function(AmityStoryTarget storytarget, AmityStoryMediaType mediaType, AmityStoryImageDisplayMode? imageMode, HyperLink? hyperlionk) createStory;

  const StoryDraftPage({
    super.key,
    required this.mediaType,
    required this.targetId,
    required this.createStory,
    required this.targetType,
    required this.storyTarget,
    required this.onClose,
    required this.isFromGallery,
  });

  @override
  State<StoryDraftPage> createState() => _StoryDraftPageState();
}

class _StoryDraftPageState extends State<StoryDraftPage> {
  @override
  void initState() {
    super.initState();
    if (widget.isFromGallery) {
      context.read<StoryDraftBloc>().add(FillFitToggleEvent(
            imageDisplayMode: AmityStoryImageDisplayMode.FIT,
          ));
    } else {
      context.read<StoryDraftBloc>().add(FillFitToggleEvent(
            imageDisplayMode: AmityStoryImageDisplayMode.FILL,
          ));
    }
    context.read<StoryDraftBloc>().add(ObserveStoryTargetEvent(communityId: widget.targetId, targetType: widget.targetType));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocConsumer<StoryDraftBloc, StoryDraftState>(
          builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Flexible(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: getContent(state.imageDisplayMode),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                if (state is HyperlinkAddedState && state.hyperlink != null) {
                                  AmityCustomSnackBar.show(context, 'Can\'t add more than one link to your story.', SvgPicture.asset('assets/Icons/ic_warning_outline_white.svg', package: 'amity_uikit_beta_service', height: 20, color: Colors.white), textColor: Colors.white);
                                } else {
                                  showHyperLinkBottomSheet(
                                      hyperLink: state is HyperlinkAddedState ? state.hyperlink : null,
                                      context: context,
                                      onHyperLinkAdded: (hyperLink) {
                                        context.read<StoryDraftBloc>().add(OnHyperlinkAddedEvent(hyperlink: hyperLink));
                                      },
                                      onHyperLinkRemoved: () {
                                        context.read<StoryDraftBloc>().add(OnHyperlinkRemovedEvent());
                                      });
                                }
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/Icons/ic_link_white.svg",
                                    package: 'amity_uikit_beta_service',
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          (widget.mediaType is AmityStoryMediaTypeImage && widget.isFromGallery)
                              ? Positioned(
                                  top: 16,
                                  right: 52,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<StoryDraftBloc>().add(FillFitToggleEvent(imageDisplayMode: state.imageDisplayMode == AmityStoryImageDisplayMode.FILL ? AmityStoryImageDisplayMode.FIT : AmityStoryImageDisplayMode.FILL));
                                    },
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/Icons/ic_square_white.svg",
                                          package: 'amity_uikit_beta_service',
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          state.hyperlink != null
                              ? Positioned(
                                  bottom: 34,
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    child: Center(
                                      child: AmityStoryHyperlinkView(
                                        hyperlink: state.hyperlink!,
                                        onClick: () {
                                          showHyperLinkBottomSheet(
                                              hyperLink: state.hyperlink,
                                              context: context,
                                              onHyperLinkAdded: (hyperLink) {
                                                context.read<StoryDraftBloc>().add(OnHyperlinkAddedEvent(hyperlink: hyperLink));
                                              },
                                              onHyperLinkRemoved: () {
                                                context.read<StoryDraftBloc>().add(OnHyperlinkRemovedEvent());
                                              });
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Show the Dialog box
                                ConfirmationDialog().show(
                                  context: context,
                                  title: 'Discard this Story?',
                                  detailText: 'The story will be permanently deleted. It cannot be undone',
                                  leftButtonText: 'Cancel',
                                  rightButtonText: 'Discard',
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                                // Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/Icons/ic_arrow_left_white.svg",
                                    package: 'amity_uikit_beta_service',
                                    height: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              widget.createStory(state.storyTarget!, widget.mediaType, state.imageDisplayMode, state.hyperlink);
                              widget.onClose();
                              Navigator.of(context).pop();
                              // if (widget.mediaType is AmityStoryMediaTypeImage) {
                              //   context.read<StoryDraftBloc>().add(OnPostImageStoryEvent(imageDisplayMode: state.imageDisplayMode, hyperlink: state is HyperlinkAddedState ? state.hyperlink : null, imageFile: (widget.mediaType as AmityStoryMediaTypeImage).file));
                              // } else if (widget.mediaType is AmityStoryMediaTypeVideo) {
                              //   context.read<StoryDraftBloc>().add(OnPostVideoStoryEvent(hyperlink: state is HyperlinkAddedState ? state.hyperlink : null, videoFile: (widget.mediaType as AmityStoryMediaTypeVideo).file));
                              // }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 8, left: 4),
                              margin: const EdgeInsets.only(right: 16),
                              height: 40,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    child: SizedBox(width: 32, height: 32, child: getProfileIcon(state.storyTarget)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 8, right: 8),
                                    child: const Text(
                                      "Share Story",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "SF Pro Text",
                                      ),
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/Icons/ic_arrow_right_black.svg",
                                    package: 'amity_uikit_beta_service',
                                    height: 16,
                                    width: 16,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          listener: (BuildContext context, StoryDraftState state) {
            if (state is StoryPostedState) {
              BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
              widget.createStory(state.storyTarget!, widget.mediaType, state.imageDisplayMode, state.hyperlink);
              widget.onClose();
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget getContent(AmityStoryImageDisplayMode imageDisplayMode) {
    if (widget.mediaType is AmityStoryMediaTypeImage) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Image.file(
                        (widget.mediaType as AmityStoryMediaTypeImage).file,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                  child: Image.file(
                    (widget.mediaType as AmityStoryMediaTypeImage).file,
                    fit: imageDisplayMode == AmityStoryImageDisplayMode.FILL ? BoxFit.cover : BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    try {
      if (widget.mediaType is AmityStoryMediaTypeVideo) {
        return Container(
          height: double.infinity,
          width: double.infinity,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: AmityStoryVideoPlayer(
                  video: (widget.mediaType as AmityStoryMediaTypeVideo).file,
                  onInitializing: () {},
                  showVolumeControl: false,
                  url: null,
                  onInitialize: () {},
                  onPause: () {},
                  onPlay: () {}, onWidgetDispose: () {
                    BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                  },
                ),
              )),
        );
      }
    } catch (ex) {
      rethrow;
    }

    return Container();
  }

  Widget getProfileIcon(AmityStoryTarget? storyTarget) {
    if (storyTarget == null) {
      return const AmityNetworkImage(imageUrl: "", placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg");
    }
    if (storyTarget is AmityStoryTargetCommunity) {
      return storyTarget.community?.avatarImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: AmityNetworkImage(
                imageUrl: storyTarget.community!.avatarImage!.fileUrl!,
                placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
              ),
            )
          : const AmityNetworkImage(
              imageUrl: "",
              placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
            );
    }

    return const AmityNetworkImage(imageUrl: "", placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg");
  }
}
