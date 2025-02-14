import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/video_post_player/pager/bloc/video_post_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/SingleVideoPlayer/bloc/single_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SingleVideoPlayer extends StatelessWidget with ChangeNotifier {
  final AmityPost post;

  SingleVideoPlayer({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SingleVideoPlayerBloc(posts: posts, initialIndex: initialIndex),
      child:
          VideoPostPlayerBuilder(context: context, initialIndex: initialIndex)
              .build(),
    );
  }
}

class VideoPostPlayerBuilder with ChangeNotifier {
  final BuildContext context;
  final int initialIndex;

  VideoPostPlayerBuilder({required this.context, required this.initialIndex});

  Widget build() {
    return BlocBuilder<VideoPostPlayerBloc, VideoPostPlayerState>(
        builder: (context, state) {
      if (state.posts.length != state.urls.length) {
        context.read<VideoPostPlayerBloc>().add(VideoPostPlayerEventInitial());
      }
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            '${state.currentIndex + 1}/${state.posts.length}',
            style: const TextStyle(color: Colors.white),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          centerTitle: true,
          leading: Container(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/Icons/amity_ic_close_viewer.svg',
                  package: 'amity_uikit_beta_service',
                  width: 32,
                  height: 32,
                ),
                color: Colors.white,
                onPressed: () {
                  context
                      .read<VideoPostPlayerBloc>()
                      .add(VideoPostPlayerEventDispose());
                  Navigator.of(context).pop();
                },
              )),
        ),
        body: PageView.builder(
          itemCount: state.posts.length,
          controller: PageController(initialPage: initialIndex),
          onPageChanged: (index) {
            context
                .read<VideoPostPlayerBloc>()
                .add(VideoPostPlayerEventPageChanged(currentIndex: index));
          },
          itemBuilder: (context, index) {
            if (state.urls.isEmpty) {
              return Center(
                  child: loadingIndicator(context, size: 50, strokeWidth: 5));
            } else {
              if (index == state.currentIndex) {
                if (state.videoController == null) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(state.thumbnails[index]),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                } else {
                  return Chewie(
                    controller: ChewieController(
                      videoPlayerController: state.videoController!,
                      showControlsOnInitialize: false,
                      autoInitialize: true,
                      aspectRatio: state.videoController!.value.aspectRatio,
                      autoPlay: true,
                      looping: true,
                    ),
                  );
                }
              } else {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(state.thumbnails[index]),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }
            }
          },
        ),
      );
    });
  }

  Widget loadingIndicator(BuildContext context,
      {double? size, double? strokeWidth}) {
    final appTheme = Provider.of<ConfigProvider>(context).getTheme(null, null);
    return SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: CircularProgressIndicator(
        color: Provider.of<AmityUIConfiguration>(context).appColors.primary,
        strokeWidth: strokeWidth ?? 2,
        valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
      ),
    );
  }

  @override
  void dispose() {
    context.read<VideoPostPlayerBloc>().add(VideoPostPlayerEventDispose());
    super.dispose();
  }
}
