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
  });

  final String userId;
  final AmityUser? user;
  final AmityMyFollowInfo? myFollowInfo;
  final AmityUserFollowInfo? userFollowInfo;
  final UserProfileTabIndex selectedIndex;
  final bool isOwnUserProfile;
  final bool isHeaderExpanded;

  @override
  List<Object?> get props => [
        userId,
        user,
        myFollowInfo,
        userFollowInfo,
        selectedIndex,
        isOwnUserProfile,
        isHeaderExpanded,
      ];

  UserProfileState copyWith({
    String? userId,
    AmityUser? user,
    AmityMyFollowInfo? myFollowInfo,
    AmityUserFollowInfo? userFollowInfo,
    UserProfileTabIndex? selectedIndex,
    bool? isHeaderExpanded,
  }) {
    return UserProfileState(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      myFollowInfo: myFollowInfo ?? this.myFollowInfo,
      userFollowInfo: userFollowInfo ?? this.userFollowInfo,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isOwnUserProfile: AmityCoreClient.getUserId() == userId,
      isHeaderExpanded: isHeaderExpanded ?? this.isHeaderExpanded,
    );
  }
}
