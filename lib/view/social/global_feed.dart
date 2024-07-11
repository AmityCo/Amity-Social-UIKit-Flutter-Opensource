import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/components/post_profile.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/posts/edit_post_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/general_component.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/social/community_feedV2.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/amity_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/my_community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/community_feed_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/edit_post_viewmodel.dart';
import '../../viewmodel/feed_viewmodel.dart';
import '../../viewmodel/post_viewmodel.dart';
import '../../viewmodel/user_feed_viewmodel.dart';
import 'comments.dart';
import 'post_content_widget.dart';

class GlobalFeedScreen extends StatefulWidget {
  final bool isShowMyCommunity;
  final bool canCreateCommunity;
  final bool canSearchCommunities;

  const GlobalFeedScreen({
    super.key,
    this.isShowMyCommunity = true,
    this.canCreateCommunity = true,
    this.canSearchCommunities = true,
    // this.isCustomPostRanking = false
  });

  @override
  GlobalFeedScreenState createState() => GlobalFeedScreenState();
}

class GlobalFeedScreenState extends State<GlobalFeedScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var globalFeedProvider = Provider.of<FeedVM>(context, listen: false);
    var myCommunityList = Provider.of<MyCommunityVM>(context, listen: false);
    myCommunityList.initMyCommunity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalFeedProvider.initAmityGlobalfeed(
          onCustomPost: AmityUIConfiguration.onCustomPost);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        AppBar().preferredSize.height;

    final theme = Theme.of(context);
    return Consumer<FeedVM>(builder: (context, vm, _) {
      return RefreshIndicator(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onRefresh: () async {
          var globalFeedProvider = Provider.of<FeedVM>(context, listen: false);
          var myCommunityList =
              Provider.of<MyCommunityVM>(context, listen: false);

          myCommunityList.initMyCommunity();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            globalFeedProvider.initAmityGlobalfeed(
                onCustomPost:AmityUIConfiguration.onCustomPost);
          });
        },
        child: Container(
          color:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
          child: Stack(
            children: [
              vm.isLoading
                  ? vm.getAmityPosts.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Provider.of<AmityUIConfiguration>(context)
                              .primaryColor,
                        ))
                      : const SizedBox()
                  : const SizedBox(),
              Column(
                children: [
                  Expanded(
                    child: Container(
                      child: FadedSlideAnimation(
                        beginOffset: const Offset(0, 0.3),
                        endOffset: const Offset(0, 0),
                        slideCurve: Curves.linearToEaseOut,
                        child: ListView.builder(
                          // shrinkWrap: true,
                          controller: vm.scrollcontroller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: vm.getAmityPosts.length,
                          itemBuilder: (context, index) {
                            return StreamBuilder<AmityPost>(
                              key: Key(vm.getAmityPosts[index].postId!),
                              stream: vm.getAmityPosts[index].listen.stream.asyncMap((event) async{
                                final newPost = await AmityUIConfiguration.onCustomPost([event]);
                                return newPost.first;
                              }),
                              initialData: vm.getAmityPosts[index],
                              builder: (context, snapshot) {
                                    snapshot.data!.latestComments;
                                var post = snapshot.data!;
                                return Column(
                                  children: [
                                    index != 0
                                        ? const SizedBox()
                                        : widget.isShowMyCommunity
                                            ? CommunityIconList(
                                                amityCommunites:
                                                    Provider.of<MyCommunityVM>(
                                                            context)
                                                        .amityCommunities,
                                                canCreateCommunity:
                                                    widget.canCreateCommunity,
                                              )
                                            : const SizedBox(),
                                    PostWidget(
                                      isPostDetail: false,
                                      // customPostRanking:
                                      //     widget.isCustomPostRanking,
                                      feedType: FeedType.global,
                                      showCommunity: true,
                                      showlatestComment: true,
                                      post: snapshot.data!,
                                      theme: theme,
                                      postIndex: index,
                                      isFromFeed: true,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

enum FeedType { user, community, global, pending }

class PostWidget extends StatefulWidget {
  const PostWidget({
    Key? key,
    required this.post,
    required this.theme,
    required this.postIndex,
    this.isFromFeed = false,
    required this.showlatestComment,
    required this.feedType,
    required this.showCommunity,
    this.showAcceptOrRejectButton = false,
    required this.isPostDetail,
  }) : super(key: key);
  final FeedType feedType;
  final AmityPost post;
  final ThemeData theme;
  final int postIndex;
  final bool isFromFeed;
  final bool showlatestComment;
  final bool showCommunity;
  final bool showAcceptOrRejectButton;
  final bool isPostDetail;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState
    extends State<PostWidget> // with AutomaticKeepAliveClientMixin
{
  double iconSize = 16;
  double feedReactionCountSize = 16;

  Widget postWidgets() {
    List<Widget> widgets = [];
    if (widget.post.data != null) {
      widgets
          .add(AmityPostWidget([widget.post], false, false, widget.feedType));
    }
    final childrenPosts = widget.post.children;
    if (childrenPosts != null && childrenPosts.isNotEmpty) {
      widgets.add(AmityPostWidget(childrenPosts, true, true, widget.feedType));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget postOptions(BuildContext context) {
    bool isPostOwner =
        widget.post.postedUserId == AmityCoreClient.getCurrentUser().userId;
    List<String> postOwnerMenu = ['Edit Post', 'Delete Post'];
    final isFlaggedByMe = widget.post.isFlaggedByMe;
    List<String> otherPostMenu = [
      widget.post.isFlaggedByMe ? 'Report Post' : 'Unreport Post',
      'Block User'
    ];

    return PopupMenuButton(
      color:
          Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      surfaceTintColor: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'Report Post':
          case 'Unreport Post':
            log("isflag by me $isFlaggedByMe");
            if (isFlaggedByMe) {
              Provider.of<PostVM>(context, listen: false)
                  .unflagPost(widget.post);
            } else {
              Provider.of<PostVM>(context, listen: false).flagPost(widget.post);
            }

            break;
          case 'Edit Post':
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<EditPostVM>(
                    create: (context) => EditPostVM(),
                    child: AmityEditPostScreen(
                      amityPost: widget.post,
                    ))));
            break;
          case 'Delete Post':
            if (widget.feedType == FeedType.global) {
              ConfirmationDialog().show(
                context: context,
                title: 'Delete Post?',
                detailText: 'Do you want to Delete your post?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Delete',
                onConfirm: () {
                  Provider.of<FeedVM>(context, listen: false).deletePost(
                      widget.post, widget.postIndex, (isSuccess, error) {
                    if (isSuccess) {
                      if (widget.isPostDetail) {
                        Navigator.of(context).pop();
                      }
                    }
                  });
                },
              );
            } else if (widget.feedType == FeedType.community) {
              ConfirmationDialog().show(
                context: context,
                title: 'Delete Post?',
                detailText: 'Do you want to Delete your post?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Delete',
                onConfirm: () {
                  Provider.of<CommuFeedVM>(context, listen: false).deletePost(
                      widget.post, widget.postIndex, (isSuccess, error) {
                    if (isSuccess) {
                      if (widget.isPostDetail) {
                        Navigator.of(context).pop();
                      }
                    }
                  });
                },
              );
            } else if (widget.feedType == FeedType.user) {
              ConfirmationDialog().show(
                context: context,
                title: 'Delete Post?',
                detailText: 'Do you want to Delete your post?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Delete',
                onConfirm: () {
                  Provider.of<UserFeedVM>(context, listen: false)
                      .deletePost(widget.post, (isSuccess, error) {
                    if (isSuccess) {
                      if (widget.isPostDetail) {
                        Navigator.of(context).pop();
                      }
                    }
                  });
                },
              );
            } else if (widget.feedType == FeedType.pending) {
              ConfirmationDialog().show(
                context: context,
                title: 'Delete Post?',
                detailText: 'Do you want to Delete your post?',
                leftButtonText: 'Cancel',
                rightButtonText: 'Delete',
                onConfirm: () {
                  Provider.of<CommuFeedVM>(context, listen: false)
                      .deletePendingPost(widget.post, widget.postIndex);
                },
              );
            } else {
            }
            break;
          case 'Block User':
            Provider.of<UserVM>(context, listen: false)
                .blockUser(widget.post.postedUserId!, () {
              if (widget.feedType == FeedType.global) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Provider.of<FeedVM>(context, listen: false)
                      .initAmityGlobalfeed(
                          onCustomPost: AmityUIConfiguration.onCustomPost);
                });
              } else if (widget.feedType == FeedType.community) {
                Provider.of<CommuFeedVM>(context, listen: false)
                    .initAmityCommunityFeed(
                        (widget.post.target as CommunityTarget)
                            .targetCommunityId!);
              }
            });

            break;
          default:
        }
      },
      child: Icon(
        Icons.more_horiz_rounded,
        size: 24,
        color: widget.feedType == FeedType.user
            ? Provider.of<AmityUIConfiguration>(context)
                .appColors
                .userProfileTextColor
            : Colors.grey,
      ),
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> menuItems = [];
        // Add post owner options
        if (isPostOwner) {
          menuItems.addAll(postOwnerMenu.map((option) => PopupMenuItem(
                value: option,
                child: Builder(builder: (context) {
                  return Text(
                    option,
                    style: TextStyle(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                  );
                }),
              )));
        }

        // Add report/unreport option
        if (!isPostOwner) {
          menuItems.addAll(otherPostMenu.map((option) => PopupMenuItem(
                value: option,
                child: Builder(builder: (context) {
                  return Text(
                    option,
                    style: TextStyle(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base,
                    ),
                  );
                }),
              )));
        }
        // Add block user option
        // if (!isPostOwner) {
        //   menuItems.add(const PopupMenuItem(
        //     value: 'Block User',
        //     child: Text('Block User'),
        //   ));
        // }

        return menuItems;
      },
    );
  }

  void _onUserProfile() {
    final replaceModeratorProfileNavigation = Provider.of<AmityUIConfiguration>(
      context,
      listen: false,
    ).logicConfig.replaceModeratorProfileNavigation;
    final targetingCommunity =
        widget.post.targetType == AmityPostTargetType.COMMUNITY;

    if (replaceModeratorProfileNavigation &&
        _isModerator &&
        targetingCommunity) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => CommuFeedVM(),
            child: CommunityScreen(
              isFromFeed: true,
              community:
                  (widget.post.target as CommunityTarget).targetCommunity!,
            ),
          ),
        ),
      );
    } else {
      if (widget.post.postedUser!.userId! ==  AmityCoreClient.getCurrentUser().userId&&Provider.of<AmityUIConfiguration>(context,listen: false).customUserProfileNavigate) {
        Provider.of<AmityUIConfiguration>(context,listen: false).onUserProfile(context);
      }else{
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => UserFeedVM(),
            child: UserProfileScreen(
              amityUser: widget.post.postedUser!,
              amityUserId: widget.post.postedUser!.userId!,
            ),
          ),
        ),
      );}
    }
  }

  String? get _avatarUrl {
    final replaceModeratorProfile = Provider.of<AmityUIConfiguration>(context)
        .logicConfig
        .replaceModeratorProfile;
    final targetingCommunity =
        widget.post.targetType == AmityPostTargetType.COMMUNITY;

    if (replaceModeratorProfile && _isModerator && targetingCommunity) {
      return (widget.post.target as CommunityTarget)
          .targetCommunity
          ?.avatarImage
          ?.fileUrl;
    } else {
      return (widget.post.postedUser!.userId !=
              AmityCoreClient.getCurrentUser().userId)
          ? (widget.post.postedUser?.avatarUrl)
          : Provider.of<AmityUIConfiguration>(context).currentUserImageUrl ==
                  true
              ? (widget.post.postedUser?.avatarUrl)
              : (Provider.of<AmityVM>(context).currentamityUser!.avatarUrl);
    }
  }

  String get _displayName {
    final replaceModeratorProfile = Provider.of<AmityUIConfiguration>(context)
        .logicConfig
        .replaceModeratorProfile;
    final targetingCommunity =
        widget.post.targetType == AmityPostTargetType.COMMUNITY;

    if (replaceModeratorProfile && _isModerator && targetingCommunity) {
      return ((widget.post.target as CommunityTarget)
              .targetCommunity
              ?.displayName) ??
          "Display name";
    } else {
      return (widget.post.postedUser!.userId !=
              AmityCoreClient.getCurrentUser().userId)
          ? (widget.post.postedUser?.displayName ?? "Display name")
          : (Provider.of<AmityVM>(context).currentamityUser!.displayName ?? "");
    }
  }

  bool get _isModerator {
    final postMetadata = widget.post.metadata;
    final isModerator =
        postMetadata != null && postMetadata['isCreateByAdmin'] == true;

    return isModerator;
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (widget.isFromFeed) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommentScreen(
                          amityPost: widget.post,
                          theme: widget.theme,
                          isFromFeed: true,
                          feedType: widget.feedType,
                        )));
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 0),
              color: Provider.of<AmityUIConfiguration>(context)
                  .appColors
                  .baseBackground,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  children: [
                    Container(
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                            left: 0, top: 0, right: 0, bottom: 0),
                        leading: FadeAnimation(
                          child: GestureDetector(
                            onTap: _onUserProfile,
                            child: getAvatarImage(_avatarUrl),
                          ),
                        ),
                        title: Wrap(
                          children: [
                            GestureDetector(
                              onTap: _onUserProfile,
                              child: Text(
                                _displayName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Provider.of<AmityUIConfiguration>(
                                            context)
                                        .appColors
                                        .base),
                              ),
                            ),
                            (widget.showCommunity &&
                                    widget.post.targetType ==
                                        AmityPostTargetType.COMMUNITY &&
                                    !_isModerator)
                                ? Icon(
                                    Icons.arrow_right_rounded,
                                    color: Provider.of<AmityUIConfiguration>(
                                            context)
                                        .appColors
                                        .base,
                                  )
                                : Container(),
                            (widget.showCommunity &&
                                    widget.post.targetType ==
                                        AmityPostTargetType.COMMUNITY &&
                                    !_isModerator)
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider(
                                                    create: (context) =>
                                                        CommuFeedVM(),
                                                    child: CommunityScreen(
                                                      isFromFeed: true,
                                                      community: (widget
                                                                  .post.target
                                                              as CommunityTarget)
                                                          .targetCommunity!,
                                                    ),
                                                  )));
                                    },
                                    child: Text(
                                      (widget.post.target as CommunityTarget)
                                              .targetCommunity!
                                              .displayName ??
                                          "Community name",
                                      style: widget.theme.textTheme.bodyLarge!
                                          .copyWith(
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .base,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            TimeAgoWidget(
                              createdAt: widget.post.createdAt!,
                              textColor: widget.feedType == FeedType.user
                                  ? Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .userProfileTextColor
                                  : Colors.grey,
                            ),
                            widget.post.editedAt != widget.post.createdAt
                                ? Row(
                                    children: [
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        Icons.circle,
                                        size: 4,
                                        color: widget.feedType == FeedType.user
                                            ? Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .userProfileTextColor
                                            : Colors.grey,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text("Edited",
                                          style: TextStyle(
                                            color: widget.feedType ==
                                                    FeedType.user
                                                ? Provider.of<
                                                            AmityUIConfiguration>(
                                                        context)
                                                    .appColors
                                                    .userProfileTextColor
                                                : Colors.grey,
                                          )),
                                    ],
                                  )
                                : const SizedBox()
                          ],
                        ),
                        trailing: widget.feedType == FeedType.pending &&
                                widget.post.postedUser!.userId !=
                                    AmityCoreClient.getCurrentUser().userId
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Image.asset(
                                  //   'assets/Icons/ic_share.png',
                                  //   scale: 3,
                                  // ),
                                  // SizedBox(width: iconSize.feedIconSize),
                                  // Icon(
                                  //   Icons.bookmark_border,
                                  //   size: iconSize.feedIconSize,
                                  //   color: ApplicationColors.grey,
                                  // ),
                                  // SizedBox(width: iconSize.feedIconSize),
                                  postOptions(context),
                                ],
                              ),
                      ),
                    ),
                    postWidgets(),
                    widget.feedType == FeedType.pending
                        ? const SizedBox()
                        : Container(
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, bottom: 16, left: 0, right: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Builder(builder: (context) {
                                      return widget.post.reactionCount! > 0
                                          ? Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Provider.of<
                                                              AmityUIConfiguration>(
                                                          context)
                                                      .primaryColor,
                                                  child: const Icon(
                                                    Icons.thumb_up,
                                                    color: Colors.white,
                                                    size: 13,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    widget.post.reactionCount
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: widget
                                                                    .feedType ==
                                                                FeedType.user
                                                            ? Provider.of<
                                                                        AmityUIConfiguration>(
                                                                    context)
                                                                .appColors
                                                                .userProfileTextColor
                                                            : Colors.grey,
                                                        fontSize:
                                                            feedReactionCountSize,
                                                        letterSpacing: 1)),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    widget.post.reactionCount! >
                                                            1
                                                        ? "likes"
                                                        : "like",
                                                    style: TextStyle(
                                                        color: widget
                                                                    .feedType ==
                                                                FeedType.user
                                                            ? Provider.of<
                                                                        AmityUIConfiguration>(
                                                                    context)
                                                                .appColors
                                                                .userProfileTextColor
                                                            : Colors.grey,
                                                        fontSize:
                                                            feedReactionCountSize,
                                                        letterSpacing: 1)),
                                              ],
                                            )
                                          : const SizedBox(
                                              width: 0,
                                            );
                                    }),
                                    Builder(builder: (context) {
                                      // any logic needed...
                                      if (widget.post.commentCount! > 1) {
                                        return Text(
                                          '${widget.post.commentCount} comments',
                                          style: TextStyle(
                                              color: widget.feedType ==
                                                      FeedType.user
                                                  ? Provider.of<
                                                              AmityUIConfiguration>(
                                                          context)
                                                      .appColors
                                                      .userProfileTextColor
                                                  : Colors.grey,
                                              fontSize: feedReactionCountSize,
                                              letterSpacing: 0.5),
                                        );
                                      } else if (widget.post.commentCount! ==
                                          0) {
                                        return const SizedBox(
                                          width: 0,
                                        );
                                      } else {
                                        return Text(
                                          '${widget.post.commentCount} comment',
                                          style: TextStyle(
                                              color: widget.feedType ==
                                                      FeedType.user
                                                  ? Provider.of<
                                                              AmityUIConfiguration>(
                                                          context)
                                                      .appColors
                                                      .userProfileTextColor
                                                  : Colors.grey,
                                              fontSize: feedReactionCountSize,
                                              letterSpacing: 0.5),
                                        );
                                      }
                                    })
                                  ],
                                )),
                          ),
                    Divider(
                      color: widget.feedType == FeedType.user
                          ? Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .userProfileTextColor
                          : Colors.grey,
                      height: 1,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    widget.feedType == FeedType.pending
                        ? widget.showAcceptOrRejectButton
                            ? PendingSectionButton(
                                postId: widget.post.postId!,
                                communityId:
                                    (widget.post.target as CommunityTarget)
                                        .targetCommunityId!,
                              )
                            : const SizedBox()
                        : Container(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    widget.post.myReactions!.contains("like")
                                        ? GestureDetector(
                                            onTap: () {
                                              print(widget.post.myReactions);
                                              HapticFeedback.heavyImpact();
                                              Provider.of<PostVM>(context,
                                                      listen: false)
                                                  .removePostReaction(
                                                      widget.post);
                                            },
                                            child: SizedBox(
                                              height: 40,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Provider.of<AmityUIConfiguration>(
                                                          context)
                                                      .iconConfig
                                                      .likedIcon(
                                                          color: Provider.of<
                                                                      AmityUIConfiguration>(
                                                                  context)
                                                              .primaryColor),
                                                  Text(
                                                    ' Liked',
                                                    style: TextStyle(
                                                      color: Provider.of<
                                                                  AmityUIConfiguration>(
                                                              context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          feedReactionCountSize,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        : GestureDetector(
                                            onTap: () {
                                              HapticFeedback.heavyImpact();
                                              Provider.of<PostVM>(context,
                                                      listen: false)
                                                  .addPostReaction(widget.post);
                                            },
                                            child: SizedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Provider.of<AmityUIConfiguration>(
                                                          context)
                                                      .iconConfig
                                                      .likeIcon(
                                                          color: widget
                                                                      .feedType ==
                                                                  FeedType.user
                                                              ? Provider.of<
                                                                          AmityUIConfiguration>(
                                                                      context)
                                                                  .appColors
                                                                  .userProfileTextColor
                                                              : Colors.grey),
                                                  Text(
                                                    ' Like',
                                                    style: TextStyle(
                                                        color: widget
                                                                    .feedType ==
                                                                FeedType.user
                                                            ? Provider.of<
                                                                        AmityUIConfiguration>(
                                                                    context)
                                                                .appColors
                                                                .userProfileTextColor
                                                            : Colors.grey,
                                                        fontSize:
                                                            feedReactionCountSize,
                                                        letterSpacing: 1),
                                                  ),
                                                ],
                                              ),
                                            )),
                                  ],
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.isFromFeed) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentScreen(
                                                    amityPost: widget.post,
                                                    theme: widget.theme,
                                                    isFromFeed: true,
                                                    feedType: widget.feedType,
                                                  )));
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Provider.of<AmityUIConfiguration>(context)
                                          .iconConfig
                                          .commentIcon(),
                                      const SizedBox(width: 5.5),
                                      Text(
                                        'Comment',
                                        style: TextStyle(
                                            color: Provider.of<
                                                        AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .userProfileIconColor,
                                            fontSize: feedReactionCountSize,
                                            letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                // GestureDetector(
                                //   onTap: () {},
                                //   child: Row(
                                //     children: [
                                //       Provider.of<AmityUIConfiguration>(context)
                                //           .iconConfig
                                //           .shareIcon(iconSize: 16),
                                //       const SizedBox(width: 4),
                                //       Text(
                                //         "Share",
                                //         style: TextStyle(
                                //           color: Colors.grey,
                                //           fontSize: feedReactionCountSize,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),

                    // Divider(),
                    // CommentComponent(
                    //     key: Key(widget.post.postId!),
                    //     postId: widget.post.postId!,
                    //     theme: widget.theme)
                  ],
                ),
              ),
            )),
        widget.post.latestComments == null
            ? const SizedBox()
            : !widget.showlatestComment
                ? const SizedBox()
                : Container(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .baseBackground,
                    child: Divider(
                      color: widget.feedType == FeedType.user
                          ? Provider.of<AmityUIConfiguration>(context)
                              .appColors
                              .userProfileTextColor
                          : Colors.grey,
                      height: 0,
                    )),
        // widget.isFromFeed
        //     ? const SizedBox()
        //     : Container(
        //         color: Colors.white,
        //         child: const Divider(
        //           color: Colors.grey,
        //           height: 0,
        //         )),

        !widget.showlatestComment
            ? const SizedBox()
            : widget.post.latestComments == null
                ? const SizedBox()
                : widget.post.latestComments!.isEmpty
                    ? const SizedBox()
                    : Container(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseBackground,
                        child: LatestCommentComponent(
                          feedType: widget.feedType,
                          postId: widget.post.data!.postId,
                          comments: widget.post.latestComments!,
                        ),
                      ),

        !widget.isFromFeed
            ? const SizedBox()
            : const SizedBox(
                height: 8,
              )
      ],
    );
  }

