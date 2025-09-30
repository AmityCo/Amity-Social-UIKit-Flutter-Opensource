import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/parent_message_cache.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
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
        // Create metadata for mentions if they exist
        Map<String, dynamic> metadata = {};
        if (event.mentionMetadataList.isNotEmpty) {
          metadata = AmityMentionMetadataCreator(event.mentionMetadataList).create();
        }

        final messageBuilder = AmityChatClient.newMessageRepository()
            .createMessage(subChannelId)
            .parentId(replyTo?.messageId)
            .text(event.text.trim());
        
        if (event.mentionMetadataList.isNotEmpty) {
          messageBuilder.metadata(metadata);
          
          // Check if "@All" mention is present (exact match)
          bool hasAllMention = event.mentionUserIds.contains("all");
          
          if (hasAllMention) {
            // Use mentionChannel for @All mentions
            messageBuilder.mentionChannel();
          }
          
          // Always handle regular user mentions (excluding "all")
          final regularUserIds = event.mentionUserIds.where((id) => id != "all").toList();
          if (regularUserIds.isNotEmpty) {
            messageBuilder.mentionUsers(regularUserIds);
          }
        }
        await messageBuilder.send();
      } catch (error) {
        if (error is AmityException) {
          if (error.code == error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message contains inappropriate word. Please review and delete it."));
          } else if (error.code == error.getErrorCode(AmityErrorCode.LINK_NOT_IN_WHITELIST)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message wasn't sent as it contains a link that's not allowed."));
          } else if (error.code == 400000) {
            // Message too long error
            final context = NavigationService.navigatorKey.currentContext;
            if (context != null && context.mounted) {
              AmityV4Dialog().showAlertErrorDialog(
                title: context.l10n.error_message_too_long_title,
                message: context.l10n.error_message_too_long_description,
                closeText: context.l10n.general_done,
              );
            }
          }
        }
      }
    });

    on<MessageComposerUpdateTextMessage>((event, emit) async {
      MessageComposerCache().updateText("");
      emit(state.copyWith(text: "", replyTo: null));
      try {
        // Get the message first to preserve existing metadata
        AmityMessage? originalMessage;
        try {
          originalMessage = await AmityChatClient.newMessageRepository()
              .getMessage(event.messageId);
        } catch (e) {
        }
              
        // Create metadata for mentions if they exist
        Map<String, dynamic> metadata = {};
        
        // Only update the 'mentioned' part of metadata, preserve everything else
        if (originalMessage?.metadata != null) {
          // Copy all existing metadata
          metadata = Map<String, dynamic>.from(originalMessage!.metadata!);
          
          // Check for any channel mentions in the original metadata
          if (metadata.containsKey('mentioned')) {
            final List<dynamic> originalMentions = metadata['mentioned'] as List<dynamic>;
            List<Map<String, dynamic>> channelMentions = [];
            
            // Extract channel mentions to preserve them
            for (var mention in originalMentions) {
              if (mention is Map<String, dynamic> && 
                  mention.containsKey('type') && 
                  mention['type'] == 'channel') {
                channelMentions.add(Map<String, dynamic>.from(mention));
              }
            }
            
            // Store channel mentions for later
            if (channelMentions.isNotEmpty) {
              metadata['_channelMentions'] = channelMentions;
            }
          }
        }
        
        // Update the 'mentioned' part with new user mentions
        List<dynamic> allMentions = [];
        
        // Add user mentions if they exist
        if (event.mentionMetadataList.isNotEmpty) {
          final mentionData = AmityMentionMetadataCreator(event.mentionMetadataList).create();
          allMentions.addAll(mentionData['mentioned'] as List<dynamic>);
          
        }
        
        // Add back any channel mentions that were in the original message
        if (metadata.containsKey('_channelMentions')) {
          final List<dynamic> channelMentions = metadata['_channelMentions'] as List<dynamic>;
          allMentions.addAll(channelMentions);
          metadata.remove('_channelMentions'); // Remove temporary storage
          
        }
        
        // Update final metadata
        if (allMentions.isNotEmpty) {
          metadata['mentioned'] = allMentions;
        } else {
          // If no mentions in updated text, remove the mention metadata
          metadata.remove('mentioned');
        }
        
        final messageBuilder = AmityChatClient.newMessageRepository()
            .editTextMessage(event.messageId)
            .text(event.text.trim());
            
        // Always update metadata to either include mentions or remove them
        messageBuilder.metadata(metadata);
        
        await messageBuilder.update();
      } catch (error) {
        if (error is AmityException) {
          if (error.code == error.getErrorCode(AmityErrorCode.BAN_WORD_FOUND)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message contains inappropriate word. Please review and delete it."));
          } else if (error.code == error.getErrorCode(AmityErrorCode.LINK_NOT_IN_WHITELIST)) {
            toastBloc.add(const AmityToastShort(
                message:
                    "Your message wasn't sent as it contains a link that's not allowed."));
          } else if (error.code == 400000) {
            // Message too long error
            final context = NavigationService.navigatorKey.currentContext;
            if (context != null && context.mounted) {
              AmityV4Dialog().showAlertErrorDialog(
                title: context.l10n.error_message_too_long_title,
                message: context.l10n.error_message_too_long_description,
                closeText: context.l10n.general_done,
              );
            }
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
              if (error is AmityException) {
                if (error.code == error.getErrorCode(AmityErrorCode.LINK_NOT_IN_WHITELIST)) {
                  toastBloc.add(const AmityToastShort(
                      message:
                          "Your message wasn't sent as it contains a link that's not allowed."));
                } else {
                  toastBloc.add(AmityUIKitToastLong(
                      message: "Failed to send image: ${error.toString()}",
                      bottomPadding: AmityChatPage.toastBottomPadding));
                }
              } else {
                toastBloc.add(AmityUIKitToastLong(
                    message: "Failed to send image: ${error.toString()}",
                    bottomPadding: AmityChatPage.toastBottomPadding));
              }
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
                if (error is AmityException) {
                  if (error.code == error.getErrorCode(AmityErrorCode.LINK_NOT_IN_WHITELIST)) {
                    toastBloc.add(const AmityToastShort(
                        message:
                            "Your message wasn't sent as it contains a link that's not allowed."));
                  } else {
                    toastBloc.add(AmityToastShort(
                        message: "Failed to send video: ${error.toString()}",
                        bottomPadding: AmityChatPage.toastBottomPadding));
                  }
                } else {
                  toastBloc.add(AmityToastShort(
                      message: "Failed to send video: ${error.toString()}",
                      bottomPadding: AmityChatPage.toastBottomPadding));
                }
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
