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
  final bool isLoadingMore;
  final bool hasNextPage;
  final bool hasPrevious;
  final Map<String, Uint8List?> localThumbnails;
  final bool isOnMuteChange;
  final bool isOnFlagChange;
  final AmityChannelMember? channelMember;
  final AmityUser? user; // Dedicated user property
  final ReplyingMesage? replyingMessage;
  final AmityMessage? editingMessage;
  final bool showScrollButton;
  final AmityMessage? newMessage;
  final ScrollController scrollController;
  final bool isUserBlocked;
  final String? aroundMessageId; // For jump to message functionality
  final int? bounceTargetIndex; // For bounce animation targeting
  final bool useReverseUI; // Controls scroll direction and message ordering

  const ChatPageState({
    required this.channelId,
    required this.messages,
    this.avatarUrl,
    this.userDisplayName,
    this.isMute = false,
    this.isConnected = true,
    this.isFetching = false,
    this.isLoadingMore = false,
    this.hasNextPage = true,
    this.hasPrevious = false,
    this.localThumbnails = const {},
    this.isOnMuteChange = false,
    this.isOnFlagChange = false,
    this.channelMember,
    this.user,
    this.replyingMessage,
    this.editingMessage,
    this.showScrollButton = false,
    this.newMessage,
    required this.scrollController,
    this.isUserBlocked = false,
    this.aroundMessageId,
    this.bounceTargetIndex,
    this.useReverseUI = true,
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
        isLoadingMore,
        hasNextPage,
        hasPrevious,
        localThumbnails,
        isOnMuteChange,
        isOnFlagChange,
        channelMember,
        user,
        replyingMessage,
        editingMessage,
        showScrollButton,
        newMessage,
        isUserBlocked,
        aroundMessageId,
        bounceTargetIndex,
        useReverseUI,
      ];

  ChatPageState copyWith({
    String? channelId,
    String? avatarUrl,
    String? userDisplayName,
    bool? isMute,
    bool isConnected = true,
    List<ChatItem>? messages,
    bool? isFetching,
    bool? isLoadingMore,
    bool? hasNextPage,
    bool? hasPrevious,
    Map<String, Uint8List?>? localThumbnails,
    bool? isOnMuteChange,
    bool? isOnFlagChange,
    AmityChannelMember? channelMember,
    Object? replyingMessage = _undefined,
    Object? editingMessage = _undefined,
    bool? showScrollButton,
    Object? newMessage = _undefined,
    ScrollController? scrollController,
    AmityUser? user,
    bool? isUserBlocked,
    Object? aroundMessageId = _undefined,
    Object? bounceTargetIndex = _undefined,
    bool? useReverseUI,
  }) {
    return ChatPageState(
      channelId: channelId ?? this.channelId,
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMute: isMute ?? this.isMute,
      isConnected: isConnected,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      isFetching: isFetching ?? this.isFetching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      isOnFlagChange: isOnFlagChange ?? this.isOnFlagChange,
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
      user: user ?? this.user,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      aroundMessageId: aroundMessageId == _undefined
          ? this.aroundMessageId
          : aroundMessageId as String?,
      bounceTargetIndex: bounceTargetIndex == _undefined
          ? this.bounceTargetIndex
          : bounceTargetIndex as int?,
      useReverseUI: useReverseUI ?? this.useReverseUI,
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
          isLoadingMore: false,
          hasNextPage: true,
          hasPrevious: false,
          isOnMuteChange: false,
          scrollController: scrollController,
          user: null,
          isUserBlocked: false,
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
          isLoadingMore: false,
          hasNextPage: hasNextPage,
          hasPrevious: false,
          scrollController: scrollController,
          user: null,
          isUserBlocked: false,
        );
}
