import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:amity_uikit_beta_service/v4/utils/media_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'message_composer_events.dart';
part 'message_composer_state.dart';

class MessageComposerBloc
    extends Bloc<MessageComposerEvent, MessageComposerState> {
  final String subChannelId;
  final TextEditingController controller;
  final ScrollController scrollController;
  final AmityMessage? replyTo;
  final AmityMessage? editingMessage;
  final AmityToastBloc toastBloc;

  MessageComposerBloc({
    required this.subChannelId,
    required this.controller,
    required this.scrollController,
    required this.replyTo,
    required this.editingMessage,
    required this.toastBloc,
  }) : super(MessageComposerState(
            controller: controller,
            scrollController: scrollController,
            text: "",
            replyTo: replyTo,
            showMediaSection: false,
            appName: "")) {
    on<MessageComposerGetAppName>((event, emit) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      emit(state.copyWith(appName: packageInfo.appName));
    });

    on<MessageComposerTextChange>((event, emit) {
      if (editingMessage == null) {
        MessageComposerCache().updateText(event.text);
      }
      emit(state.copyWith(text: event.text));
    });

    on<MessageComposerCreateTextMessage>((event, emit) async {
      MessageComposerCache().updateText("");
      emit(state.copyWith(
        text: "",
        replyTo: null,
      ));
      try {
        final replyTo = this.replyTo;
        if (replyTo != null) {
          ParentMessageCache().addMessage(replyTo.messageId!, replyTo);
        }
        await AmityChatClient.newMessageRepository()
            .createMessage(subChannelId)
            .parentId(replyTo?.messageId)
            .text(event.text.trim())
            .send();
      } catch (error) {
        if (error != null && error is AmityException) {
          if (error.code == error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message contains inappropriate word. Please review and delete it."));
          }
        }
      }
    });

    on<MessageComposerUpdateTextMessage>((event, emit) async {
      MessageComposerCache().updateText("");
      emit(state.copyWith(text: "", replyTo: null));
      try {
        await AmityChatClient.newMessageRepository()
            .updateMessage(subChannelId, event.messageId)
            .text(event.text.trim())
            .update();
      } catch (error) {
        if (error != null && error is AmityException) {
          if (error.code == error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message contains inappropriate word. Please review and delete it."));
          }
        }
      }
    });

    on<MessageComposerMediaExpanded>((event, emit) {
      emit(state.copyWith(showMediaSection: true));
    });

    on<MessageComposerMediaCollapsed>((event, emit) {
      emit(state.copyWith(showMediaSection: false));
    });

    on<MessageComposerSelectImageAndVideoEvent>((event, emit) async {
      try {
        final fileSize = await event.selectedMedia.length();
        if (fileSize > 1 * 1024 * 1024 * 1024) {
          toastBloc.add(const AmityToastShort(
              message:
                  "The selected file is too large. Please select a file smaller than 1GB."));
        } else {
          final isImage = await isImageFileMime(event.selectedMedia);
          if (isImage) {
            final imagePath = event.selectedMedia.path;
            final uri = Uri(path: imagePath);
            try {
              final replyTo = this.replyTo;
              if (replyTo != null) {
                ParentMessageCache().addMessage(replyTo.messageId!, replyTo);
              }
              await AmityChatClient.newMessageRepository()
                  .createMessage(subChannelId)
                  .parentId(state.replyTo?.messageId)
                  .image(uri)
                  .send();
            } catch (error) {
              toastBloc.add(AmityUIKitToastLong(
                  message: "Failed to send image: ${error.toString()}",
                  bottomPadding: AmityChatPage.toastBottomPadding));
            }
          } else {
            final isVideo = await isVideoFileMime(event.selectedMedia);
            // Some devices doesn't save recorded video in mime type video
            if (isVideo || event.fromCamera) {
              final videoPath = event.selectedMedia.path;
              final uri = Uri(path: videoPath);
              try {
                final replyTo = this.replyTo;
                if (replyTo != null) {
                  ParentMessageCache().addMessage(replyTo.messageId!, replyTo);
                }
                await AmityChatClient.newMessageRepository()
                    .createMessage(subChannelId)
                    .parentId(state.replyTo?.messageId)
                    .video(uri)
                    .send();
              } catch (error) {
                toastBloc.add(AmityToastShort(
                    message: "Failed to send video: ${error.toString()}",
                    bottomPadding: AmityChatPage.toastBottomPadding));
              }
            }
          }
        }
      } catch (error) {}
    });

    // Fetch app name on first load
    add(MessageComposerGetAppName());
  }

  @override
  Future<void> close() async {
    state.controller.dispose();
    state.scrollController.dispose();
    super.close();
  }
}
