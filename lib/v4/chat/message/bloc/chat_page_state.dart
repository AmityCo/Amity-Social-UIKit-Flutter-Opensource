part of 'chat_page_bloc.dart';

const _undefined = Object();

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
  final ReplyingMesage? replyingMessage;
  final AmityMessage? editingMessage;
  final bool showScrollButton;
  final AmityMessage? newMessage;
  final ScrollController scrollController;

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
    this.channelMember,
    this.replyingMessage,
    this.editingMessage,
    this.showScrollButton = false,
    this.newMessage,
    required this.scrollController,
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
        channelMember,
        replyingMessage,
        editingMessage,
        showScrollButton,
        newMessage,
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
    AmityChannelMember? channelMember,
    Object? replyingMessage = _undefined,
    Object? editingMessage = _undefined,
    bool? showScrollButton,
    Object? newMessage = _undefined,
    ScrollController? scrollController,
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
      channelMember: channelMember ?? this.channelMember,
      replyingMessage: replyingMessage == _undefined
          ? this.replyingMessage
          : replyingMessage as ReplyingMesage?,
      editingMessage: editingMessage == _undefined
          ? this.editingMessage
          : editingMessage as AmityMessage?,
      showScrollButton: showScrollButton ?? this.showScrollButton,
      newMessage: newMessage == _undefined
          ? this.newMessage
          : newMessage as AmityMessage?,
      scrollController: scrollController ?? this.scrollController,
    );
  }
}

class ChatPageStateInitial extends ChatPageState {
  const ChatPageStateInitial({
    required String channelId,
    required String? userDisplayName,
    required String? avatarUrl,
    required ScrollController scrollController,
  }) : super(
          channelId: channelId,
          userDisplayName: userDisplayName,
          avatarUrl: avatarUrl,
          messages: const [],
          isFetching: false,
          hasNextPage: true,
          isOnMuteChange: false,
          scrollController: scrollController,
        );
}

class ChatPageStateChanged extends ChatPageState {
  const ChatPageStateChanged({
    required String channelId,
    required List<ChatItem> messages,
    required bool isFetching,
    required bool hasNextPage,
    required ScrollController scrollController,
  }) : super(
          channelId: channelId,
          messages: messages,
          isFetching: isFetching,
          hasNextPage: hasNextPage,
          scrollController: scrollController,
        );
}
