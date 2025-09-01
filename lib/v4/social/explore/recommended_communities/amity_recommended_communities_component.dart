import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/uikit_behavior.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_community_category_view.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/recommended_communities/amity_recommended_community_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/recommended_communities/recommended_communities_cubit.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityRecommendedCommunitiesComponent extends NewBaseComponent {
  final Function(CommunityListState) onStateChanged;
  final ExploreComponentRefreshController? refreshController;

  AmityRecommendedCommunitiesComponent({
    super.key,
    super.pageId,
    this.refreshController,
    required this.onStateChanged,
  }) : super(componentId: 'recommended_communities');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => RecommendedCommunitiesCubit(refreshController)
        ..loadRecommendedCommunities(),
      child: BlocConsumer<RecommendedCommunitiesCubit, CommunityState>(
        listener: (context, state) {
          onStateChanged(
              context.read<RecommendedCommunitiesCubit>().getCurrentState());
        },
        builder: (context, state) {
          if (state.isLoading) {
            return AmityRecommendedCommunityShimmer();
          }

          if (state.hasError || state.communities.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            color: theme.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: Text(context.l10n.community_recommended_for_you,
                      style: AmityTextStyle.titleBold(theme.baseColor)),
                ),
                SizedBox(
                  height: 219,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.communities.length,
                    itemBuilder: (context, index) =>
                        AmityRecommendedCommunityCard(
                      theme: theme,
                      community: state.communities[index],
                      onJoinTap: () => context
                          .read<RecommendedCommunitiesCubit>()
                          .joinCommunity(state.communities[index].communityId!),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AmityRecommendedCommunityCard extends StatelessWidget {
  final AmityThemeColor theme;
  final AmityCommunity community;
  final VoidCallback onJoinTap;

  const AmityRecommendedCommunityCard({
    Key? key,
    required this.theme,
    required this.community,
    required this.onJoinTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasCategories =
        community.categories != null && community.categories!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        UIKitBehavior.instance.postContentComponentBehavior
            .goToCommunityProfilePage(context, community.communityId ?? '');
      },
      child: Container(
        width: 268,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.baseColorShade4),
          borderRadius: BorderRadius.circular(8),
          color: theme.backgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Image
            AmityRecommendedCommunityAvatarView(
              image: community.avatarImage,
              theme: theme,
            ),
            // Community Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Name and Verified Badge
                  Row(
                    children: [
                      if (community.isPublic == false)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_private_community.svg',
                            package: 'amity_uikit_beta_service',
                            width: 16,
                            height: 14,
                          ),
                        ),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                community.displayName ?? '',
                                style: AmityTextStyle.body(theme.baseColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (community.isOfficial == true)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: SvgPicture.asset(
                                  'assets/Icons/amity_ic_verified_community.svg',
                                  package: 'amity_uikit_beta_service',
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  SizedBox(
                    height: 45,
                    width: 250,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasCategories)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 180),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: AmityCommunityCategoryView(
                                    categories: community.categories!,
                                    theme: theme,
                                    maxPreview: 2,
                                  ),
                                ),
                              ),
                            Text(
                              '${(community.membersCount ?? 0).formattedCompactString()} ${context.l10n.profile_members_count(community.membersCount ?? 0)}',
                              style: AmityTextStyle.caption(theme.baseColorShade1),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: AmityCommunityJoinButton(
                            theme: theme,
                            community: community,
                            onTap: onJoinTap,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AmityRecommendedCommunityAvatarView extends StatelessWidget {
  final AmityImage? image;
  final AmityThemeColor theme;

  const AmityRecommendedCommunityAvatarView(
      {Key? key, this.image, required this.theme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      width: 268,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        child: image?.getUrl(AmityImageSize.MEDIUM) != null
            ? Image.network(
                image!.getUrl(AmityImageSize.MEDIUM),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: theme.baseColorShade3,
      child: Center(
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_default_community_avatar.svg',
          width: 64,
          height: 38,
          package: 'amity_uikit_beta_service',
        ),
      ),
    );
  }
}

class AmityCommunityJoinButton extends StatelessWidget {
  final AmityThemeColor theme;
  final AmityCommunity community;
  final VoidCallback onTap;

  const AmityCommunityJoinButton({
    Key? key,
    required this.theme,
    required this.community,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: _getButtonDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getButtonIcon(),
            const SizedBox(width: 4),
            _getButtonLabel(context),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getButtonDecoration() {
    return community.isJoined ?? false
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: theme.baseColorShade3, // Border color
                width: 1.0 // Border width
                ),
          )
        : BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(6),
          );
  }

  Widget _getButtonIcon() {
    return community.isJoined ?? false
        ? Icon(Icons.check, color: theme.baseColor, size: 16)
        : const Icon(Icons.add, color: Colors.white, size: 16);
  }

  Widget _getButtonLabel(BuildContext context) {
    return community.isJoined ?? false
        ? Text(context.l10n.community_joined, style: AmityTextStyle.captionBold(theme.baseColor))
        : Text(context.l10n.community_join, style: AmityTextStyle.captionBold(Colors.white));
  }
}
