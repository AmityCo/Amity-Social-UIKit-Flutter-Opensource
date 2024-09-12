import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_categories.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_cover_view.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_info_view.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_join_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_pending_post.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_title.dart';
import 'package:amity_uikit_beta_service/v4/utils/Shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AmityCommunityHeaderStyle { EXPANDED, COLLAPSE }

class AmityCommunityHeaderComponent extends NewBaseComponent {
  final AmityCommunityHeaderStyle style;
  final AmityCommunity? community;

  AmityCommunityHeaderComponent({
    super.key,
    required this.style,
    required this.community,
  }) : super(componentId: "community_header");

  @override
  Widget buildComponent(BuildContext context) {
    if (style == AmityCommunityHeaderStyle.EXPANDED) {
      final categories = community?.categories
              ?.map((e) => (e?.name ?? ""))
              .where((e) => e.isNotEmpty)
              .toList() ??
          <String>[];
      return (community == null)
          ? CommunityProfileHeaderSkeleton()
          : Column(
              children: [
                AmityCommunityCoverView(community: community, style: style),
                Container(
                  color: theme.backgroundColor,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            left: 16, top: 16, right: 16, bottom: 10),
                        child: AmityCommunityProfileTitleView(
                            community: community),
                      ),
                      if (categories.isNotEmpty)
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child:
                                AmityCommunityCategoryList(tags: categories)),
                      if (community?.description?.isNotEmpty == true)
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    community?.description ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: theme.baseColor,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (community != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 8),
                          child: AmityCommunityInfoView(community: community!),
                        ),
                      BlocConsumer<CommunityProfileBloc, CommunityProfileState>(
                        builder: (context, state) {
                          return (state.isJoined == false)
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: AmityCommunityJoinButton(
                                    community: community!,
                                  ),
                                )
                              : Container();
                        },
                        listener: (BuildContext context,
                            CommunityProfileState state) {},
                      ),
                        BlocConsumer<CommunityProfileBloc,
                            CommunityProfileState>(
                          builder: (context, state) {
                            return (state.isJoined && state.pendingPostCount > 0)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16),
                                    child: AmityCommunityPendingPost(
                                      community: community!,
                                      pendingPostCount: state.pendingPostCount,
                                      isModerator: state.isModerator,
                                    ),
                                  )
                                : Container();
                          },
                          listener: (BuildContext context,
                              CommunityProfileState state) {},
                        )
                    ],
                  ),
                ),
              ],
            );
    } else {
      return (community == null)
          ? CommunityProfileHeaderSkeleton()
          : Stack(
              fit: StackFit.expand,
              children: [
                AmityCommunityCoverView(
                  community: community,
                  style: AmityCommunityHeaderStyle.COLLAPSE,
                ),
              ],
            );
    }
  }

  Widget CommunityProfileHeaderSkeleton() {
    return Shimmer(
      linearGradient: configProvider.getShimmerGradient(),
      child: Container(
        width: double.infinity,
        height: 346,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: ShimmerLoading(
          isLoading: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 188,
                decoration: BoxDecoration(color: theme.baseColorShade4),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: Container(
                  width: 200,
                  height: 12,
                  decoration: ShapeDecoration(
                    color: theme.baseColorShade4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Row(
                    children: [
                      chipSkeleton(),
                      const SizedBox(width: 12),
                      chipSkeleton(),
                      const SizedBox(width: 12),
                      chipSkeleton(),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 21),
                child: Container(
                  width: 240,
                  height: 8,
                  decoration: ShapeDecoration(
                    color: theme.baseColorShade4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: Container(
                  width: 297,
                  height: 8,
                  decoration: ShapeDecoration(
                    color: theme.baseColorShade4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: Row(
                    children: [
                      chipSkeleton(),
                      SizedBox(width: 12),
                      chipSkeleton(),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget chipSkeleton() {
    return Container(
      width: 54,
      height: 12,
      decoration: ShapeDecoration(
        color: theme.baseColorShade4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
