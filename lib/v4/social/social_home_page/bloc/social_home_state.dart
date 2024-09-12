// States
import 'package:equatable/equatable.dart';

abstract class SocialHomeState extends Equatable{
  @override
  List<Object> get props => [];
}

class TabState extends SocialHomeState {
  final int selectedIndex;

  TabState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
