part of 'amity_edit_group_member_permissions_page.dart';

class AmityGroupMemberPermissionsState {
  final bool isLoading;
  final MessagingPermission messagingPermission;
  final String? errorMessage;

  const AmityGroupMemberPermissionsState({
    this.isLoading = false,
    this.messagingPermission = MessagingPermission.everyone,
    this.errorMessage,
  });

  AmityGroupMemberPermissionsState copyWith({
    bool? isLoading,
    MessagingPermission? messagingPermission,
    String? errorMessage,
  }) {
    return AmityGroupMemberPermissionsState(
      isLoading: isLoading ?? this.isLoading,
      messagingPermission: messagingPermission ?? this.messagingPermission,
      errorMessage: errorMessage,
    );
  }
}