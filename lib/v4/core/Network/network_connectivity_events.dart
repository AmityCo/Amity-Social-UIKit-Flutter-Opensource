part of 'network_connectivity_bloc.dart';

abstract class NetworkConnectivityEvent extends Equatable {
  const NetworkConnectivityEvent();

  @override
  List<Object> get props => [];
}

class NetworkConnectivityChangedEvent extends NetworkConnectivityEvent {
  final bool isConnected;

  const NetworkConnectivityChangedEvent({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}