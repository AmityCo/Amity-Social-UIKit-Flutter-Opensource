import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';

part 'amity_add_group_member_state.dart';

class AmityAddGroupMemberCubit extends Cubit<AmityAddGroupMemberState> {
  
  AmityAddGroupMemberCubit() : super(const AmityAddGroupMemberState());

  late UserLiveCollection userLiveCollection;
  StreamSubscription<List<AmityUser>>? _subscription;
  StreamSubscription<bool>? _loadingSubscription;
  String searchText = '';
  bool _isClosed = false;

  void queryUser(String searchText, {bool isFirstLoad = false}) {
    if (_isClosed) return;
    
    // Cancel previous subscriptions if they exist
    _subscription?.cancel();
    _loadingSubscription?.cancel();
    
    emit(state.copyWith(
      isFetching: true,
      users: [],
      hasMoreItems: false,
    ));

    userLiveCollection = AmityCoreClient.newUserRepository()
        .searchUserByDisplayName(searchText)
        .matchType(AmityUserSearchMatchType.PARTIAL)
        .sortBy(AmityUserSortOption.DISPLAY)
        .getLiveCollection();

    _loadingSubscription = userLiveCollection.observeLoadingState().listen((event) {
      if (!_isClosed) {
        emit(state.copyWith(
          isFetching: event,
        ));
      }
    });

    _subscription =
        userLiveCollection.getStreamController().stream.listen((users) async {
      if (!_isClosed) {
        emit(state.copyWith(
          users: users,
          hasMoreItems: userLiveCollection.hasNextPage()
        ));
      }
    });

    userLiveCollection.loadNext();
  }

  void loadmoreUsers() {
    if (_isClosed) return;
    
    if (userLiveCollection.hasNextPage() == true) {
      userLiveCollection.loadNext();
    }
  }

  void updateSelectedUsers(AmityUser user) {
    if (_isClosed) return;
    
    final selectedUsers = List<AmityUser>.from(state.selectedUsers);
    final userIndex = selectedUsers.indexWhere((selectedUser) => 
        selectedUser.userId == user.userId);
    
    if (userIndex >= 0) {
      selectedUsers.removeAt(userIndex);
    } else {
      selectedUsers.add(user);
    }
    emit(state.copyWith(selectedUsers: selectedUsers));
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    _subscription?.cancel();
    _loadingSubscription?.cancel();
    return super.close();
  }
}