import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/single_video_player/pager/bloc/video_message_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class VideoMessagePlayer extends StatelessWidget with ChangeNotifier {
  final AmityMessage message;
  final Function onDelete;

  VideoMessagePlayer({
    Key? key,
    required this.message,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final video = (message.data as MessageVideoData).getVideo();
    final thumbnailUrl =
        (message.data as MessageVideoData).thumbnailImageFile?.fileUrl ?? "";
    return BlocProvider(
      create: (context) =>
          VideoMessagePlayerBloc(video: video, thumbnailUrl: thumbnailUrl),
      child:
          AmityVideoPlayerBuilder(context: context, onDelete: onDelete).build(),
    );
  }
}

class AmityVideoPlayerBuilder with ChangeNotifier {
  final BuildContext context;
  final Function onDelete;

  AmityVideoPlayerBuilder({required this.context, required this.onDelete});

  Widget build() {
    return BlocBuilder<VideoMessagePlayerBloc, VideoMessagePlayerState>(
        builder: (context, state) {
      return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Dismissible(
              key: const Key('dismissible'),
              direction: DismissDirection.down,
              onDismissed: (_) => Navigator.of(context).pop(),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: (state.videoController == null)
                            ? Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(state.thumbnailUrl),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : Chewie(
                                controller: ChewieController(
                                  videoPlayerController: state.videoController!,
                                  showControlsOnInitialize: false,
                                  autoInitialize: true,
                                  aspectRatio:
                                      state.videoController!.value.aspectRatio,
                                  autoPlay: true,
                                  looping: true,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...[
                              GestureDetector(
                                onTap: () {
                                  onDelete();
                                },
                                child: Container(
                                  child: SvgPicture.asset(
                                    'assets/Icons/amity_ic_deleted_message.svg',
                                    package: 'amity_uikit_beta_service',
                                    width: 28,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final permissionHandler =
                                      MediaPermissionHandler();
                                  final bool mediaPermissionGranted =
                                      await permissionHandler
                                          .handleMediaPermissions();
                                  if (mediaPermissionGranted == false) {
                                    context.read<AmityToastBloc>().add(
                                        AmityToastShort(
                                            message: "Permission denied.",
                                            icon: AmityToastIcon.warning,
                                            bottomPadding: AmityChatPage
                                                .toastBottomPadding));
                                    return;
                                  } else {
                                    final saved = await permissionHandler
                                        .downloadAndSaveVideo(state.videoUrl);
                                    if (saved) {
                                      context.read<AmityToastBloc>().add(
                                          AmityToastShort(
                                              message: "Saved video.",
                                              icon: AmityToastIcon.success,
                                              bottomPadding: AmityChatPage
                                                  .toastBottomPadding));
                                    } else {
                                      context.read<AmityToastBloc>().add(
                                          AmityToastShort(
                                              message: "Failed to save video.",
                                              icon: AmityToastIcon.warning,
                                              bottomPadding: AmityChatPage
                                                  .toastBottomPadding));
                                    }
                                  }
                                } catch (e) {
                                  context.read<AmityToastBloc>().add(
                                      AmityToastShort(
                                          message: "Failed to save video.",
                                          icon: AmityToastIcon.warning,
                                          bottomPadding: AmityChatPage
                                              .toastBottomPadding));
                                }
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  'assets/Icons/amity_ic_save_image_white.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 28,
                                  height: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 16, top: Platform.isIOS ? 30 : 0),
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/Icons/amity_ic_close_viewer.svg',
                        package: 'amity_uikit_beta_service',
                        width: 32,
                        height: 32,
                      ),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }

  @override
  void dispose() {
    context
        .read<VideoMessagePlayerBloc>()
        .add(VideoMessagePlayerEventDispose());
    super.dispose();
  }
}
