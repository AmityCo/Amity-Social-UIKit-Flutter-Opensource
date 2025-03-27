part of 'chat_list_bloc.dart';

class ChatListState extends Equatable {
  final List<AmityChannel> channels;
  final Map<String, AmityChannelMember?> channelMembers;
  final bool isLoading;
  final bool isPushNotificationEnabled;
  final AmityErrorInfo? error;
  final bool showArchiveErrorDialog;

  const ChatListState({
    this.channels = const [],
    this.channelMembers = const {},
    this.isLoading = true,
    this.isPushNotificationEnabled = true,
    this.error,
    this.showArchiveErrorDialog = false,
  });

  ChatListState copyWith({
    List<AmityChannel>? channels,
    Map<String, AmityChannelMember?>? channelMembers,
    bool? isLoading,
    bool? isPushNotificationEnabled,
    AmityErrorInfo? error,
    bool? showArchiveErrorDialog,
  }) {
    return ChatListState(
      channels: channels ?? this.channels,
      channelMembers: channelMembers ?? this.channelMembers,
      isLoading: isLoading ?? this.isLoading,
      isPushNotificationEnabled:
          isPushNotificationEnabled ?? this.isPushNotificationEnabled,
      error: error ?? this.error,
      showArchiveErrorDialog:
          showArchiveErrorDialog ?? this.showArchiveErrorDialog,
    );
  }

  @override
  List<Object?> get props => [
        channels,
        channelMembers,
        isLoading,
        isPushNotificationEnabled,
        error,
        showArchiveErrorDialog,
      ];
}