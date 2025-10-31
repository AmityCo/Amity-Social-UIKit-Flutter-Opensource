import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/amity_story_media_type.dart';
import 'package:amity_uikit_beta_service/v4/social/story/draft/bloc/story_draft_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/amity_story_hyperlink_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_story_hyperlink_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_custom_snack_bar.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_cache.dart';
import 'package:amity_uikit_beta_service/v4/utils/create_story/bloc/create_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class StoryDraftPage extends NewBasePage {
  final AmityStoryMediaType mediaType;
  final String targetId;
  final AmityStoryTargetType targetType;
  final bool? isFromGallery;

  StoryDraftPage({
    super.key,
    required this.mediaType,
    required this.targetId,
    required this.targetType,
    this.isFromGallery = false,
  }) : super(pageId: 'create_story_page');

  @override
  Widget buildPage(BuildContext context) {
    return StoryDraftPageBuilder(
      mediaType: mediaType,
      targetId: targetId,
      targetType: targetType,
      isFromGallery: isFromGallery,
    );
  }
}

class StoryDraftPageBuilder extends StatefulWidget {
  final AmityStoryMediaType mediaType;
  final String targetId;
  final AmityStoryTargetType targetType;
  final bool? isFromGallery;

  const StoryDraftPageBuilder({
    super.key,
    required this.mediaType,
    required this.targetId,
    required this.targetType,
    this.isFromGallery,
  });

  @override
  State<StoryDraftPageBuilder> createState() => _StoryDraftPageBuilderState();
}

