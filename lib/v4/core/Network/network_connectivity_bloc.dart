import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'network_connectivity_events.dart';
part 'network_connectivity_state.dart';

class NetworkConnectivityBloc
    extends Bloc<NetworkConnectivityEvent, NetworkConnectivityState> {

  late final StreamSubscription<List<ConnectivityResult>> subscription;

  NetworkConnectivityBloc() : super(const NetworkConnectivityState()) {
    // Update state
    on<NetworkConnectivityChangedEvent>((event, emit) {
      emit(state.copyWith(
        isConnected: event.isConnected,
      ));
    });

    // Observe Network Connectivity status here
    subscription =
        Connectivity().onConnectivityChanged.listen((connectivityEvent) {
      if (connectivityEvent.contains(ConnectivityResult.none)) {
        add(const NetworkConnectivityChangedEvent(
            isConnected: false));
      } else {
        add(const NetworkConnectivityChangedEvent(
            isConnected: true));
      }
    });
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
