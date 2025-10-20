import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/category/amity_community_category_view.dart';
import 'package:amity_uikit_beta_service/v4/social/explore/communities_by_category/bloc/communities_by_category_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/app_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunitiesByCategoryPage extends NewBasePage {
  final AmityCommunityCategory category;
  final ScrollController _scrollController = ScrollController();

  AmityCommunitiesByCategoryPage({super.key, required this.category})
      : super(pageId: 'amity_communities_by_category_page');

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CommunitiesByCategoriesPageBloc(category, _scrollController),
      child: BlocBuilder<CommunitiesByCategoriesPageBloc,
          CommunitiesByCategoriesPageState>(
        builder: (context, state) {
          return _getPageWidget(context, state);
        },
      ),
    );
  }

  Widget _getPageWidget(
      BuildContext context, CommunitiesByCategoriesPageState state) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AmityAppBar(
          title: category.name ?? context.l10n.category_default_title,
          configProvider: configProvider,
          theme: theme),
      body: state.communities.isEmpty
          ? _getEmptyState(context)
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => {
                          _goToCommunityProfilePage(
                              context, state.communities[index])
                        },
                        child: _getCommunityItem(
                            context, state.communities[index]),
                      );
                    },
                    childCount: state.communities.length,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _getCommunityItem(BuildContext context, AmityCommunity community) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
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
                  ),
                ),
              )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
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
                  context.l10n
                      .community_members_count(community.membersCount ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _getEmptyState(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/Icons/amity_ic_user_profile_empty_state.svg',
              width: 60,
              height: 60,
              package: 'amity_uikit_beta_service',
            ),
            const SizedBox(height: 16),
            Text(context.l10n.community_empty_state,
                style: AmityTextStyle.titleBold(theme.baseColorShade3)),
            const SizedBox(height: 40)
          ],
        )
      ],
    );
  }

  void _goToCommunityProfilePage(
      BuildContext context, AmityCommunity community) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AmityCommunityProfilePage(
        communityId: community.communityId ?? '',
      ),
    ));
  }
}
