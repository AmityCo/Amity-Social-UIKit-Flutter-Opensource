part of 'group_profile_page.dart';

abstract class GroupProfileState {}

class GroupProfileLoading extends GroupProfileState {}

class GroupProfileLoaded extends GroupProfileState {
  final String? imagePath;
  final String? selectedImagePath;
  final int charCount;
  final bool hasChanged;
  final MediaPermissionHandler mediaHandler;

  GroupProfileLoaded({
    this.imagePath,
    this.selectedImagePath,
    this.charCount = 0,
    this.hasChanged = false,
    MediaPermissionHandler? mediaHandler,
  }) : mediaHandler = mediaHandler ?? MediaPermissionHandler();

  GroupProfileLoaded copyWith({
    String? imagePath,
    String? selectedImagePath,
    int? charCount,
    bool? hasChanged,
    MediaPermissionHandler? mediaHandler,
  }) {
    return GroupProfileLoaded(
      imagePath: imagePath ?? this.imagePath,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      charCount: charCount ?? this.charCount,
      hasChanged: hasChanged ?? this.hasChanged,
      mediaHandler: mediaHandler ?? this.mediaHandler,
    );
  }
}