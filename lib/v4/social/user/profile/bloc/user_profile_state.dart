part of 'user_profile_bloc.dart';

enum UserProfileTabIndex { feed, image, video }

class UserProfileState extends Equatable {
  const UserProfileState({
    required this.userId,
    this.user,
    this.myFollowInfo,
    this.userFollowInfo,
    this.selectedIndex = UserProfileTabIndex.feed,
    this.isOwnUserProfile = true,
    this.isHeaderExpanded = false,
    this.showUserNameOnAppBar = false,
  });

  final String userId;
  final AmityUser? user;
  final AmityMyFollowInfo? myFollowInfo;
  final AmityUserFollowInfo? userFollowInfo;
  final UserProfileTabIndex selectedIndex;
  final bool isOwnUserProfile;
  final bool isHeaderExpanded;
  final bool showUserNameOnAppBar;

  @override
  List<Object?> get props => [
        userId,
        user,
        myFollowInfo,
        userFollowInfo,
        selectedIndex,
        isOwnUserProfile,
        isHeaderExpanded,
        showUserNameOnAppBar
      ];

  UserProfileState copyWith({
    String? userId,
    AmityUser? user,
    AmityMyFollowInfo? myFollowInfo,
    AmityUserFollowInfo? userFollowInfo,
    UserProfileTabIndex? selectedIndex,
    bool? isHeaderExpanded,
    bool? showUserNameOnAppBar,
  }) {
    return UserProfileState(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      myFollowInfo: myFollowInfo ?? this.myFollowInfo,
      userFollowInfo: userFollowInfo ?? this.userFollowInfo,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isOwnUserProfile: AmityCoreClient.getUserId() == userId,
      isHeaderExpanded: isHeaderExpanded ?? this.isHeaderExpanded,
      showUserNameOnAppBar: showUserNameOnAppBar ?? this.showUserNameOnAppBar,
    );
  }
}
