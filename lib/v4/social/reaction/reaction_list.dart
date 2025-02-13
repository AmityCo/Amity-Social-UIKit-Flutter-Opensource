import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/bloc/reaction_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityReactionList extends NewBaseComponent {
  final String referenceId;
  final AmityReactionReferenceType referenceType;
  late int? reactionCount = 0;


  AmityReactionList({
    Key? key,
    String? pageId,
    required this.referenceId,
    required this.referenceType,
  }) : super(key: key, pageId: pageId, componentId: 'reactions_component');

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => ReactionListBloc(
          referenceId: referenceId, referenceType: referenceType),
      child: Builder(
        builder: (context) {
          context.read<ReactionListBloc>().add(ReactionListEventInit());
          return BlocBuilder<ReactionListBloc, ReactionListState>(
            builder: (context, state) {
              if (state is ReactionListLoading) {
                return getSkeletonList();
              } else if (state is ReactionListLoaded) {
                reactionCount = state.list.length;
                return getReactionList(context, state);
              } else {
                return getSkeletonList();
              }
            },
          );
        },
      ),
    );
  }

  Widget getReactionList(BuildContext context, ReactionListLoaded state) {
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<ReactionListBloc>().add(ReactionListEventLoadMore());
      }
    });

    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        bottomSheetHandle(),
        reactionTab(),
        Divider(
          color: theme.baseColorShade4,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: state.list.length,
            separatorBuilder: (context, index) {
              return Divider(
                color: theme.baseColorShade4,
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
                height: 8,
              );
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    top: index == 0
                        ? 0.0
                        : 0.0), // Change the value to adjust the padding
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reactionRow(context, state.list[index]),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget getSkeletonList() {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        bottomSheetHandle(),
        reactionTab(),
        Divider(
          color: theme.baseColorShade4,
          thickness: 0.5,
          height: 0,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                  skeletonItem(),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget bottomSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 15),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: theme.baseColorShade3,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget reactionTab() {
    final tabTextStyle = TextStyle(
        fontSize: 17.0,
        color: theme.primaryColor,
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w600);
    return Container(
      color: theme.backgroundColor,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(1, (index) {
            TextPainter textPainter = TextPainter(
              text: TextSpan(
                text: reactionCount?.formattedCompactString(),
                style: tabTextStyle,
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            double textWidth = textPainter.width;
            return GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          configProvider.getReaction("like").imagePath,
                          package: 'amity_uikit_beta_service',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${reactionCount?.formattedCompactString()}",
                          style: tabTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: textWidth + 28,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  ImageProvider getAvatarImage(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    } else {
      return const AssetImage("assets/images/user_placeholder.png",
          package: "amity_uikit_beta_service");
    }
  }

  Widget reactionRow(BuildContext context, AmityReaction reaction) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              amityUserId: reaction.creator?.userId ?? '',
              amityUser: null,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatarImage(reaction),
            displayName(reaction.creator?.displayName ?? ""),
            SizedBox(
              height: double.infinity,
              child: SvgPicture.asset(
                configProvider
                    .getReaction(reaction.reactionName ?? "")
                    .imagePath,
                package: 'amity_uikit_beta_service',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget avatarImage(AmityReaction reaction) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          width: 32,
          height: 32,
          child: AmityUserImage(
              user: reaction.creator,
              theme: theme,
              size: 32),
        ),
      ),
    );
  }

  Widget displayName(String displayName) {
    return Expanded(
      child: Text(
        displayName,
        style: TextStyle(
          color: theme.baseColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'SF Pro Text',
        ),
      ),
    );
  }

  Widget skeletonItem() {
    return ShimmerLoading(
      isLoading: true,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 56,
              padding:
                  const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
              child: const SkeletonImage(
                height: 40,
                width: 40,
                borderRadius: 40,
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14.0),
                SkeletonText(width: 180),
                SizedBox(height: 12.0),
                SkeletonText(width: 108),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
