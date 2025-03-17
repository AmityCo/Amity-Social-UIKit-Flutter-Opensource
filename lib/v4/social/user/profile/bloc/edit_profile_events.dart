part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileFetchEvent extends EditProfileEvent {
  final AmityUser user;

  const UserProfileFetchEvent({required this.user});

  @override
  List<Object> get props => [user];
}

class EditProfileImagePickerEvent extends EditProfileEvent {
  final Function onError;

  const EditProfileImagePickerEvent({required this.onError});

  @override
  List<Object> get props => [];
}

class EditProfileAboutChangedEvent extends EditProfileEvent {
  final String value;

  const EditProfileAboutChangedEvent({required this.value});

  @override
  List<Object> get props => [value];
}

class EditProfileSaveEvent extends EditProfileEvent {
  final Function({required bool isSuccess, required bool isUnsafeUploadError})
      onCompletion; // Nudity, Violence, etc.

  const EditProfileSaveEvent({required this.onCompletion});

  @override
  List<Object> get props => [];
}
