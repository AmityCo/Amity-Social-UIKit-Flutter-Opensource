part of 'amity_create_group_cubit.dart';

enum CreateGroupStatus { initial, loading, success, failure, uploadImageFailed }


class AmityCreateGroupState extends Equatable {
  final CreateGroupStatus status;
  final String groupName;
  final bool isPublic;
  final File? groupImage;
  final String? error;
  final String? errorTitle;
  final AmityChannel? createdChannel;

  const AmityCreateGroupState({
    this.status = CreateGroupStatus.initial,
    this.groupName = '',
    this.isPublic = true,
    this.groupImage,
    this.error,
    this.errorTitle,
    this.createdChannel,
  });

  bool get isValid =>
      groupName.trim().isNotEmpty ||
      groupName.isEmpty; // Allow empty group names

  AmityCreateGroupState copyWith({
    CreateGroupStatus? status,
    String? groupName,
    bool? isPublic,
    File? groupImage,
    String? error,
    String? errorTitle,
    AmityChannel? createdChannel,
  }) {
    return AmityCreateGroupState(
      status: status ?? this.status,
      groupName: groupName ?? this.groupName,
      isPublic: isPublic ?? this.isPublic,
      groupImage: groupImage ?? this.groupImage,
      error: error,
      errorTitle: errorTitle,
      createdChannel: createdChannel ?? this.createdChannel,
    );
  }

  @override
  List<Object?> get props => [
        status,
        groupName,
        isPublic,
        groupImage,
        error,
        errorTitle,
        createdChannel,
      ];
}
