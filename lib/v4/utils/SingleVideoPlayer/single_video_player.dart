import 'package:amity_uikit_beta_service/v4/utils/SingleVideoPlayer/bloc/single_video_player_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SingleVideoPlayer extends StatelessWidget with ChangeNotifier {
  final int initialIndex;
  final String? filePath;
  final String? fileUrl;

  SingleVideoPlayer({
    Key? key,
    required this.filePath,
    required this.fileUrl,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SingleVideoPlayerBloc(filePath: filePath, fileUrl: fileUrl),
      child: VideoPlayerBuilder(context: context, initialIndex: 0).build(),
    );
  }
}

class VideoPlayerBuilder with ChangeNotifier {
  final BuildContext context;
  final int initialIndex;

  VideoPlayerBuilder({required this.context, required this.initialIndex});

  Widget build() {
    return BlocBuilder<SingleVideoPlayerBloc, SingleVideoPlayerState>(
        builder: (context, state) {
      context.read<SingleVideoPlayerBloc>().add(SingleVideoPlayerEventInitial());
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
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
                      .read<SingleVideoPlayerBloc>()
                      .add(SingleVideoPlayerEventDispose());
                  Navigator.of(context).pop();
                },
              )),
        ),
        body: PageView.builder(
          itemCount: 1,
          controller: PageController(initialPage: initialIndex),
          onPageChanged: (index) {
            context
                .read<SingleVideoPlayerBloc>()
                .add(SingleVideoPlayerEventPageChanged(currentIndex: index));
          },
          itemBuilder: (context, index) {
            if (state.videoController == null) {
              return Container();
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
    context.read<SingleVideoPlayerBloc>().add(SingleVideoPlayerEventDispose());
    super.dispose();
  }
}
