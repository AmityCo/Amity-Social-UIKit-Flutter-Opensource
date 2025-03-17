enum UserFeedEmptyStateType { empty, private, blocked }

class UserFeedEmptyStateInfo {
  final String title;
  final String description;
  final String icon;

  UserFeedEmptyStateInfo(this.title, this.description, this.icon);
}
