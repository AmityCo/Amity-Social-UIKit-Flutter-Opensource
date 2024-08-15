// Bloc

import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_event.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/bloc/social_home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialHomeBloc extends Bloc<SocialHomeEvent, SocialHomeState> {
  SocialHomeBloc() : super(TabState(0)) {
    on<TabSelectedEvent>(_onTabSelected);
  }

  void _onTabSelected(TabSelectedEvent event, Emitter<SocialHomeState> emit) {
    emit(TabState(event.tabIndex));
  }
}
