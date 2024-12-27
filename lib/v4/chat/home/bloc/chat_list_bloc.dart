import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';

part 'chat_list_events.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  AmityChannelType channelType;

  late final ChannelLiveCollection channelLiveCollection;

  ChatListBloc({required this.channelType}) : super(ChatListState()) {
    channelLiveCollection = AmityChatClient.newChannelRepository()
        .getChannels()
        .conversationType()
        .getLiveCollection();

    on<ChatListEventChannelsUpdated>((event, emit) {
      final channelIds = event.channels
          .where(
              (channel) => !state.channelMembers.containsKey(channel.channelId))
          .map((e) => e.channelId ?? "")
          .where((e) => e.isNotEmpty)
          .toList();

      addEvent(ChatListEventFetchMembers(channelIds: channelIds));

      emit(state.copyWith(
        channels: event.channels,
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

    channelLiveCollection.observeLoadingState().listen((isLoading) {
      addEvent(ChatListEventLoadingStateUpdated(isLoading: isLoading));
    });

    channelLiveCollection.getStreamController().stream.listen((channels) {
      addEvent(ChatListEventChannelsUpdated(channels: channels));
    });

    channelLiveCollection.loadNext();

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
