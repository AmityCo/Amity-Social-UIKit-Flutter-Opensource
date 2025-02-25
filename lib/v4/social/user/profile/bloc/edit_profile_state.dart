part of 'edit_profile_bloc.dart';

class EditProfileState extends Equatable {
  EditProfileState({
    required this.userId,
    this.displayName,
    this.about,
    this.user,
    this.isProfileInfoUpdated = false,
    this.selectedImage,
  });

  final String userId;
  final String? displayName;
  final String? about;
  final AmityUser? user;
  final File? selectedImage;
  bool isProfileInfoUpdated;

  @override
  List<Object?> get props =>
      [userId, displayName, about, user, isProfileInfoUpdated];

  EditProfileState copyWith({
    String? userId,
    String? displayName,
    String? about,
    AmityUser? user,
    File? selectedImage,
    bool? isProfileInfoUpdated,
  }) {
    return EditProfileState(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      about: about ?? this.about,
      user: user ?? this.user,
      selectedImage: selectedImage ?? this.selectedImage,
      isProfileInfoUpdated: isProfileInfoUpdated ?? this.isProfileInfoUpdated,
    );
  }
}