// @override
// bool get wantKeepAlive {
//   final childrenPosts = widget.post.children;
//   if (childrenPosts != null && childrenPosts.isNotEmpty) {
//     if (childrenPosts[0].data is VideoData) {
//       log("keep ${childrenPosts[0].parentPostId} alive");
//       return true;
//     } else {
//       return true;
//     }
//   } else {
//     return false;
//   }
// }
}

class PendingSectionButton extends StatelessWidget {
  final String postId;
  final String communityId;

  const PendingSectionButton(
      {super.key, required this.postId, required this.communityId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 11,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Provider.of<CommuFeedVM>(context, listen: false).acceptPost(
                    postId: postId,
                    communityId: communityId,
                    callback: (isSuccess) {},
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        Provider.of<AmityUIConfiguration>(context).primaryColor,
                    borderRadius: BorderRadius.circular(4), // Set border radius
                  ),
                  child: const Center(
                      child: Text("Accept",
                          style: TextStyle(
                              color: Colors.white))), // Text color set to white
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Provider.of<CommuFeedVM>(context, listen: false).declinePost(
                    postId: postId,
                    communityId: communityId,
                    callback: (isSuccess) {},
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, // Decline button background color
                    borderRadius: BorderRadius.circular(4), // Set border radius
                    border: Border.all(color: Colors.grey), // Border color
                  ),
                  child: const Center(
                      child: Text("Decline")), // Text with default color
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}

class LatestCommentComponent extends StatefulWidget {
  const LatestCommentComponent({
    Key? key,
    required this.postId,
    required this.comments,
    required this.feedType,
    this.textColor,
  }) : super(key: key);
  final FeedType feedType;
  final String postId;

  final List<AmityComment> comments;
  final Color? textColor;

  @override
  State<LatestCommentComponent> createState() => _LatestCommentComponentState();
}

class _LatestCommentComponentState extends State<LatestCommentComponent> {
  @override
  void initState() {
    super.initState();
  }

  bool isLiked(AsyncSnapshot<AmityComment> snapshot) {
    var comments = snapshot.data!;
    return comments.myReactions?.isNotEmpty ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostVM>(builder: (context, vm, _) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.comments.length,
        itemBuilder: (context, index) {
          return StreamBuilder<AmityComment>(
            key: Key(widget.comments[index].commentId!),
            stream: widget.comments[index].listen.stream.asyncMap((event) async{
              final newPost = await AmityUIConfiguration.onCustomComment([event]);
              return newPost.first;
            }),
            initialData: widget.comments[index],
            builder: (context, snapshot) {
              var comments = snapshot.data!;
              var commentData = comments.data as CommentTextData;

              return index > 1
                  ? const SizedBox()
                  : comments.isDeleted!
                      ? Container(
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(9.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Icon(
                                      Icons.remove_circle_outline,
                                      size: 15,
                                      color: Color(0xff636878),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Text(
                                      "This comment  has been deleted",
                                      style: TextStyle(
                                          color: Color(0xff636878),
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 0,
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              color: widget.feedType == FeedType.user
                                  ? Provider.of<AmityUIConfiguration>(context)
                                      .appColors
                                      .userProfileBGColor
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        top: 14, left: 16, bottom: 8),
                                    child: CustomListTile(
                                        avatarUrl: comments.user!.avatarUrl,
                                        displayName:
                                            comments.user!.displayName!,
                                        createdAt: comments.createdAt!,
                                        editedAt: comments.editedAt!,
                                        userId: comments.user!.userId!,
                                        user: comments.user!),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    margin: const EdgeInsets.only(
                                        left: 70.0, right: 18),
                                    decoration: BoxDecoration(
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .baseShade4,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      commentData.text!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .appColors
                                                .base,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  CommentActionComponent(
                                      amityComment: comments),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            ),
                            // const Divider(
                            //   height: 0,
                            // ),
                          ],
                        );
            },
          );
        },
      );
    });
  }
}

class CommentActionComponent extends StatelessWidget {
  const CommentActionComponent({
    super.key,
    required this.amityComment,
  });

  final AmityComment amityComment;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityComment>(
        stream: amityComment.listen.stream..asyncMap((event) async{
          final newPost = await AmityUIConfiguration.onCustomComment([event]);
          return newPost.first;
        }),
        initialData: amityComment,
        builder: (context, snapshot) {
          var comments = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(left: 70.0, top: 5.0),
            child: Row(
              children: [
                // Like Button
                comments.myReactions == null
                    ? GestureDetector(
                        onTap: () {
                          Provider.of<PostVM>(context, listen: false)
                              .addCommentReaction(comments);
                        },
                        child: Row(
                          children: [
                            Provider.of<AmityUIConfiguration>(context)
                                .iconConfig
                                .likeIcon(),
                            snapshot.data!.reactionCount! > 0
                                ? Text(
                                    " ${snapshot.data!.reactionCount!}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff898E9E),
                                    ),
                                  )
                                : const Text(
                                    " Like",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff898E9E),
                                    ),
                                  ),
                          ],
                        ),
                      )
                    : comments.myReactions!.isEmpty
                        ? GestureDetector(
                            onTap: () {
                              Provider.of<PostVM>(context, listen: false)
                                  .addCommentReaction(comments);
                            },
                            child: Row(
                              children: [
                                Provider.of<AmityUIConfiguration>(context)
                                    .iconConfig
                                    .likeIcon(),
                                snapshot.data!.reactionCount! > 0
                                    ? Text(
                                        " ${snapshot.data!.reactionCount!}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff898E9E),
                                        ),
                                      )
                                    : const Text(
                                        " Like",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff898E9E),
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              print("addCommentReaction");
                              Provider.of<PostVM>(context, listen: false)
                                  .removeCommentReaction(comments);
                            },
                            child: Row(
                              children: [
                                Provider.of<AmityUIConfiguration>(context)
                                    .iconConfig
                                    .likedIcon(
                                        color:
                                            Provider.of<AmityUIConfiguration>(
                                                    context)
                                                .primaryColor),
                                Text(
                                  " ${snapshot.data?.reactionCount ?? 0}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .primary),
                                ),
                              ],
                            )),

                // const SizedBox(width: 10),
                // // Reply Button
                // Provider.of<AmityUIConfiguration>(
                //         context)
                //     .iconConfig
                //     .replyIcon(),

                // const Text(
                //   "Reply",
                //   style: TextStyle(
                //     color: Color(0xff898E9E),
                //   ),
                // ),

                // More Options Button
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  child: const Icon(
                    Icons.more_horiz,
                    color: Color(0xff898E9E),
                  ),
                  onTap: () {
                    AmityGeneralCompomemt.showOptionsBottomSheet(context, [
                      comments.user?.userId! ==
                              AmityCoreClient.getCurrentUser().userId
                          ? const SizedBox()
                          : ListTile(
                              title: const Text(
                                'Report',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                              },
                            ),

                      ///check admin
                      comments.user?.userId! !=
                              AmityCoreClient.getCurrentUser().userId
                          ? const SizedBox()
                          : ListTile(
                              title: const Text(
                                'Edit Comment',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditCommentPage(
                                          feedType: FeedType.user,
                                          initailText:
                                              (comments.data as CommentTextData)
                                                  .text!,
                                          comment: comments,
                                          postCallback: () async {},
                                        )));
                              },
                            ),
                      comments.user?.userId! !=
                              AmityCoreClient.getCurrentUser().userId
                          ? const SizedBox()
                          : ListTile(
                              title: const Text(
                                'Delete Comment',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () async {
                                ConfirmationDialog().show(
                                    context: context,
                                    title: "Delete this comment",
                                    detailText:
                                        " This comment will be permanently deleted. You'll no longer to see and find this comment",
                                    onConfirm: () {
                                      Provider.of<PostVM>(context)
                                          .deleteComment(comments);
                                      // AmitySuccessDialog
                                      //     .showTimedDialog(
                                      //         "Success",
                                      //         context:
                                      //             context);
                                      Navigator.pop(context);
                                    });
                              },
                            ),
                    ]);
                  },
                ),
              ],
            ),
          );
        });
  }
}
