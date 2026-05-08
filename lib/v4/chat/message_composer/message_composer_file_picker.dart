import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension MessageComposerFilePicker on AmityMessageComposer {
  void pickMultipleFiles(BuildContext context, String appName, FileType type,
      {int maxFiles = 10}) async {
    
    try {
      // Use pickImageAndVideo which respects Android 14+ partial (limited) media
      // access by enabling Android Photo Picker when access is limited.
      // This replaces the previous FilePicker.platform.pickFiles() call which
      // bypassed Android Photo Picker entirely and showed all files regardless
      // of the user's partial access selection.
      final handler = MediaPermissionHandler();
      final files = await handler.pickImageAndVideo(limit: 1);

      if (files.isNotEmpty) {
        final selectedMedia = files.first;
        action.onMessageCreated();
        if (!context.mounted) return;
        context.read<MessageComposerBloc>().add(
              MessageComposerSelectImageAndVideoEvent(
                selectedMedia: selectedMedia,
              ),
            );
        return;
      }

      toastBloc.add(AmityToastDismiss());
    } catch (e) {
      toastBloc.add(AmityToastDismiss());
    }
  }
}