class _StoryDraftPageBuilderState extends State<StoryDraftPageBuilder> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<StoryDraftBloc>();
      if (widget.isFromGallery ?? false) {
        bloc.add(FillFitToggleEvent(
          imageDisplayMode: AmityStoryImageDisplayMode.FIT,
        ));
      } else {
        bloc.add(FillFitToggleEvent(
          imageDisplayMode: AmityStoryImageDisplayMode.FILL,
        ));
      }
      bloc.add(ObserveStoryTargetEvent(
        communityId: widget.targetId,
        targetType: widget.targetType,
      ));
    });
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
                  Expanded(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: getContent(state.imageDisplayMode),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                if (state is HyperlinkAddedState &&
                                    state.hyperlink != null) {
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
                                      hyperLink: state is HyperlinkAddedState
                                          ? state.hyperlink
                                          : null,
                                      context: context,
                                      onHyperLinkAdded: (hyperLink) {
                                        context.read<StoryDraftBloc>().add(
                                            OnHyperlinkAddedEvent(
                                                hyperlink: hyperLink));
                                      },
                                      onHyperLinkRemoved: () {
                                        context
                                            .read<StoryDraftBloc>()
                                            .add(OnHyperlinkRemovedEvent());
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
                          (widget.mediaType is AmityStoryMediaTypeImage &&
                                  (widget.isFromGallery ?? false))
                              ? Positioned(
                                  top: 16,
                                  right: 52,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<StoryDraftBloc>().add(
                                          FillFitToggleEvent(
                                              imageDisplayMode: state
                                                          .imageDisplayMode ==
                                                      AmityStoryImageDisplayMode
                                                          .FILL
                                                  ? AmityStoryImageDisplayMode
                                                      .FIT
                                                  : AmityStoryImageDisplayMode
                                                      .FILL));
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
                                              context
                                                  .read<StoryDraftBloc>()
                                                  .add(OnHyperlinkAddedEvent(
                                                      hyperlink: hyperLink));
                                            },
                                            onHyperLinkRemoved: () {
                                              context.read<StoryDraftBloc>().add(
                                                  OnHyperlinkRemovedEvent());
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
                                  title: 'Discard this Story?',
                                  detailText:
                                      'The story will be permanently deleted. It cannot be undone.',
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
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShareButton(
                          storyTarget: state.storyTarget,
                          pageId: 'create_story_page',
                          onClick: () {
                              HapticFeedback.heavyImpact();
                              BlocProvider.of<StoryVideoPlayerBloc>(context)
                                  .add(const DisposeStoryVideoPlayerEvent());
                              StoryTimerStateManager.currentValue = -1;
                              BlocProvider.of<CreateStoryBloc>(context)
                                  .add(CreateStory(
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
      return AmityStoryImageViewWidget(
          imageDisplayMode: imageDisplayMode, mediaType: widget.mediaType);
    }
    try {
      if (widget.mediaType is AmityStoryMediaTypeVideo) {
        return StoryDraftVideoView(
          mediaType: widget.mediaType as AmityStoryMediaTypeVideo,
          isFromGallery: widget.isFromGallery ?? false,
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
  State<AmityStoryImageViewWidget> createState() =>
      _AmityStoryImageViewWidgetState();
}

class _AmityStoryImageViewWidgetState extends State<AmityStoryImageViewWidget> {
  Color _dominantColor = Colors.black;
  Color _vibrantColor = Colors.grey.shade800;
  PaletteGenerator? _paletteGenerator;
  ImageProvider? _lowResProvider;
  ImageProvider? _fullResProvider;
  ImageStream? _lowResStream;
  ImageStream? _fullResStream;
  ImageStreamListener? _lowResListener;
  ImageStreamListener? _fullResListener;
  bool _lowResReady = false;
  bool _fullResReady = false;
  bool _highResStarted = false;
  bool _isComputingPalette = false;
  String? _paletteCacheKey;
  final StoryPaletteCache _paletteCache = StoryPaletteCache();

  @override
  void initState() {
    super.initState();
    _initializeImageProviders(resetPalette: false);
  }

  @override
  void didUpdateWidget(covariant AmityStoryImageViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mediaType != widget.mediaType) {
      _initializeImageProviders(resetPalette: true);
    } else if (oldWidget.imageDisplayMode != widget.imageDisplayMode) {
      // Ensure the widget rebuilds with updated fit/alignment.
      setState(() {});
    }
  }

  void _initializeImageProviders({required bool resetPalette}) {
    _disposeStreams();

    final imageFile = (widget.mediaType as AmityStoryMediaTypeImage).file;
    final baseProvider = FileImage(imageFile);

    _paletteCacheKey = imageFile.path;
    _lowResProvider = ResizeImage(
      baseProvider,
      width: 420,
      allowUpscaling: false,
    );
    _fullResProvider = ResizeImage(
      baseProvider,
      width: 1440,
      allowUpscaling: false,
    );

    _lowResReady = false;
    _fullResReady = false;
    _highResStarted = false;

    if (resetPalette) {
      _dominantColor = Colors.black;
      _vibrantColor = Colors.grey.shade800;
      _paletteGenerator = null;
    }

    if (_paletteCacheKey != null) {
      final cachedPalette = _paletteCache.get(_paletteCacheKey!);
      if (cachedPalette != null) {
        _paletteGenerator = cachedPalette;
        final cachedDominant =
            cachedPalette.dominantColor?.color.withOpacity(0.7);
        final cachedVibrant =
            cachedPalette.darkMutedColor?.color.withOpacity(0.7);
        if (cachedDominant != null) {
          _dominantColor = cachedDominant;
        }
        if (cachedVibrant != null) {
          _vibrantColor = cachedVibrant;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startLowResLoad();
    });
  }

  void _startLowResLoad() {
    if (_lowResProvider == null) return;

    final stream = _lowResProvider!.resolve(const ImageConfiguration());
    _lowResStream = stream;
    _lowResListener = ImageStreamListener((image, synchronousCall) {
      if (!_lowResReady && mounted) {
        setState(() {
          _lowResReady = true;
        });
      }
      _ensurePaletteComputed(useLowRes: true);
      _startFullResLoad();
    }, onError: (error, stackTrace) {
      _startFullResLoad();
    });

    stream.addListener(_lowResListener!);
  }

  void _startFullResLoad() {
    if (_highResStarted || _fullResProvider == null) return;
    _highResStarted = true;

    final stream = _fullResProvider!.resolve(const ImageConfiguration());
    _fullResStream = stream;
    _fullResListener = ImageStreamListener((image, synchronousCall) {
      if (!_fullResReady && mounted) {
        setState(() {
          _fullResReady = true;
        });
      }
      _ensurePaletteComputed(useLowRes: false);
    });

    stream.addListener(_fullResListener!);
  }

  void _ensurePaletteComputed({required bool useLowRes}) {
    if (_isComputingPalette) {
      return;
    }

    if (_paletteCacheKey != null && _paletteCache.has(_paletteCacheKey!)) {
      final cachedPalette = _paletteCache.get(_paletteCacheKey!);
      if (cachedPalette != null && _paletteGenerator == null) {
        _paletteGenerator = cachedPalette;
        final cachedDominant =
            cachedPalette.dominantColor?.color.withOpacity(0.7);
        final cachedVibrant =
            cachedPalette.darkMutedColor?.color.withOpacity(0.7);
        if (cachedDominant != null || cachedVibrant != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              if (cachedDominant != null) {
                _dominantColor = cachedDominant;
              }
              if (cachedVibrant != null) {
                _vibrantColor = cachedVibrant;
              }
            });
          });
        }
      }
      return;
    }

    final provider = useLowRes && _lowResProvider != null
        ? _lowResProvider
        : _fullResProvider ?? _lowResProvider;
    if (provider == null) return;

    _isComputingPalette = true;
    PaletteGenerator.fromImageProvider(
      provider,
      size: const Size(40, 40),
    ).then((palette) {
      if (!mounted) return;
      _paletteGenerator = palette;
      if (_paletteCacheKey != null) {
        _paletteCache.set(_paletteCacheKey!, palette);
      }

      final newDominantColor = palette.dominantColor?.color.withOpacity(0.7);
      final newVibrantColor = palette.darkMutedColor?.color.withOpacity(0.7);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (newDominantColor != null) {
            _dominantColor = newDominantColor;
          }
          if (newVibrantColor != null) {
            _vibrantColor = newVibrantColor;
          }
        });
      });
    }).catchError((_) {
      // Ignore palette failures and keep defaults
    }).whenComplete(() {
      _isComputingPalette = false;
    });
  }

  @override
  void dispose() {
    _disposeStreams();
    super.dispose();
  }

  void _disposeStreams() {
    if (_lowResStream != null && _lowResListener != null) {
      _lowResStream!.removeListener(_lowResListener!);
    }
    if (_fullResStream != null && _fullResListener != null) {
      _fullResStream!.removeListener(_fullResListener!);
    }
    _lowResStream = null;
    _fullResStream = null;
    _lowResListener = null;
    _fullResListener = null;
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
                child: AnimatedContainer(
                  duration: const Duration(
                      milliseconds: 300), // Smooth transition when colors load
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
              if (_lowResReady && _lowResProvider != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      key: ValueKey(
                          'low_res_${widget.imageDisplayMode.name}_visible_${_fullResReady ? 0 : 1}'),
                      opacity: _fullResReady ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      child: _buildDecoratedImage(
                        provider: _lowResProvider!,
                        filterQuality: FilterQuality.low,
                        isHighRes: false,
                      ),
                    ),
                  ),
                )
              else
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  ),
                ),
              if (_fullResReady && _fullResProvider != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      key: ValueKey(
                          'full_res_${widget.imageDisplayMode.name}_visible'),
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: _buildDecoratedImage(
                        provider: _fullResProvider!,
                        filterQuality: FilterQuality.medium,
                        isHighRes: true,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecoratedImage(
      {required ImageProvider provider,
      required FilterQuality filterQuality,
      required bool isHighRes}) {
    final fit = widget.imageDisplayMode == AmityStoryImageDisplayMode.FILL
        ? BoxFit.cover
        : BoxFit.contain;

    return DecoratedBox(
      key: ValueKey(
          '${isHighRes ? 'hi' : 'lo'}_${widget.imageDisplayMode.name}'),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: provider,
          fit: fit,
          alignment: Alignment.center,
          filterQuality: filterQuality,
        ),
      ),
    );
  }
}

