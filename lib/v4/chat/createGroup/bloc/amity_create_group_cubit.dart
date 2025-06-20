import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'dart:io';
import 'dart:async';

part 'amity_create_group_state.dart';

class AmityCreateGroupCubit extends Cubit<AmityCreateGroupState> {
  AmityCreateGroupCubit() : super(const AmityCreateGroupState());

  void updateGroupName(String name) {
    emit(state.copyWith(groupName: name));
  }

  void updatePrivacySetting(bool isPublic) {
    emit(state.copyWith(isPublic: isPublic));
  }

  void updateGroupImage(File? image) {
    emit(state.copyWith(groupImage: image));
  }

  void removeGroupImage() {
    emit(state.copyWith(groupImage: null));
  }

  Future<void> createGroup({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
    File? groupImage,
  }) async {
    emit(state.copyWith(status: CreateGroupStatus.loading));

    try {
      if (groupImage != null) {
        // Upload image first, then create group with avatar
        await _createGroupWithAvatar(
          groupName: groupName,
          isPublic: isPublic,
          users: users,
          imageFile: groupImage,
        );
      } else {
        // Create group without avatar
        await _createGroupWithoutAvatar(
          groupName: groupName,
          isPublic: isPublic,
          users: users,
        );
      }
    } catch (e) {
      if (e is UploadImageError) {
        emit(state.copyWith(
          status: CreateGroupStatus.uploadImageFailed,
          errorTitle: e.title,
          error: e.message,
        ));
      } else {
        // Handle other types of errors
        emit(state.copyWith(
          status: CreateGroupStatus.failure,
          errorTitle: "Upload Failed",
          error: "Please try again.",
        ));
      }
    }
  }

  Future<void> _createGroupWithAvatar({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
    required File imageFile,
  }) async {
    final completer = Completer<void>();

    AmityCoreClient.newFileRepository()
        .uploadImage(imageFile)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {
          // Progress is handled, but we don't emit state changes for progress
        },
        complete: (file) async {
          try {
            final channel = await AmityChatClient.newChannelRepository()
                .createChannel()
                .communityType()
                .withDisplayName(groupName)
                .isPublic(isPublic)
                .userIds(users
                    .where((e) => e.userId != null)
                    .map((e) => e.userId!)
                    .toList())
                .avatar(file)
                .create();

            emit(state.copyWith(
              status: CreateGroupStatus.success,
              createdChannel: channel,
            ));
            completer.complete();
          } catch (e) {
            completer.completeError(e);
          }
        },
        error: (error) {
          final Map<String, dynamic> errorData =
              error.data as Map<String, dynamic>;
          final int uploadErrorCode = errorData["detail"]["error"]["code"];

          String errorTitle;
          String errorMessage;

          if (uploadErrorCode == 403) {
            errorTitle = "Inappropriate image";
            errorMessage = "Please choose a different image to upload.";
          } else {
            errorTitle = "Upload Failed";
            errorMessage = "Please try again.";
          }

          completer.completeError(UploadImageError(
            title: errorTitle,
            message: errorMessage,
          ));
        },
        cancel: () {},
      );
    });

    await completer.future;
  }

  Future<void> _createGroupWithoutAvatar({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
  }) async {
    final channel = await AmityChatClient.newChannelRepository()
        .createChannel()
        .communityType()
        .withDisplayName(groupName)
        .isPublic(isPublic)
        .userIds(
            users.where((e) => e.userId != null).map((e) => e.userId!).toList())
        .create();

    emit(state.copyWith(
      status: CreateGroupStatus.success,
      createdChannel: channel,
    ));
  }

  // Helper method to generate display name from member names
  String generateDisplayNameFromMembers(List<AmityUser> users) {
    if (users.isEmpty) return "";

    final StringBuffer nameBuffer = StringBuffer();
    const int maxLength = 100;
    bool isFirst = true;

    for (final AmityUser user in users) {
      final String displayName = user.displayName ?? "Unknown";

      if (!isFirst) {
        if (nameBuffer.length + 2 + displayName.length > maxLength) {
          break;
        }
        nameBuffer.write(", ");
      } else {
        isFirst = false;
      }

      // Add as much of the name as will fit
      if (nameBuffer.length + displayName.length <= maxLength) {
        nameBuffer.write(displayName);
      } else {
        // Add partial name to reach exactly maxLength
        final int remainingSpace = maxLength - nameBuffer.length;
        if (remainingSpace > 0) {
          nameBuffer.write(displayName.substring(0, remainingSpace));
        }
        break;
      }
    }

    return nameBuffer.toString();
  }
}

class UploadImageError {
  final String title;
  final String message;

  UploadImageError({required this.title, required this.message});
}
