part of 'amity_group_chat_page_bloc.dart';

const _undefined = Object();

class GroupChatPageState extends Equatable {
  final String channelId;
  final String? avatarUrl;
  final bool isConnected;
  final String? channelDisplayName;
  final bool isMute;
  final List<ChatItem> messages;
  final bool isFetching;
  final bool isLoadingMore;
  final bool hasNextPage;
  final bool hasPrevious;
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
  final Map<String, bool> mutedUsers;
  final String? aroundMessageId;
  final bool useReverseUI;
  final int? bounceTargetIndex;
  final bool isLoadingToastDismissed;
  final bool shouldBounceMessage;
  final int? bounceMessageIndex;
  final bool? shouldUseReverse;

  const GroupChatPageState({
    required this.channelId,
    required this.messages,
    this.avatarUrl,
    this.channelDisplayName,
    this.isMute = false,
    this.isConnected = true,
    this.isFetching = false,
    this.isLoadingMore = false,
    this.hasNextPage = true,
    this.hasPrevious = false,
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
    this.mutedUsers = const {},
    this.aroundMessageId,
    this.useReverseUI = true,
    this.bounceTargetIndex,
    this.isLoadingToastDismissed = false,
    this.shouldBounceMessage = false,
    this.bounceMessageIndex,
    this.shouldUseReverse,
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
        isLoadingMore,
        hasNextPage,
        hasPrevious,
        localThumbnails,
        isOnMuteChange,
        channel,
        replyingMessage,
        editingMessage,
        showScrollButton,
        newMessage,
        isModerator,
        memberRoles,
        mutedUsers,
        aroundMessageId,
        useReverseUI,
        bounceTargetIndex,
        isLoadingToastDismissed,
        shouldBounceMessage,
        bounceMessageIndex,
        shouldUseReverse,
      ];

  GroupChatPageState copyWith({
    String? channelId,
    String? avatarUrl,
    String? channelDisplayName,
    bool? isMute,
    bool isConnected = true,
    List<ChatItem>? messages,
    bool? isFetching,
    bool? isLoadingMore,
    bool? hasNextPage,
    bool? hasPrevious,
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
    Map<String, bool>? mutedUsers,
    Object? aroundMessageId = _undefined,
    bool? useReverseUI,
    Object? bounceTargetIndex = _undefined,
    bool? isLoadingToastDismissed,
    bool? shouldBounceMessage,
    Object? bounceMessageIndex = _undefined,
    Object? shouldUseReverse = _undefined,
  }) {
    return GroupChatPageState(
      channelId: channelId ?? this.channelId,
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isMute: isMute ?? this.isMute,
      isConnected: isConnected,
      channelDisplayName: channelDisplayName ?? this.channelDisplayName,
      isFetching: isFetching ?? this.isFetching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPrevious: hasPrevious ?? this.hasPrevious,
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
      mutedUsers: mutedUsers ?? this.mutedUsers,
      aroundMessageId: aroundMessageId == _undefined
          ? this.aroundMessageId
          : aroundMessageId as String?,
      useReverseUI: useReverseUI ?? this.useReverseUI,
      bounceTargetIndex: bounceTargetIndex == _undefined
          ? this.bounceTargetIndex
          : bounceTargetIndex as int?,
      isLoadingToastDismissed:
          isLoadingToastDismissed ?? this.isLoadingToastDismissed,
      shouldBounceMessage: shouldBounceMessage ?? this.shouldBounceMessage,
      bounceMessageIndex: bounceMessageIndex == _undefined
          ? this.bounceMessageIndex
          : bounceMessageIndex as int?,
      shouldUseReverse: shouldUseReverse == _undefined
          ? this.shouldUseReverse
          : shouldUseReverse as bool?,
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
          isLoadingMore: false,
          hasNextPage: true,
          hasPrevious: false,
          isOnMuteChange: false,
          scrollController: scrollController,
        );
}

class GroupChatPageStateChanged extends GroupChatPageState {
  const GroupChatPageStateChanged({
    required String channelId,
    required List<ChatItem> messages,
    required bool isFetching,
    bool isLoadingMore = false,
    required bool hasNextPage,
    required bool hasPrevious,
    required ScrollController scrollController,
  }) : super(
          channelId: channelId,
          messages: messages,
          isFetching: isFetching,
          isLoadingMore: isLoadingMore,
          hasNextPage: hasNextPage,
          hasPrevious: hasPrevious,
          scrollController: scrollController,
        );
}
