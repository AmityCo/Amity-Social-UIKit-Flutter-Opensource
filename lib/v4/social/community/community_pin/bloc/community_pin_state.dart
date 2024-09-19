part of 'community_pin_bloc.dart';

class CommunityPinState extends Equatable {
  final List<AmityPinnedPost> announcements;
  final List<AmityPinnedPost> pins;
  final bool isFetching;

  CommunityPinState({
    this.announcements = const [],
    this.pins = const [],
    this.isFetching = false,
  });

  factory CommunityPinState.initial() {
    return CommunityPinState(
      announcements: const [],
      pins: const [],
      isFetching: false,
    );
  }

  @override
  List<Object?> get props => [announcements, pins];

  CommunityPinState copyWith({
    List<AmityPinnedPost>? announcements,
    List<AmityPinnedPost>? pins,
    bool? isFetching,
  }) {
    return CommunityPinState(
      announcements: announcements ?? this.announcements,
      pins: pins ?? this.pins,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}
