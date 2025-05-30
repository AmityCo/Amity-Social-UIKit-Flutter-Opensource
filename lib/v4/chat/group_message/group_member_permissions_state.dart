part of 'group_member_permissions_page.dart';

class GroupMemberPermissionsState {
  final bool isLoading;
  final MessagingPermission messagingPermission;
  final String? errorMessage;

  const GroupMemberPermissionsState({
    this.isLoading = false,
    this.messagingPermission = MessagingPermission.everyone,
    this.errorMessage,
  });

  GroupMemberPermissionsState copyWith({
    bool? isLoading,
    MessagingPermission? messagingPermission,
    String? errorMessage,
  }) {
    return GroupMemberPermissionsState(
      isLoading: isLoading ?? this.isLoading,
      messagingPermission: messagingPermission ?? this.messagingPermission,
      errorMessage: errorMessage,
    );
  }
}