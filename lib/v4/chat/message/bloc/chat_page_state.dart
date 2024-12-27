part of 'chat_page_bloc.dart';

class ChatPageState extends Equatable {
  final String channelId;
  final String? avatarUrl;
  final bool isConnected;
  final String? userDisplayName;
  final bool isMute;
  final List<ChatItem> messages;
  final bool isFetching;
  final bool hasNextPage;
  final Map<String, Uint8List?> localThumbnails;
  final bool isOnMuteChange;
  final AmityChannelMember? channelMember;

  const ChatPageState({
    required this.channelId,
    required this.messages,
    this.avatarUrl,
    this.userDisplayName,
    this.isMute = false,
    this.isConnected = true,
    this.isFetching = false,
    this.hasNextPage = true,
    this.localThumbnails = const {},
    this.isOnMuteChange = false,
    this.channelMember
  });

  @override
  List<Object?> get props => [
        channelId,
        messages,
        avatarUrl,
        isMute,
        isConnected,
        userDisplayName,
        isFetching,
        hasNextPage,
        localThumbnails,
        isOnMuteChange,
        channelMember
      ];

  ChatPageState copyWith({
    String? channelId,
    String? avatarUrl,
    String? userDisplayName,
    bool? isMute,
    bool isConnected = true,
    List<ChatItem>? messages,
    bool? isFetching,
    bool? hasNextPage,
    Map<String, Uint8List?>? localThumbnails,
    bool? isOnMuteChange,
    AmityChannelMember? channelMember
  }) {
    return ChatPageState(
      channelId: channelId ?? this.channelId,
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMute: isMute ?? this.isMute,
      isConnected: isConnected,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      isFetching: isFetching ?? this.isFetching,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      localThumbnails: localThumbnails ?? this.localThumbnails,
      isOnMuteChange: isOnMuteChange ?? this.isOnMuteChange,
      channelMember: channelMember ?? this.channelMember
    );
  }
}

class ChatPageStateInitial extends ChatPageState {
  const ChatPageStateInitial({
    required String channelId,
    required String? userDisplayName,
    required String? avatarUrl,
  }) : super(
          channelId: channelId,
          userDisplayName: userDisplayName,
          avatarUrl: avatarUrl,
          messages: const [],
          isFetching: false,
          hasNextPage: true,
          isOnMuteChange: false,
        );
}

class ChatPageStateChanged extends ChatPageState {
  const ChatPageStateChanged({
    required String channelId,
    required List<ChatItem> messages,
    required bool isFetching,
    required bool hasNextPage,
  }) : super(
          channelId: channelId,
          messages: messages,
          isFetching: isFetching,
          hasNextPage: hasNextPage,
        );
}
