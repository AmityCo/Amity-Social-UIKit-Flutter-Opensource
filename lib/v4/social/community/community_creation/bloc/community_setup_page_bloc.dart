import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/element/category_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

part 'community_setup_page_event.dart';
part 'community_setup_page_state.dart';

class CommunitySetupPageBloc
    extends Bloc<CommunitySetupPageEvent, CommunitySetupPageState> {
  File? pickedFile;

  CommunitySetupPageBloc({AmityCommunity? community})
      : super(community != null
            ? CommunitySetupPageState().copyWith(
                avatar: community.avatarImage,
                communityName: community.displayName,
                communityDescription: community.description,
                communityCategories: community.categories
                    ?.map((category) => CommunityCategory(category: category))
                    .toList(),
                communityPrivacy: community.isPublic ?? true
                    ? CommunityPrivacy.public
                    : CommunityPrivacy.private,
              )
            : CommunitySetupPageState()) {
    on<CommunitySetupPageImagePickerEvent>((event, emit) async {
      final XFile? xFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        pickedFile = File(xFile.path);
        emit(state.copyWith(
            pickedImage: pickedFile, hasExistingDataChanged: true));
      }
    });

    on<CommunitySetupPageCameraImageEvent>((event, emit) {
      pickedFile = File(event.image.path);
      emit(state.copyWith(
          pickedImage: pickedFile, hasExistingDataChanged: true));
    });

    on<CommunitySetupPageNameChangedEvent>((event, emit) {
      emit(state.copyWith(
          communityName: event.name,
          hasExistingDataChanged: event.name != community?.displayName));
    });

    on<CommunitySetupPageDescriptionChangedEvent>((event, emit) {
      emit(state.copyWith(
          communityDescription: event.description,
          hasExistingDataChanged: event.description != community?.description));
    });

    on<CommunitySetupPageCategoryChangedEvent>((event, emit) {
      final newCategoryIds =
          event.communityCategories.map((e) => e.category?.categoryId).toSet();
      final existingCategoryIds =
          community?.categories?.map((e) => e?.categoryId).toSet() ??
              <dynamic>{};
      final hasCategoriesChanged =
          !newCategoryIds.containsAll(existingCategoryIds) ||
              !existingCategoryIds.containsAll(newCategoryIds);
      emit(state.copyWith(
          communityCategories: event.communityCategories,
          hasExistingDataChanged: hasCategoriesChanged));
    });

    on<CommunitySetupPagePrivacyChangedEvent>((event, emit) {
      final hasDataChanged = event.privacy !=
          (community?.isPublic ?? true
              ? CommunityPrivacy.public
              : CommunityPrivacy.private);
      emit(state.copyWith(
          communityPrivacy: event.privacy,
          hasExistingDataChanged: hasDataChanged,
          isCommunityPrivacyUpdatedToPrivate:
              hasDataChanged && event.privacy == CommunityPrivacy.private));
    });

    on<CommunitySetupPageAddMemberEvent>((event, emit) {
      emit(state.copyWith(communityMembers: event.users));
    });

    on<CommunitySetupPageRemoveMemberEvent>((event, emit) {
      emit(state.copyWith(
          communityMembers: [...state.communityMembers]
            ..removeWhere((element) => element.userId == event.user.userId)));
    });

    on<CommunitySetupPageCreateCommunityEvent>((event, emit) {
      CommunityCreatorBuilder builder =
          AmitySocialClient.newCommunityRepository()
              .createCommunity(state.communityName)
              .description(state.communityDescription)
              .categoryIds(state.communityCategories
                  .map((category) => category.category?.categoryId ?? '')
                  .toList())
              .isPublic(state.communityPrivacy == CommunityPrivacy.public);

      if (state.communityMembers.isNotEmpty &&
          state.communityPrivacy == CommunityPrivacy.private) {
        builder.userIds(state.communityMembers
            .map((user) => user.userId)
            .whereType<String>()
            .toList());
      }

      if (pickedFile != null) {
        _uploadImage((image) {
          builder.avatar(image);
          builder.create().then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.context.l10n.community_create_success_message,
                icon: AmityToastIcon.success));
            event.onSuccess(value);
          }, onError: (error) {
            event.toastBloc.add(AmityToastShort(
                message: event.context.l10n.community_create_error_message));
          });
        });
      } else {
        builder.create().then((value) {
          event.toastBloc.add(AmityToastShort(
              message: event.context.l10n.community_create_success_message,
              icon: AmityToastIcon.success));
          event.onSuccess(value);
        }, onError: (error) {
          event.toastBloc.add(AmityToastShort(
              message: event.context.l10n.community_create_error_message));
        });
      }
    });

    on<CommunitySetupPageSaveCommunityEvent>((event, emit) {
      CommunityUpdaterBuilder builder =
          AmitySocialClient.newCommunityRepository()
              .updateCommunity(community?.communityId ?? '')
              .displayName(state.communityName)
              .description(state.communityDescription)
              .categoryIds(state.communityCategories
                  .map((category) => category.category?.categoryId ?? '')
                  .toList())
              .isPublic(state.communityPrivacy == CommunityPrivacy.public);

      if (pickedFile != null) {
        _uploadImage((image) {
          builder.avatar(image);
          builder.update().then((value) {
            event.toastBloc.add(AmityToastShort(
                message: event.context.l10n.community_update_success_message,
                icon: AmityToastIcon.success));
            event.onSuccess();
          }, onError: (error) {
            event.toastBloc.add(AmityToastShort(
                message: event.context.l10n.community_update_error_message));
          });
        });
      } else {
        builder.update().then((value) {
          event.toastBloc.add(AmityToastShort(
              message: event.context.l10n.community_update_success_message,
              icon: AmityToastIcon.success));
          event.onSuccess();
        }, onError: (error) {
          event.toastBloc.add(AmityToastShort(
              message: event.context.l10n.community_update_error_message));
        });
      }
    });
  }

  void _uploadImage(Function(AmityImage) onUploadComplete) {
    AmityCoreClient.newFileRepository()
        .uploadImage(pickedFile!)
        .stream
        .listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {},
        complete: (file) {
          onUploadComplete(file);
        },
        error: (error) async {},
        cancel: () {
          //upload is cancelled
        },
      );
    });
  }
}
