part of 'community_setup_page_bloc.dart';

// ignore: must_be_immutable
class CommunitySetupPageState extends Equatable {
  CommunitySetupPageState();
  File? pickedImage;
  AmityImage? avatar;
  String communityName = '';
  String communityDescription = '';
  List<CommunityCategory> communityCategories = [];
  List<AmityUser> communityMembers = [];
  CommunityPrivacy communityPrivacy = CommunityPrivacy.public;
  bool hasExistingDataChanged = false;
  bool isCommunityPrivacyUpdatedToPrivate = false;

  CommunitySetupPageState copyWith(
      {File? pickedImage,
      AmityImage? avatar,
      String? communityName,
      String? communityDescription,
      List<CommunityCategory>? communityCategories,
      CommunityPrivacy? communityPrivacy,
      List<AmityUser>? communityMembers,
      bool? hasExistingDataChanged,
      bool? isCommunityPrivacyUpdatedToPrivate}) {
    return CommunitySetupPageState()
      ..pickedImage = pickedImage ?? this.pickedImage
      ..avatar = avatar ?? this.avatar
      ..communityName = communityName ?? this.communityName
      ..communityCategories = communityCategories ?? this.communityCategories
      ..communityDescription = communityDescription ?? this.communityDescription
      ..communityPrivacy = communityPrivacy ?? this.communityPrivacy
      ..communityMembers = communityMembers ?? this.communityMembers
      ..hasExistingDataChanged =
          hasExistingDataChanged ?? this.hasExistingDataChanged
      ..isCommunityPrivacyUpdatedToPrivate =
          isCommunityPrivacyUpdatedToPrivate ?? this.isCommunityPrivacyUpdatedToPrivate;
  }

  @override
  List<Object> get props => [
        pickedImage ?? File(''),
        communityName,
        communityDescription,
        communityCategories,
        communityPrivacy,
        communityMembers,
        hasExistingDataChanged,
        isCommunityPrivacyUpdatedToPrivate
      ];
}
