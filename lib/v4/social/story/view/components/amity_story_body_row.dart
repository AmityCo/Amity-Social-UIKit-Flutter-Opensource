import 'dart:io';
import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_story_hyperlink_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/story_video_player_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_cache.dart';
import 'package:amity_uikit_beta_service/v4/social/story/utils/story_palette_preloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';

class AmityStoryBodyRow extends StatefulWidget {
  final AmityStoryDataType dataType;
  final AmityStoryData data;
  final AmityStorySyncState state;
  final List<AmityStoryItem> items;
  final bool isVisible;
  final Function(bool) onTap;
  final Function(bool) onHold;
  final Function onSwipeUp;
  final Function onSwipeDown;
  final Function(HyperLink)? onHyperlinkClick;
  final String storyId; // Story ID for global palette cache lookup

  AmityStoryBodyRow(
      {super.key,
      required this.dataType,
      required this.data,
      required this.state,
      required this.items,
      required this.isVisible,
      required this.onTap,
      required this.onHold,
      required this.onSwipeUp,
      required this.onSwipeDown,
      this.onHyperlinkClick,
      required this.storyId});

  @override
  State<AmityStoryBodyRow> createState() => _AmityStoryBodyRowState();
}

class _AmityStoryBodyRowState extends State<AmityStoryBodyRow> {
  bool showBottomSheet = false;
  bool isVolumeOn = true;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('DismissibleAmityStoryBodyRow'),
      direction: DismissDirection.vertical,
      onDismissed: (direction) {
        if (direction == DismissDirection.up) {
          widget.onSwipeUp();
        } else if (direction == DismissDirection.down) {
          widget.onSwipeDown();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            getContent(widget.dataType),
            Positioned.fill(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: GestureDetector(
                  onTapDown: (details) {
                    var position = details.globalPosition;
                    if (position.dx < MediaQuery.of(context).size.width / 2) {
                      widget.onTap(false);
                    } else {
                      widget.onTap(true);
                    }
                  },
                  onLongPressStart: (details) {
                    widget.onHold(true);
                  },
                  onLongPressEnd: (details) {
                    widget.onHold(false);
                  },
                  onVerticalDragStart: (details) {
                    // onSwipeUp();
                  },
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0) {
                    } else {
                      showBottomSheet = true;
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (showBottomSheet) {
                      widget.onSwipeUp();
                      showBottomSheet = false;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            (widget.items.isNotEmpty && widget.items.first is HyperLink)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AmityStoryBodyHyperlinkView(
                          hyperlinkItem: widget.items.first as HyperLink,
                          onHyperlinkClick: widget.onHyperlinkClick!),
                    ),
                  )
                : Container(),
            (widget.dataType == AmityStoryDataType.VIDEO)
                ? Positioned(
                    top: 90,
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isVolumeOn = !isVolumeOn;
                        });
                        BlocProvider.of<StoryVideoPlayerBloc>(context)
                            .add(const VolumeChangedEvent());
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
                            isVolumeOn
                                ? "assets/Icons/ic_volume_white.svg"
                                : "assets/Icons/ic_volume_off_white.svg",
                            package: 'amity_uikit_beta_service',
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget getContent(AmityStoryDataType dataType) {
    switch (dataType) {
      case AmityStoryDataType.IMAGE:
        return AmityStoryBodyImageView(
          data: widget.data as ImageStoryData,
          syncState: widget.state,
          storyId:
              widget.storyId, // Pass story ID for global palette cache lookup
        );

      case AmityStoryDataType.VIDEO:
        if (!widget.isVisible) {
          BlocProvider.of<StoryVideoPlayerBloc>(context)
              .add(const PauseStoryVideoEvent());
        }
        return AmityStoryBodyVideoView(
            data: widget.data as VideoStoryData, syncState: widget.state);

      default:
        return Container();
    }
  }
}

class AmityStoryBodyImageView extends StatefulWidget {
  final ImageStoryData data;
  final AmityStorySyncState syncState;
  final bool shouldPreload; // New parameter for preloading control
  final String storyId; // Story ID for global palette cache lookup

  AmityStoryBodyImageView({
    super.key,
    required this.data,
    required this.syncState,
    this.shouldPreload = false, // Default to false
    required this.storyId, // Story ID is required
  });

  @override
  State<AmityStoryBodyImageView> createState() =>
      _AmityStoryBodyImageViewState();
}

class _AmityStoryBodyImageViewState extends State<AmityStoryBodyImageView> {
  bool _isImageReady = false; // Track image load state
  bool _isPaletteReady = false; // Track palette calculation state
  bool _isCalculatingPalette = false; // Track if calculation is in progress
  Color _dominantColor = Colors.black; // Default color
  Color _vibrantColor = Colors.grey.shade800; // Default color
  PaletteGenerator? _paletteGenerator;

  @override
  void initState() {
    super.initState();

    // Use global palette cache with story ID (persists across communities!)
    final globalCache = StoryPaletteCache();
    final cachedPalette = globalCache.get(widget.storyId);

    if (cachedPalette != null) {
      _paletteGenerator = cachedPalette;
      final newDominantColor =
          _paletteGenerator?.dominantColor?.color.withOpacity(0.7);
      final newVibrantColor =
          _paletteGenerator?.darkMutedColor?.color.withOpacity(0.7);
      if (newDominantColor != null) _dominantColor = newDominantColor;
      if (newVibrantColor != null) _vibrantColor = newVibrantColor;
      _isPaletteReady = true; // Palette is ready from global cache!
    }

    // Request palette generation via shared preloader if needed
    _ensurePalette();

    // Preload image if requested (for next/previous pages)
    if (widget.shouldPreload) {
      _preloadImage();
    }
  }

  @override
  void didUpdateWidget(covariant AmityStoryBodyImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storyId != widget.storyId) {
      _paletteGenerator = null;
      _isPaletteReady = false;
      _isCalculatingPalette = false;
      _dominantColor = Colors.black;
      _vibrantColor = Colors.grey.shade800;

      final globalCache = StoryPaletteCache();
      final cachedPalette = globalCache.get(widget.storyId);
      if (cachedPalette != null) {
        _applyPalette(cachedPalette);
        _isPaletteReady = true;
      }

      _ensurePalette();
    }
  }

  // Preload image into cache
  void _preloadImage() async {
    try {
      final imageProvider = widget.data.image.hasLocalPreview != null &&
              widget.data.image.hasLocalPreview!
          ? FileImage(File(widget.data.image.getFilePath!)) as ImageProvider
          : NetworkImage(widget.data.image.getUrl(AmityImageSize.MEDIUM));

      // Preload with memory constraints
      await precacheImage(
        ResizeImage(
          imageProvider,
          width: 1080,
          height: 1920,
          allowUpscaling: false,
        ),
        context,
      );
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Non-blocking palette generation with optimized sample size and microtask batching
  void _ensurePalette() {
    if (widget.data.imageDisplayMode == AmityStoryImageDisplayMode.FILL) {
      _isPaletteReady = true;
      _isCalculatingPalette = false;
      return;
    }

    if (_isPaletteReady || _isCalculatingPalette) return;

    final globalCache = StoryPaletteCache();
    if (globalCache.has(widget.storyId)) {
      final cachedPalette = globalCache.get(widget.storyId);
      if (cachedPalette != null) {
        _applyPalette(cachedPalette);
      }
      return;
    }

    _isCalculatingPalette = true;

    StoryPalettePreloader()
        .ensurePaletteForImageData(
            storyId: widget.storyId, imageData: widget.data)
        .then((palette) {
      if (!mounted) return;

      if (palette != null) {
        _applyPalette(palette);
      }

      setState(() {
        _isPaletteReady = true;
        _isCalculatingPalette = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _isPaletteReady = true;
        _isCalculatingPalette = false;
      });
    });
  }

  void _applyPalette(PaletteGenerator palette) {
    _paletteGenerator = palette;
    final newDominantColor = palette.dominantColor?.color.withOpacity(0.7);
    final newVibrantColor = palette.darkMutedColor?.color.withOpacity(0.7);

    if (newDominantColor != null || newVibrantColor != null) {
      _dominantColor = newDominantColor ?? _dominantColor;
      _vibrantColor = newVibrantColor ?? _vibrantColor;
    }
  }

  @override
  void dispose() {
    // Clear palette generator reference to help garbage collection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient (always visible)
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(
                milliseconds: 300), // Slower transition reduces frame drops
            curve: Curves.easeOut, // Smooth easing
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _dominantColor,
                  _vibrantColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Image with synchronized display and blur transition
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: widget.data.image.hasLocalPreview != null &&
                  widget.data.image.hasLocalPreview!
              ? Image.file(
                  File(widget.data.image.getFilePath!),
                  fit: widget.data.imageDisplayMode ==
                          AmityStoryImageDisplayMode.FILL
                      ? BoxFit.cover
                      : BoxFit.contain,
                  cacheWidth: 1080, // Constrain memory cache to 1080p width
                  cacheHeight: 1920, // Constrain memory cache to 1080p height
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    // Mark image as ready when loaded
                    if (frame != null && !_isImageReady) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_isImageReady) {
                          setState(() {
                            _isImageReady = true;
                          });
                        }
                      });
                    }

                    if (wasSynchronouslyLoaded) {
                      // Synchronously loaded (from cache) - apply blur fade
                      return _buildBlurFadeTransition(child);
                    }

                    // Async load - fade in with blur
                    return AnimatedOpacity(
                      opacity: frame == null ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: _buildBlurFadeTransition(child),
                    );
                  },
                )
              : CachedNetworkImage(
                  fadeInDuration:
                      const Duration(milliseconds: 200), // Fast fade-in
                  fadeOutDuration:
                      const Duration(milliseconds: 100), // Fast fade-out
                  placeholder: (context, url) => Container(
                    // Minimal placeholder - just background gradient (already visible)
                    color: Colors.transparent,
                  ),
                  imageUrl: widget.data.image.getUrl(AmityImageSize.MEDIUM),
                  memCacheWidth: 1080, // Limit memory cache to 1080p width
                  memCacheHeight: 1920, // Limit memory cache to 1080p height
                  maxWidthDiskCache: 1080, // Limit disk cache to 1080p width
                  maxHeightDiskCache: 1920, // Limit disk cache to 1080p height
                  imageBuilder: (context, imageProvider) {
                    // Mark image as ready
                    if (!_isImageReady) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_isImageReady) {
                          setState(() {
                            _isImageReady = true;
                          });
                        }
                      });
                    }

                    return _buildBlurFadeTransition(
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: widget.data.imageDisplayMode ==
                                    AmityStoryImageDisplayMode.FILL
                                ? BoxFit.cover
                                : BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Build smooth blur-to-clear transition that masks color changes
  Widget _buildBlurFadeTransition(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin:
            _isPaletteReady ? 0.0 : 8.0, // Start blurred if palette not ready
        end: 0.0, // Always end at clear
      ),
      duration: const Duration(milliseconds: 300), // Smooth blur fade
      curve: Curves.easeOut,
      builder: (context, blurValue, child) {
        if (blurValue == 0.0) {
          // No blur needed - return child directly for performance
          return child!;
        }

        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
            tileMode: TileMode.decal,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class AmityStoryBodyVideoView extends StatelessWidget {
  final VideoStoryData data;
  final AmityStorySyncState syncState;

  const AmityStoryBodyVideoView(
      {super.key, required this.data, required this.syncState});

  @override
  Widget build(BuildContext context) {
    final storyVideoBloc = context.read<StoryVideoPlayerBloc>();
    final viewStoryBloc = context.read<ViewStoryBloc>();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AmityStoryVideoPlayer(
        showVolumeControl: true,
        video:
            (data.video.hasLocalPreview != null && data.video.hasLocalPreview!)
                ? File(data.video.getFilePath!)
                : null,
        onInitializing: () {
          StoryTimerStateManager.currentValue = -1;
          viewStoryBloc.add(ShoudPauseEvent(shouldPause: true));
        },
        onWidgetDispose: (isFinalDispose) {
          if (isFinalDispose) {
            storyVideoBloc.add(const DisposeStoryVideoPlayerEvent());
          } else {
            storyVideoBloc.add(const PauseStoryVideoEvent());
          }
        },
        url: (data.video.hasLocalPreview != null && data.video.hasLocalPreview!)
            ? null
            : data.video.fileUrl!,
        onInitialize: () {
          StoryTimerStateManager.totalValue = storyVideoBloc.state.duration;
          viewStoryBloc.add(ShoudPauseEvent(shouldPause: false));
        },
        onPause: () {},
        onPlay: () {},
      ),
    );
  }
}

class AmityStoryBodyHyperlinkView extends StatelessWidget {
  final HyperLink hyperlinkItem;
  final Function(HyperLink) onHyperlinkClick;
  const AmityStoryBodyHyperlinkView(
      {super.key, required this.hyperlinkItem, required this.onHyperlinkClick});

  @override
  Widget build(BuildContext context) {
    return AmityStoryHyperlinkView(
        hyperlink: hyperlinkItem,
        onClick: () {
          onHyperlinkClick(hyperlinkItem);
        });
  }
}
