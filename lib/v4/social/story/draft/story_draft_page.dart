import 'dart:ui';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/bloc/story_draft_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/amity_story_hyperlink_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_story_hyperlink_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/story_video_player_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';

class StoryDraftPage extends NewBasePage {
  final AmityStoryMediaType mediaType;
  final String targetId;
  final AmityStoryTargetType targetType;
  bool? isFromGallery = false;

  StoryDraftPage({
    super.key,
    required this.mediaType,
    required this.targetId,
    required this.targetType,
    this.isFromGallery,
  }) : super(pageId: 'create_story_page');

  @override
  Widget buildPage(BuildContext context) {
    return StoryDarftPageBuilder(
      mediaType: mediaType,
      targetId: targetId,
      targetType: targetType,
      isFromGallery: isFromGallery,
    );
  }
}

class StoryDarftPageBuilder extends StatefulWidget {
  final AmityStoryMediaType mediaType;
  final String targetId;
  final AmityStoryTargetType targetType;
  bool? isFromGallery = false;

  StoryDarftPageBuilder({
    super.key,
    required this.mediaType,
    required this.targetId,
    required this.targetType,
    this.isFromGallery,
  });

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;

  @override
  State<StoryDarftPageBuilder> createState() => _StoryDarftPageBuilderState();
}

class _StoryDarftPageBuilderState extends State<StoryDarftPageBuilder> {
  @override
  void initState() {
    super.initState();
    if (widget.isFromGallery ?? false) {
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
                    child: SizedBox(
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
                                  AmityCustomSnackBar.show(
                                    context,
                                    'Can\'t add more than one link to your story.',
                                    SvgPicture.asset(
                                      'assets/Icons/ic_warning_outline_white.svg',
                                      package: 'amity_uikit_beta_service',
                                      height: 20,
                                      color: Colors.white,
                                    ),
                                    textColor: Colors.white,
                                  );
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
                          (widget.mediaType is AmityStoryMediaTypeImage && (widget.isFromGallery ?? false))
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 16.0,
                                    ),
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
                                            },
                                          );
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
                                ConfirmationDialog().show(
                                  context: context,
                                  title: widget._getText(context,
                                          'modal_discard_story_title') ??
                                      'Discard this Story?',
                                  detailText: widget._getText(context,
                                          'modal_discard_story_desc') ??
                                      'modal_discard_story_desc',
                                  leftButtonText: context.l10n.general_cancel,
                                  rightButtonText: widget._getText(
                                          context, 'modal_discard_story_cta') ??
                                      'Discard',
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
                          ShareButton(
                            storyTarget: state.storyTarget,
                            pageId: 'create_story_page',
                            onClick: () {
                              HapticFeedback.heavyImpact();
                              BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                              AmityStorySingleSegmentTimerElement.currentValue = -1;
                              BlocProvider.of<CreateStoryBloc>(context).add(CreateStory(
                                mediaType: widget.mediaType,
                                targetId: widget.targetId,
                                targetType: widget.targetType,
                                imageMode: state.imageDisplayMode,
                                hyperlink: state.hyperlink,
                              ));
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          listener: (BuildContext context, StoryDraftState state) {},
        ),
      ),
    );
  }

  Widget getContent(AmityStoryImageDisplayMode imageDisplayMode) {
    if (widget.mediaType is AmityStoryMediaTypeImage) {
      return AmityStoryImageViewWidget(imageDisplayMode: imageDisplayMode, mediaType: widget.mediaType);
    }
    try {
      if (widget.mediaType is AmityStoryMediaTypeVideo) {
        return SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: AmityStoryVideoPlayer(
                video: (widget.mediaType as AmityStoryMediaTypeVideo).file,
                onInitializing: () {},
                showVolumeControl: false,
                url: null,
                onInitialize: () {},
                onPause: () {},
                onPlay: () {},
                onWidgetDispose: () {
                  BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
                },
              ),
            ),
          ),
        );
      }
    } catch (ex) {
      rethrow;
    }
    return Container();
  }
}

class AmityStoryImageViewWidget extends StatefulWidget {
  final AmityStoryImageDisplayMode imageDisplayMode;
  final AmityStoryMediaType mediaType;
  const AmityStoryImageViewWidget({
    super.key,
    required this.mediaType,
    required this.imageDisplayMode,
  });

  @override
  State<AmityStoryImageViewWidget> createState() => _AmityStoryImageViewWidgetState();
}

class _AmityStoryImageViewWidgetState extends State<AmityStoryImageViewWidget> {
  Color _dominantColor = Colors.black; // Default color
  Color _vibrantColor = Colors.white; // Default color
  late PaletteGenerator _paletteGenerator;

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    // Load the image from assets
    final imageProvider = FileImage((widget.mediaType as AmityStoryMediaTypeImage).file);
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 200), // Set the size to reduce computation time
    );
    setState(() {
      _dominantColor = _paletteGenerator.vibrantColor?.color.withOpacity(0.7) ?? Colors.black;
      _vibrantColor = _paletteGenerator.darkVibrantColor?.color.withOpacity(0.7) ?? Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _dominantColor,
                        _vibrantColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
                  fit: widget.imageDisplayMode == AmityStoryImageDisplayMode.FILL ? BoxFit.cover : BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

  return const AmityNetworkImage(
    imageUrl: "",
    placeHolderPath: "assets/Icons/amity_ic_community_avatar_placeholder.svg",
  );
}

class ShareButton extends BaseElement {
  final VoidCallback onClick;
  final AmityStoryTarget? storyTarget;
  final String? componentId;
  final String? pageId;
  ShareButton({super.key, required this.onClick, required this.storyTarget, this.componentId, this.pageId}) : super(pageId: pageId, componentId: componentId, elementId: "share_story_button");

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;
  
  @override
  Widget buildElement(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.only(right: 8, left: 4),
        margin: const EdgeInsets.only(right: 16),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: theme.backgroundColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 32, height: 32, child: getProfileIcon(storyTarget)),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                _getText(context, 'story_share_cta') ?? "Share Story",
                style: TextStyle(
                  color: theme.baseColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "SF Pro Text",
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/Icons/ic_arrow_right_black.svg",
              package: 'amity_uikit_beta_service',
              color: theme.baseColor,
              height: 16,
              width: 16,
            )
          ],
        ),
      ),
    );
  }
}
