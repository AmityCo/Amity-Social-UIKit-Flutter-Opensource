import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

extension MessageComposerFilePicker on AmityMessageComposer {
  void pickMultipleFiles(BuildContext context, String appName, FileType type,
      {int maxFiles = 10}) async {
    try {
      final granted = await MediaPermissionHandler().handleMediaPermissions();
      if (!granted) {
        toastBloc.add(AmityToastDismiss());
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final path = pickedFile.path;
        if (path != null) {
          final selectedMedia = XFile(path);
          action.onMessageCreated();
          if (!context.mounted) return;
          context.read<MessageComposerBloc>().add(
                MessageComposerSelectImageAndVideoEvent(
                  selectedMedia: selectedMedia,
                ),
              );
          return;
        }
      }

      toastBloc.add(AmityToastDismiss());
    } catch (e) {
      toastBloc.add(AmityToastDismiss());
    }
  }
}
