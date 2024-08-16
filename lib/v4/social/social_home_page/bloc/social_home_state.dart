// States
abstract class SocialHomeState {}

class TabState extends SocialHomeState {
  final int selectedIndex;

  TabState(this.selectedIndex);
}
