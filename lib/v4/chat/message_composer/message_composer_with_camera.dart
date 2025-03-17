import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_camera_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/utils/navigation_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

extension MessageComposerWithCamera on AmityMessageComposer {
  void onCameraTap(BuildContext context) {
    Navigator.push(
      context,
      BottomToTopAnimatedRoute(
        AmityMessageCameraScreen(
          selectedFileType: selectedMediaType,
          avatarUrl: avatarUrl,
        ),
      ),
    ).then(
      (value) {
        AmityCameraResult? result = value;
        if (result != null) {
          context.read<MessageComposerBloc>().add(
              MessageComposerSelectImageAndVideoEvent(
                selectedMedia: result.file,
                fromCamera: true
              ),
            );  
        }
      },
    );
  }
}
