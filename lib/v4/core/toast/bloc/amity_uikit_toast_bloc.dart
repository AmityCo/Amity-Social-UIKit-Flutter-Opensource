import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'amity_uikit_toast_events.dart';
part 'amity_uikit_toast_state.dart';

class AmityToastBloc extends Bloc<AmityToastEvent, AmityToastState> {
  AmityToastBloc()
      : super(const AmityToastState(
          message: "",
          style: AmityToastStyle.hidden,
        )) {
    on<AmityToastShort>((event, emit) => emit(AmityToastState(
          message: event.message,
          style: AmityToastStyle.short,
          icon: event.icon,
          key: UniqueKey(),
        )));

    on<AmityToastDismiss>((event, emit) => emit(const AmityToastState(
          message: "",
          style: AmityToastStyle.hidden,
          key: null,
        )));
  }
}
