part of 'community_setup_page_bloc.dart';

class CommunitySetupPageEvent extends Equatable {
  const CommunitySetupPageEvent();

  @override
  List<Object> get props => [];
}

class CommunitySetupPageImagePickerEvent extends CommunitySetupPageEvent {
  const CommunitySetupPageImagePickerEvent();
}

class CommunitySetupPageCameraImageEvent extends CommunitySetupPageEvent {
  final XFile image;

  const CommunitySetupPageCameraImageEvent(this.image);

  @override
  List<Object> get props => [image];
}

class CommunitySetupPageNameChangedEvent extends CommunitySetupPageEvent {
  final String name;

  const CommunitySetupPageNameChangedEvent(this.name);

  @override
  List<Object> get props => [name];
}

class CommunitySetupPageDescriptionChangedEvent
    extends CommunitySetupPageEvent {
  final String description;

  const CommunitySetupPageDescriptionChangedEvent(this.description);

  @override
  List<Object> get props => [description];
}

class CommunitySetupPageCategoryChangedEvent extends CommunitySetupPageEvent {
  final List<CommunityCategory> communityCategories;

  const CommunitySetupPageCategoryChangedEvent(this.communityCategories);

  @override
  List<Object> get props => [communityCategories];
}

class CommunitySetupPagePrivacyChangedEvent extends CommunitySetupPageEvent {
  final CommunityPrivacy privacy;

  const CommunitySetupPagePrivacyChangedEvent(this.privacy);

  @override
  List<Object> get props => [privacy];
}

class CommunitySetupPageAddMemberEvent extends CommunitySetupPageEvent {
  final List<AmityUser> users;

  const CommunitySetupPageAddMemberEvent(this.users);

  @override
  List<Object> get props => [users];
}

class CommunitySetupPageRemoveMemberEvent extends CommunitySetupPageEvent {
  final AmityUser user;

  const CommunitySetupPageRemoveMemberEvent(this.user);

  @override
  List<Object> get props => [user];
}

// ignore: must_be_immutable
class CommunitySetupPageCreateCommunityEvent extends CommunitySetupPageEvent {
  final AmityToastBloc toastBloc;
  final BuildContext context;
  Function(AmityCommunity) onSuccess;

  CommunitySetupPageCreateCommunityEvent(
      {required this.toastBloc,
      required this.context,
      required this.onSuccess});
}

// ignore: must_be_immutable
class CommunitySetupPageSaveCommunityEvent extends CommunitySetupPageEvent {
  final AmityToastBloc toastBloc;
  final BuildContext context;
  Function onSuccess;

  CommunitySetupPageSaveCommunityEvent(
      {required this.toastBloc,
      required this.context,
      required this.onSuccess});
}
