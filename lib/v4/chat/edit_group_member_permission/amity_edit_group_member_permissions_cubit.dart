part of 'amity_edit_group_member_permissions_page.dart';

class AmityEditGroupMemberPermissionsCubit extends Cubit<AmityGroupMemberPermissionsState> {
  final AmityChannel channel;
  
  AmityEditGroupMemberPermissionsCubit(this.channel) : super(const AmityGroupMemberPermissionsState()) {
    _loadInitialPermissions();
  }
  
  void _loadInitialPermissions() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Check if the channel is muted to determine the current permission settings
      final isMuted = channel.isMuted ?? false;
      
      final currentPermission = isMuted
          ? MessagingPermission.moderatorsOnly
          : MessagingPermission.everyone;
          
      emit(state.copyWith(
        isLoading: false,
        messagingPermission: currentPermission,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load permissions: $e',
      ));
    }
  }
  
  void setMessagingPermission(MessagingPermission permission) {
    emit(state.copyWith(messagingPermission: permission));
  }
  
  void savePermissions() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Update the channel with the new permissions
      final isModeratorOnly = state.messagingPermission == MessagingPermission.moderatorsOnly;
      
      // Here we would call the Amity SDK to update the channel settings
      // await AmityChatClient.newChannelRepository()
      //     .updateChannel(channel.channelId)
      //     .isMessageModeration(isModeratorOnly)
      //     .update()
      //     .then((_) {
      //       emit(state.copyWith(isLoading: false));
      //     });
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save permissions: $e',
      ));
    }
  }
}