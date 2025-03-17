import 'dart:developer';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'edit_profile_events.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  var isUpdatingProfile = false;

  EditProfileBloc(String userId)
      : super(EditProfileState(
          userId: userId,
        )) {
    // Profile fetch event
    on<UserProfileFetchEvent>((event, emit) async {
      final displayName = event.user.displayName;
      final about = event.user.description;

      emit(state.copyWith(
          user: event.user, displayName: displayName, about: about));
    });

    on<EditProfileImagePickerEvent>(
      (event, emit) async {
        final XFile? xFile = await ImagePicker()
            .pickImage(source: ImageSource.gallery, requestFullMetadata: true);

        if (xFile != null) {
          final pickedFile = File(xFile.path);

          final allowedExtensions = ["jpg", "jpeg", "png"];
          final fileExtension = pickedFile.path.split(".").last.toLowerCase();

          if (!allowedExtensions.contains(fileExtension)) {
            event.onError();
            return;
          }

          emit(state.copyWith(
              selectedImage: pickedFile, isProfileInfoUpdated: true));
        }
      },
    );

    on<EditProfileAboutChangedEvent>(
      (event, emit) async {
        final isAboutChanged = event.value != state.user?.description;
        final isImageSelected = state.selectedImage != null;

        emit(state.copyWith(
            about: event.value,
            isProfileInfoUpdated: isAboutChanged || isImageSelected));
      },
    );

    on<EditProfileSaveEvent>((event, emit) async {
      if (!state.isProfileInfoUpdated && !isUpdatingProfile) {
        return;
      }

      // Profile update can take some time, so we prevent duplicate requests here.
      isUpdatingProfile = true;

      final editedAbout = state.about;
      UserUpdateQueryBuilder updateBuilder = AmityCoreClient.newUserRepository()
          .updateUser(userId)
          .description(editedAbout ?? "");

      updateOperation() {
        updateBuilder.update().then(
          (user) {
            isUpdatingProfile = false;
            event.onCompletion(isSuccess: true, isUnsafeUploadError: false);
          },
        ).onError(
          (error, stackTrace) {
            isUpdatingProfile = false;
            event.onCompletion(isSuccess: false, isUnsafeUploadError: false);
          },
        );
      }

      if (state.selectedImage != null) {
        _uploadImage(state.selectedImage, onUploadSuccess: (file) {
          updateBuilder.avatarFileId(file.fileId ?? "");
          updateOperation();
        }, onUploadError: (isUnsafeContent) {
          isUpdatingProfile = false;
          event.onCompletion(
              isSuccess: false, isUnsafeUploadError: isUnsafeContent);
        });
      } else {
        debugPrint("No image selected, updating profile without image");
        updateOperation();
      }
    });

    // Fetch user info first
    setupUserInfo(userId);
  }

  void setupUserInfo(String userId) {
    AmityCoreClient.newUserRepository().getUser(userId).then((user) {
      addEvent(UserProfileFetchEvent(user: user));
    }).onError((error, stackTrace) {
      log(error.toString());
    });
  }

  void _uploadImage(
    File? selectedFile, {
    required Function(AmityImage) onUploadSuccess,
    required Function(bool isUnsafeContent) onUploadError,
  }) {
    if (selectedFile == null) return;

    AmityCoreClient.newFileRepository()
        .uploadImage(selectedFile)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {},
        complete: (file) {
          onUploadSuccess(file);
        },
        error: (error) async {
          final Map<String, dynamic> errorData =
              error.data as Map<String, dynamic>;
          final int uploadErrorCode = errorData["detail"]["error"]["code"];
          if (uploadErrorCode == 403) {
            onUploadError(true);
            return;
          } else {
            onUploadError(false);
          }
          debugPrint("User image upload error $error");
        },
        cancel: () {
          debugPrint("User update error: Avatar upload cancelled");
          onUploadError(false);
        },
      );
    });
  }
}
