part of 'amity_edit_group_profile_page.dart';

abstract class AmityEditGroupProfileState {}

class AmityEditGroupProfileLoading extends AmityEditGroupProfileState {}

class AmityEditGroupProfileLoaded extends AmityEditGroupProfileState {
  final String? imagePath;
  final String? selectedImagePath;
  final int charCount;
  final bool hasChanged;
  final MediaPermissionHandler mediaHandler;

  AmityEditGroupProfileLoaded({
    this.imagePath,
    this.selectedImagePath,
    this.charCount = 0,
    this.hasChanged = false,
    MediaPermissionHandler? mediaHandler,
  }) : mediaHandler = mediaHandler ?? MediaPermissionHandler();

  AmityEditGroupProfileLoaded copyWith({
    String? imagePath,
    String? selectedImagePath,
    int? charCount,
    bool? hasChanged,
    MediaPermissionHandler? mediaHandler,
  }) {
    return AmityEditGroupProfileLoaded(
      imagePath: imagePath ?? this.imagePath,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      charCount: charCount ?? this.charCount,
      hasChanged: hasChanged ?? this.hasChanged,
      mediaHandler: mediaHandler ?? this.mediaHandler,
    );
  }
}