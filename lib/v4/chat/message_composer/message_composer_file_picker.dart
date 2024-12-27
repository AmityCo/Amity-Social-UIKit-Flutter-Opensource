import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

extension MessageComposerFilePicker on AmityMessageComposer {
  void pickMultipleFiles(BuildContext context, String appName, FileType type,
      {int maxFiles = 10}) async {
    try {
      MediaPermissionHandler().pickImageAndVideo().then((files) {
        if (files.isNotEmpty) {
          for (var media in files) {
            context.read<MessageComposerBloc>().add(
                  MessageComposerSelectImageAndVideoEvent(selectedMedia: media),
                );
          }
        } else {
          toastBloc.add(AmityToastDismiss());
        }
      });
    } catch (e) {}
    return null;
  }
}
