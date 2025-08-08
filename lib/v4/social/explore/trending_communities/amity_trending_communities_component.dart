import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_community_category_view.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/explore_component_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/list_state/amity_list_states.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/recommended_communities/amity_recommended_communities_component.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/trending_communities/amity_trending_community_shimmer.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/trending_communities/trending_communities_cubit.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityTrendingCommunitiesComponent extends NewBaseComponent {
  final Function(CommunityListState) onStateChanged;
  final ExploreComponentRefreshController? refreshController;

  AmityTrendingCommunitiesComponent({
    super.key,
    super.pageId,
    this.refreshController,
    required this.onStateChanged,
  }) : super(componentId: 'trending_communities');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => TrendingCommunitiesCubit(refreshController)
        ..loadTrendingCommunities(),
      child: AmityTrendingCommunitiesView(
          theme: theme, onStateChanged: onStateChanged),
    );
  }
}

class AmityTrendingCommunitiesView extends StatelessWidget {
  final AmityThemeColor theme;
  final Function(CommunityListState) onStateChanged;

  const AmityTrendingCommunitiesView({
    Key? key,
    required this.theme,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrendingCommunitiesCubit, CommunityState>(
      listener: (context, state) {
        onStateChanged(
            context.read<TrendingCommunitiesCubit>().getCurrentState());
      },
      builder: (context, state) {
        if (state.isLoading) {
          return AmityTrendingCommunityShimmer();
        }

        if (state.hasError || state.communities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 20, bottom: 16),
              child: Text(
                context.l10n.community_trending_now,
                style: AmityTextStyle.titleBold(theme.baseColor),
              ),
            ),
            for (var entry in state.communities.asMap().entries)
              AmityJoinCommunityView(
                index: entry.key,
                theme: theme,
                community: entry.value,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AmityCommunityProfilePage(
                      communityId: entry.value.communityId!,
                    ),
                  ));
                },
                onJoinTap: () {
                  if (entry.value.isJoined == true) {
                    context
                        .read<TrendingCommunitiesCubit>()
                        .leaveCommunity(entry.value.communityId!);
                  } else {
                    context
                        .read<TrendingCommunitiesCubit>()
                        .joinCommunity(entry.value.communityId!);
                  }
                },
              )
          ],
        );
      },
    );
  }
}

class AmityJoinCommunityView extends StatelessWidget {
  final AmityThemeColor theme;
  final AmityCommunity community;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;
  final int index;

  const AmityJoinCommunityView({
    Key? key,
    required this.theme,
    required this.community,
    required this.onTap,
    required this.onJoinTap,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    community.avatarImage?.getUrl(AmityImageSize.MEDIUM) ?? '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: theme.baseColorShade3,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_default_community_avatar.svg',
                            width: 24,
                            height: 18,
                            package: 'amity_uikit_beta_service',
                          ),
                        )),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 6),
                    child: Text(
                      '0${index + 1}',
                      style: AmityTextStyle.bodyBold(Colors.white),
                    )),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 4),
                      if (community.categories != null &&
                          community.categories!.isNotEmpty)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: AmityCommunityCategoryView(
                              categories: community.categories!,
                              theme: theme,
                              maxPreview: 2,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${(community.membersCount ?? 0).formattedCompactString()} ${context.l10n.profile_members_count(community.membersCount ?? 0)}',
                        style: AmityTextStyle.caption(theme.baseColorShade1),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 8,
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
    );
  }
}
