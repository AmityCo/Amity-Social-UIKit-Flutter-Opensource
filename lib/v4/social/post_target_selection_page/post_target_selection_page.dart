import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post_target_selection_page/bloc/post_target_selection_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/Shimmer.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityPostTargetSelectionPage extends NewBasePage {
  AmityPostTargetSelectionPage({Key? key})
      : super(key: key, pageId: 'select_post_target_page');
  final ScrollController scrollController = ScrollController();

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => PostTargetSelectionBloc(),
      child: Builder(builder: (context) {
        context
            .read<PostTargetSelectionBloc>()
            .add(PostTargetSelectionEventInitial());

        scrollController.addListener(
          () {
            if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
              context
                  .read<PostTargetSelectionBloc>()
                  .add(PostTargetSelectionEventLoadMore());
            }
          },
        );

        return BlocBuilder<PostTargetSelectionBloc, PostTargetSelectionState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                title: const Text(
                  'Post to',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
                leading: IconButton(
                  icon: SvgPicture.asset(
                    'assets/Icons/amity_ic_close_button.svg',
                    package: 'amity_uikit_beta_service',
                    width: 24,
                    height: 24,
                    colorFilter:
                        ColorFilter.mode(theme.baseColor, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle the close action
                  },
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () {
                        final createOptions =
                            AmityPostComposerOptions.createOptions(
                                targetType: AmityPostTargetType.USER);
                        // Navigate or perform action based on 'Global Feed' tap
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              final tween = Tween(begin: begin, end: end);
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: curve,
                              );

                              return SlideTransition(
                                position: tween.animate(curvedAnimation),
                                child: child,
                              );
                            },
                            reverseTransitionDuration: Duration.zero,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    PopScope(
                              canPop: true,
                              child: AmityPostComposerPage(
                                options: createOptions,
                                onPopRequested: (shouldPopCaller) {
                                  if (shouldPopCaller) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      leading: SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: AmityNetworkImage(
                              imageUrl:
                                  AmityCoreClient.getCurrentUser().avatarUrl,
                              placeHolderPath:
                                  "assets/Icons/amity_ic_user_avatar_placeholder.svg"),
                        ),
                      ),
                      title: Text('My timeline',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.baseColor)),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Divider(
                      color: theme.baseColorShade4,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                      height: 0,
                    ),
                    const SizedBox(
                      height: 23,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'My Communities',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: theme.baseColorShade3,
                        ),
                      ),
                    ),
                    communityRow(context, state),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget communityRow(BuildContext context, PostTargetSelectionState state) {
    if (state is PostTargetSelectionLoading) {
      return skeletonList();
    } else if (state is PostTargetSelectionLoaded) {
      final communities = state.list;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: communities.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getCommunityRow(
                  context,
                  communities[index],
                )
              ],
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget getCommunityRow(BuildContext context, AmityCommunity community) {
    return ListTile(
      onTap: () {
        final createOptions = AmityPostComposerOptions.createOptions(
            targetId: community.communityId,
            community: community,
            targetType: AmityPostTargetType.COMMUNITY);
        // Navigate or perform action based on 'Global Feed' tap
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween = Tween(begin: begin, end: end);
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            },
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, secondaryAnimation) => PopScope(
              canPop: true,
              child: AmityPostComposerPage(
                options: createOptions,
                onPopRequested: (shouldPopCaller) {
                  if (shouldPopCaller) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CommunityImageAvatarElement(
              avatarUrl: community.avatarImage?.fileUrl, elementId: ''),
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!(community.isPublic ?? false))
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: AmityPrivateBadgeElement(),
                      ),
                    Flexible(
                      child: Text(
                        community.displayName ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.baseColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (community.isOfficial ?? true)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: AmityOfficialBadgeElement(),
                      ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget skeletonList() {
    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(children: [
        Container(
          alignment: Alignment.topCenter,
          child: Shimmer(
            linearGradient: configProvider.getShimmerGradient(),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Divider(
                  color: theme.baseColorShade4,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                  height: 25,
                );
              },
              itemBuilder: (context, index) {
                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        isLoading: true,
                        child: skeletonRow(),
                      ),
                    ],
                  ),
                );
              },
              itemCount: 5,
            ),
          ),
        ),
      ]),
    );
  }

  Widget skeletonRow() {
    return SizedBox(
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
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 14.0),
            Container(
              width: 180,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