class StoryDraftVideoView extends StatefulWidget {
  final AmityStoryMediaTypeVideo mediaType;
  final bool isFromGallery;

  const StoryDraftVideoView({
    super.key, 
    required this.mediaType,
    this.isFromGallery = false,
  });

  @override
  State<StoryDraftVideoView> createState() => _StoryDraftVideoViewState();
}

class _StoryDraftVideoViewState extends State<StoryDraftVideoView> {
  Uint8List? _thumbnailBytes;
  late final StoryVideoPlayerBloc _videoBloc;

  @override
  void initState() {
    super.initState();
    _videoBloc = context.read<StoryVideoPlayerBloc>();
    _generateThumbnail();
    
    // Initialize video through bloc - single source of truth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _videoBloc.add(InitializeStoryVideoPlayerEvent(
        file: widget.mediaType.file,
        url: null,
        looping: true,
        metadata: widget.mediaType.metadata,
        isFromGallery: widget.isFromGallery,
      ));
    });
  }

  @override
  void didUpdateWidget(covariant StoryDraftVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mediaType.file.path != widget.mediaType.file.path) {
      setState(() {
        _thumbnailBytes = null;
      });
      _generateThumbnail();
      
      // Reinitialize for new video
      _videoBloc.add(InitializeStoryVideoPlayerEvent(
        file: widget.mediaType.file,
        url: null,
        looping: true,
        metadata: widget.mediaType.metadata,
        isFromGallery: widget.isFromGallery,
      ));
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      final thumb = await VideoThumbnail.thumbnailData(
  video: widget.mediaType.file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 60,
      );

      if (!mounted || thumb == null) return;

      setState(() {
        _thumbnailBytes = thumb;
      });
    } catch (_) {
      // Ignore thumbnail failures
    }
  }

  @override
  void dispose() {
    // Single disposal point - bloc will handle cleanup
    _videoBloc.add(const DisposeStoryVideoPlayerEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryVideoPlayerBloc, StoryVideoPlayerState>(
      builder: (context, videoState) {
        final videoController = videoState.videoController;
        final chewieController = videoState.chewieController;
        final hasController = videoController != null && chewieController != null;
        final isVideoReady = hasController && videoController.value.isInitialized;

        return SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Black background
                Container(color: Colors.black),
                
                // Thumbnail while loading
                if (_thumbnailBytes != null && !isVideoReady)
                  Image.memory(
                    _thumbnailBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                
                // Video player - only render when ready
                // Always fill width, crop vertically if portrait
                if (hasController && isVideoReady)
                  _buildVideoPlayer(
                    videoState,
                    videoController,
                    chewieController,
                  ),
                
                // Loading overlay
                if (!isVideoReady)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.35),
                      ),
                    ),
                  ),
                
                // Loading spinner
                if (!isVideoReady)
                  const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(
    StoryVideoPlayerState videoState,
    VideoPlayerController videoController,
    ChewieController chewieController,
  ) {
    final videoValue = videoController.value;
    var displayWidth = videoValue.size.width;
    var displayHeight = videoValue.size.height;

    if (videoState.rotationDegrees == 90 || videoState.rotationDegrees == 270) {
      final temp = displayWidth;
      displayWidth = displayHeight;
      displayHeight = temp;
    }

    const tolerance = 1.05;
    final isLandscape = displayWidth > displayHeight * tolerance;
    final fit = isLandscape ? BoxFit.contain : BoxFit.cover;

    return FittedBox(
      fit: fit,
      alignment: Alignment.center,
      child: SizedBox(
        width: videoValue.size.width,
        height: videoValue.size.height,
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
  }
}

Widget getProfileIcon(AmityStoryTarget? storyTarget) {
  if (storyTarget == null) {
    return const AmityNetworkImage(
        imageUrl: "",
        placeHolderPath:
            "assets/Icons/amity_ic_community_avatar_placeholder.svg");
  }
  if (storyTarget is AmityStoryTargetCommunity) {
    return storyTarget.community?.avatarImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AmityNetworkImage(
              imageUrl: storyTarget.community!.avatarImage!.fileUrl!,
              placeHolderPath:
                  "assets/Icons/amity_ic_community_avatar_placeholder.svg",
            ),
          )
        : const AmityNetworkImage(
            imageUrl: "",
            placeHolderPath:
                "assets/Icons/amity_ic_community_avatar_placeholder.svg",
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
  ShareButton(
      {super.key,
      required this.onClick,
      required this.storyTarget,
      this.componentId,
      this.pageId})
      : super(
            pageId: pageId,
            componentId: componentId,
            elementId: "share_story_button");

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
                "Share Story",
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
