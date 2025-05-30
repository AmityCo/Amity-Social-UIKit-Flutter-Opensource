import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_list_events.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListType chatListType;
  ChannelFilterType channelFilterType;
  AmityToastBloc toastBloc;

  late final LiveCollectionStream<AmityChannel> channelLiveCollection;

  ChatListBloc({required this.chatListType, required this.channelFilterType, required this.toastBloc})
      : super(const ChatListState()) {
    if (chatListType == ChatListType.ARCHIVED) {
      channelLiveCollection =
          AmityChatClient.newChannelRepository().getArchivedChannels();
    } else {
      // Filter channels based on channelFilterType
      List<AmityChannelType> channelTypes;
      switch (channelFilterType) {
        case ChannelFilterType.conversation:
          channelTypes = [AmityChannelType.CONVERSATION];
          break;
        case ChannelFilterType.community:
          channelTypes = [AmityChannelType.COMMUNITY];
          break;
        case ChannelFilterType.all:
        default:
          channelTypes = [AmityChannelType.COMMUNITY, AmityChannelType.CONVERSATION];
          break;
      }
      
      channelLiveCollection = AmityChatClient.newChannelRepository()
          .getChannels()
          .types(channelTypes)
          .filter(AmityChannelFilter.MEMBER)
          .excludeArchives(true)
          .getLiveCollection();
    }

    on<ChatListEventChannelsUpdated>((event, emit) {
      final channelIds = event.channels
          .where(
              (channel) => !state.channelMembers.containsKey(channel.channelId))
          .map((e) => e.channelId ?? "")
          .where((e) => e.isNotEmpty)
          .toList();

      addEvent(ChatListEventFetchMembers(channelIds: channelIds));

      // Calculate if there are any unread messages
      final hasUnreadMessages = event.channels
          .any((channel) => (channel.unreadCount ?? 0) > 0);

      emit(state.copyWith(
        channels: event.channels,
        hasUnreadMessages: hasUnreadMessages,
      ));
    });

    on<ChatListEventFetchMembers>((event, emit) async {
      var membersMap =
          Map<String, AmityChannelMember?>.from(state.channelMembers);
      for (final channelId in event.channelIds) {
        final List<AmityChannelMember?> members =
            await AmityChatClient.newChannelRepository()
                .membership(channelId)
                .getMembersFromCache();

        // Get other participant for this channel.
        AmityChannelMember? member;
        for (var i = 0; i < members.length; i++) {
          if (members[i]?.userId != AmityCoreClient.getUserId()) {
            member = members[i];
            break;
          }
        }

        membersMap[channelId] = member;
      }

      emit(state.copyWith(
        channelMembers: membersMap,
      ));
    });

    on<ChatListEventLoadingStateUpdated>((event, emit) {
      emit(state.copyWith(
        isLoading: event.isLoading,
      ));
    });

    on<ChatListLoadNextPage>((event, emit) {
      if (channelLiveCollection.hasNextPage()) {
        channelLiveCollection.loadNext();
      }
    });

    on<ChatListPushNotificationEvent>((event, emit) {
      emit(state.copyWith(
        isPushNotificationEnabled: event.isPushNotificationEnabled,
      ));
    });

    on<ChatListEventChannelArchive>((event, emit) async {
      try {
        await AmityChatClient.newChannelRepository()
            .archiveChannel(event.channelId);
        toastBloc.add(const AmityToastShort(
            message: 'Chat archived.', icon: AmityToastIcon.success));
      } catch (error) {
        String errorMessage = error.toString();
        if (errorMessage.contains('Archive limit exceeded')) {
          emit(state.copyWith(
            error: const AmityErrorInfo(
              title: 'Too many chats archived',
              message: 'You can archive a maximum of 100 chat lists.',
            ),
            showArchiveErrorDialog: true,
          ));
        } else {
          emit(state.copyWith(
            error: AmityErrorInfo(
              title: 'Archive Error',
              message: errorMessage,
            ),
            showArchiveErrorDialog: true,
          ));
        }
      }
    });

    on<ChatListEventChannelUnarchive>((event, emit) async {
      await AmityChatClient.newChannelRepository()
          .unarchiveChannel(event.channelId);
      toastBloc.add(const AmityToastShort(
          message: 'Chat unarchived.', icon: AmityToastIcon.success));
    });

    on<ChatListEventResetDialogState>((event, emit) {
      emit(state.copyWith(
        showArchiveErrorDialog: false,
        error: null,
      ));
    });

    channelLiveCollection.getStream().listen((event) {
      addEvent(ChatListEventLoadingStateUpdated(isLoading: event.isFetching));
      addEvent(ChatListEventChannelsUpdated(channels: event.data));
    });

    // Query for notification settings
    fetchNotificationSettings();
  }

  @override
  Future<void> close() {
    channelLiveCollection.dispose();
    return super.close();
  }

  void fetchNotificationSettings() async {
    final settings = await AmityNotification().user().getSettings();
    final chatModuleSettings = settings.events?.whereType<Chat>().first;

    final isPushNotificationEnabled =
        (settings.isEnabled ?? true) && (chatModuleSettings?.isEnabled ?? true);
    addEvent(ChatListPushNotificationEvent(
        isPushNotificationEnabled: isPushNotificationEnabled));
  }
}
