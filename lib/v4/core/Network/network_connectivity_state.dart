part of 'network_connectivity_bloc.dart';

class NetworkConnectivityState extends Equatable {
  const NetworkConnectivityState({
    this.isConnected = true,
  });

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];

  // copyWith method
  NetworkConnectivityState copyWith({
    bool? isConnected,
  }) {
    return NetworkConnectivityState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
