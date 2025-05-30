part of 'group_chat_page_bloc.dart';

const _undefined = Object();

class GroupChatPageState extends Equatable {
  final String channelId;
  final String? avatarUrl;
  final bool isConnected;
  final String? channelDisplayName;
  final bool isMute;
  final List<ChatItem> messages;
  final bool isFetching;
  final bool hasNextPage;
  final Map<String, Uint8List?> localThumbnails;
  final bool isOnMuteChange;
  final AmityChannel? channel;
  final ReplyingMesage? replyingMessage;
  final AmityMessage? editingMessage;
  final bool showScrollButton;
  final AmityMessage? newMessage;
  final ScrollController scrollController;
  final bool isModerator;
  final Map<String, List<String>> memberRoles;

  const GroupChatPageState({
    required this.channelId,
    required this.messages,
    this.avatarUrl,
    this.channelDisplayName,
    this.isMute = false,
    this.isConnected = true,
    this.isFetching = false,
    this.hasNextPage = true,
    this.localThumbnails = const {},
    this.isOnMuteChange = false,
    this.channel,
    this.replyingMessage,
    this.editingMessage,
    this.showScrollButton = false,
    this.newMessage,
    required this.scrollController,
    this.isModerator = false,
    this.memberRoles = const {},
  });

  @override
  List<Object?> get props => [
        channelId,
        messages,
        avatarUrl,
        isMute,
        isConnected,
        channelDisplayName,
        isFetching,
        hasNextPage,
        localThumbnails,
        isOnMuteChange,
        channel,
        replyingMessage,
        editingMessage,
        showScrollButton,
        newMessage,
        isModerator,
        memberRoles,
      ];

  GroupChatPageState copyWith({
    String? channelId,
    String? avatarUrl,
    String? channelDisplayName,
    bool? isMute,
    bool isConnected = true,
    List<ChatItem>? messages,
    bool? isFetching,
    bool? hasNextPage,
    Map<String, Uint8List?>? localThumbnails,
    bool? isOnMuteChange,
    AmityChannel? channel,
    Object? replyingMessage = _undefined,
    Object? editingMessage = _undefined,
    bool? showScrollButton,
    Object? newMessage = _undefined,
    ScrollController? scrollController,
    bool? isModerator,
    Map<String, List<String>>? memberRoles,
  }) {
    return GroupChatPageState(
      channelId: channelId ?? this.channelId,
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMute: isMute ?? this.isMute,
      isConnected: isConnected,
      channelDisplayName: channelDisplayName ?? this.channelDisplayName,
      isFetching: isFetching ?? this.isFetching,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      localThumbnails: localThumbnails ?? this.localThumbnails,
      isOnMuteChange: isOnMuteChange ?? this.isOnMuteChange,
      channel: channel ?? this.channel,
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
      isModerator: isModerator ?? this.isModerator,
      memberRoles: memberRoles ?? this.memberRoles,
    );
  }
}

class GroupChatPageStateInitial extends GroupChatPageState {
  const GroupChatPageStateInitial({
    required String channelId,
    required ScrollController scrollController,
  }) : super(
          channelId: channelId,
          messages: const [],
          isFetching: false,
          hasNextPage: true,
          isOnMuteChange: false,
          scrollController: scrollController,
        );
}

class GroupChatPageStateChanged extends GroupChatPageState {
  const GroupChatPageStateChanged({
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
