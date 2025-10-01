import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';

part 'amity_select_group_member_state.dart';

class AmitySelectGroupMemberCubit extends Cubit<AmitySelectGroupMemberState> {
  
  AmitySelectGroupMemberCubit() : super(const AmitySelectGroupMemberState());

  late UserLiveCollection userLiveCollection;
  StreamSubscription<List<AmityUser>>? _subscription;
  StreamSubscription<bool>? _loadingSubscription;
  String searchText = '';

  void initializeSelectedUsers(List<AmityUser> users) {
    if (users.isNotEmpty) {
      emit(state.copyWith(selectedUsers: users));
    }
  }

  void initializeWithExistingMembers(List<dynamic> existingMembers) {
    final selectedUsers = <AmityUser>[];
    
    for (var member in existingMembers) {
      if (member is AmityUser) {
        selectedUsers.add(member);
      }
    }
    
    if (selectedUsers.isNotEmpty) {
      emit(state.copyWith(selectedUsers: selectedUsers));
    }
  }

  void queryUser(String searchText, {bool isFirstLoad = false}) {
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
      if (!isClosed) {
        emit(state.copyWith(
          isFetching: event,
        ));
      }
    });

    _subscription =
        userLiveCollection.getStreamController().stream.listen((users) async {
      if (!isClosed) {
        emit(state.copyWith(
          users: users,
          hasMoreItems: userLiveCollection.hasNextPage()
        ));
      }
    });

    userLiveCollection.loadNext();
  }

  void loadmoreUsers() {
    if (userLiveCollection.hasNextPage() == true) {
      userLiveCollection.loadNext();
    }
  }

  void updateSelectedUsers(AmityUser user) {
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
    _subscription?.cancel();
    _loadingSubscription?.cancel();
    return super.close();
  }
}
