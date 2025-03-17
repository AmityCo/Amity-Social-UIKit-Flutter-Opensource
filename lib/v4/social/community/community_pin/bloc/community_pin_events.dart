part of 'community_pin_bloc.dart';

abstract class CommunityPinEvent extends Equatable {
  const CommunityPinEvent();

  @override
  List<Object> get props => [];
}

class CommunityPinEventAnnouncementUpdated extends CommunityPinEvent {
  final List<AmityPinnedPost> announcements;

  const CommunityPinEventAnnouncementUpdated({required this.announcements});

  @override
  List<Object> get props => [announcements];
}

class CommunityPinEventPinUpdated extends CommunityPinEvent {
  final List<AmityPinnedPost> pins;

  const CommunityPinEventPinUpdated({required this.pins});

  @override
  List<Object> get props => [pins];
}