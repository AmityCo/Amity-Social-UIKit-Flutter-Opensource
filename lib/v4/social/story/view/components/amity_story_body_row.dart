import 'dart:io';
import 'dart:ui';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/social/story/hyperlink/elements/amity_story_hyperlink_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/amity_view_community_story_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/bloc/view_story_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/bloc/story_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/components/story_video_player/story_video_player_view.dart';
import 'package:amity_uikit_beta_service/v4/social/story/view/elements/amity_story_single_segment_timer_element.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

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

  AmityStoryBodyRow({super.key, required this.dataType, required this.data, required this.state, required this.items, required this.isVisible, required this.onTap, required this.onHold, required this.onSwipeUp, required this.onSwipeDown, this.onHyperlinkClick});

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
                child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        widget.onTap(false);
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
                        if (details.delta.dy > 0)
                          {}
                        //SWIPE DOWN
                        else
                          showBottomSheet = true;
                        // SWIPE UP
                      },
                      onVerticalDragEnd: (details) {
                        if (showBottomSheet) {
                          widget.onSwipeUp();
                          showBottomSheet = false;
                        }
                        // onSwipeDown();
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        widget.onTap(true);
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
                        if (details.delta.dy > 0)
                          {}
                        //SWIPE DOWN
                        else
                          showBottomSheet = true;
                        // SWIPE UP
                      },
                      onVerticalDragEnd: (details) {
                        if (showBottomSheet) {
                          widget.onSwipeUp();
                          showBottomSheet = false;
                        }
                        // onSwipeDown();
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                  )
                ],
              ),
            )),
            (widget.items.isNotEmpty && widget.items.first is HyperLink)
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AmityStoryBodyHyperlinkView(hyperlinkItem: widget.items.first as HyperLink, onHyperlinkClick: widget.onHyperlinkClick!),
                    ),
                  )
                : Container(),

            (widget.dataType == AmityStoryDataType.VIDEO)?
            
            Positioned(
                  top: 90,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isVolumeOn = !isVolumeOn;
                      });
                      BlocProvider.of<StoryVideoPlayerBloc>(context).add(const VolumeChangedEvent());
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
                           isVolumeOn ? "assets/Icons/ic_volume_white.svg"  :  "assets/Icons/ic_volume_off_white.svg",
                          package: 'amity_uikit_beta_service',
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                )
            :Container()
            
          ],
        ),
      ),
    );
  }

  Widget getContent(AmityStoryDataType dataType) {
    switch (dataType) {
      case AmityStoryDataType.IMAGE:
        return AmityStoryBodyImageView(data: widget.data as ImageStoryData, syncState: widget.state);

      case AmityStoryDataType.VIDEO:
        var videoData = widget.data as VideoStoryData;
        if(!widget.isVisible){
          BlocProvider.of<StoryVideoPlayerBloc>(context).add(const PauseStoryVideoEvent());
        }
        return AmityStoryBodyVideoView(data: widget.data as VideoStoryData, syncState: widget.state, videoPlayerController: AmityViewCommunityStoryPage.videoPlayerController);

      default:
        return Container();
    }
  }
}

class AmityStoryBodyImageView extends StatelessWidget {
  final ImageStoryData data;
  final AmityStorySyncState syncState;
  bool isImageLoaded = false;

  AmityStoryBodyImageView({
    super.key,
    required this.data,
    required this.syncState,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(



      
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: CachedNetworkImage(
              imageUrl: data.image.getUrl(AmityImageSize.FULL),
              progressIndicatorBuilder: (context, url, progress) {
                return Shimmer.fromColors(
                  baseColor: Color(0xff292b32),
                  highlightColor: Color(0xff3c3e48),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: data.image.hasLocalPreview != null && data.image.hasLocalPreview!
              ? Image.file(
                  File(data.image.getFilePath!),
                  fit: data.imageDisplayMode == AmityStoryImageDisplayMode.FILL ? BoxFit.cover : BoxFit.contain,
                )
              : CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, progress) {
                    return Shimmer.fromColors(
                      baseColor: const Color(0xff292b32),
                      highlightColor: const Color(0xff3c3e48),
                      direction: ShimmerDirection.ttb,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    );
                  },
                  imageUrl: data.image.getUrl(AmityImageSize.FULL),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: data.imageDisplayMode == AmityStoryImageDisplayMode.FILL ? BoxFit.cover : BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AmityStoryBodyVideoView extends StatelessWidget {
  final VideoStoryData data;
  final AmityStorySyncState syncState;
  VideoPlayerController? videoPlayerController;
  AmityStoryBodyVideoView({super.key, required this.data, required this.syncState, this.videoPlayerController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AmityStoryVideoPlayer(
        showVolumeControl: true,
        video: (data.video.hasLocalPreview != null && data.video.hasLocalPreview!) ? File(data.video.getFilePath!) : null,
        onInitializing: () {
          AmityStorySingleSegmentTimerElement.currentValue = -1;
          BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: true));
        },
        onWidgetDispose: () {
          BlocProvider.of<StoryVideoPlayerBloc>(context).add(const DisposeStoryVideoPlayerEvent());
        },
        url: (data.video.hasLocalPreview != null && data.video.hasLocalPreview!) ? null : data.video.fileUrl!,
        onInitialize: () {
          AmityStorySingleSegmentTimerElement.totalValue = BlocProvider.of<StoryVideoPlayerBloc>(context).state.duration;
          BlocProvider.of<ViewStoryBloc>(context).add(ShoudPauseEvent(shouldPause: false));
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
  const AmityStoryBodyHyperlinkView({super.key, required this.hyperlinkItem, required this.onHyperlinkClick});

  @override
  Widget build(BuildContext context) {
    return AmityStoryHyperlinkView(
        hyperlink: hyperlinkItem,
        onClick: () {
          onHyperlinkClick(hyperlinkItem);
        });
  }
}
