import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'channel_create_conversation_events.dart';
part 'channel_create_conversation_state.dart';

class ChannelCreateConversationBloc
    extends Bloc<ChannelCreateConversationEvent, ChannelCreateConversationState> {
  late UserLiveCollection userLiveCollection;
  late StreamSubscription<List<AmityUser>> _subscription;

  ChannelCreateConversationBloc() : super(const ChannelCreateConversationState()) {

    void queryUser(String searchText, {bool isFirstLoad = false}) {
      if(!isFirstLoad) {
        _subscription.cancel();
      }

      userLiveCollection = AmityCoreClient.newUserRepository()
          .searchUserByDisplayName(searchText)
          .getLiveCollection();

      emit(ChannelCreateConversationLoading());
      _subscription = userLiveCollection
          .getStreamController()
          .stream
          .listen((users) async {
        if (userLiveCollection.isFetching == true && users.isEmpty) {
          emit(ChannelCreateConversationLoading());
        } else if (users.isNotEmpty) {
          add(UsersLoadedEvent(
            users: users,
            hasMoreItems: userLiveCollection.hasNextPage(),
            isFetching: userLiveCollection.isFetching,
          ));
        }
      });

      userLiveCollection.loadNext();
    }

    queryUser("", isFirstLoad: true);

    on<SearchUsersEvent>((event, emit) async {
      emit(UserSearchTextChange(event.searchText));
      queryUser(event.searchText);

    });

    on<UsersLoadedEvent>((event, emit) async {
      emit(ChannelCreateConversationLoaded(
        list: event.users,
        hasMoreItems: event.hasMoreItems,
        isFetching: event.isFetching,
      ));
    });

    on<ChannelCreateConversationEventInitial>((event, emit) async {

    });

    on<ChannelCreateConversationEventLoadMore>((event, emit) async {
      if (userLiveCollection.hasNextPage()) {
        userLiveCollection.loadNext();
      }
    });

  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
