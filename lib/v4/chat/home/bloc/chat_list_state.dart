part of 'chat_list_bloc.dart';

class ChatListState extends Equatable {

  final List<AmityChannel> channels;
  final bool isLoading;
  final Map<String, AmityChannelMember?> channelMembers; // ChannelId: ChannelMember
  final bool isPushNotificationEnabled;

  const ChatListState({
    this.channels = const [],
    this.isLoading = false,
    this.channelMembers = const {},
    this.isPushNotificationEnabled = true,
  });

  @override
  List<Object?> get props => [channels, isLoading, channelMembers];

  ChatListState copyWith({
    List<AmityChannel>? channels,
    bool? isLoading,
    Map<String, AmityChannelMember?>? channelMembers,
    bool? isPushNotificationEnabled,
  }) {
    return ChatListState(
      channels: channels ?? this.channels,
      isLoading: isLoading ?? this.isLoading,
      channelMembers: channelMembers ?? this.channelMembers,
      isPushNotificationEnabled: isPushNotificationEnabled ?? this.isPushNotificationEnabled,
    );
  }
}