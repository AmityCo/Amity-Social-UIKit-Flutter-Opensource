// Events
abstract class SocialHomeEvent {}

class TabSelectedEvent extends SocialHomeEvent {
  final int tabIndex;

  TabSelectedEvent(this.tabIndex);
}
