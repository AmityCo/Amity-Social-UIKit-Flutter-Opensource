import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/posts/edit_post_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/general_component.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
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
import '../user/user_profile.dart';
import 'comments.dart';
import 'community_feed.dart';
import 'post_content_widget.dart';

class GlobalFeedScreen extends StatefulWidget {
  final isShowMyCommunity;
  const GlobalFeedScreen({super.key, this.isShowMyCommunity = true});

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
    if (myCommunityList.amityCommunities.isEmpty) {
      myCommunityList.initMyCommunity();
    }

    globalFeedProvider.initAmityGlobalfeed();
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
          await vm.initAmityGlobalfeed();
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: FadedSlideAnimation(
                  beginOffset: const Offset(0, 0.3),
                  endOffset: const Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                  child: ListView.builder(
                    // shrinkWrap: true,
                    controller: vm.scrollcontroller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: vm.getAmityPosts().length,
                    itemBuilder: (context, index) {
                      return StreamBuilder<AmityPost>(
                          key: Key(vm.getAmityPosts()[index].postId!),
                          stream: vm.getAmityPosts()[index].listen.stream,
                          initialData: vm.getAmityPosts()[index],
                          builder: (context, snapshot) {
                            var latestComments = snapshot.data!.latestComments;

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
                                          )
                                        : const SizedBox(),
                                PostWidget(
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
                          });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

enum FeedType { user, community, global, pending }

class PostWidget extends StatefulWidget {
  const PostWidget(
      {Key? key,
      required this.post,
      required this.theme,
      required this.postIndex,
      this.isFromFeed = false,
      required this.showlatestComment,
      required this.feedType,
      required this.showCommunity,
      this.showAcceptOrRejectButton = false})
      : super(key: key);
  final FeedType feedType;
  final AmityPost post;
  final ThemeData theme;
  final int postIndex;
  final bool isFromFeed;
  final bool showlatestComment;
  final bool showCommunity;
  final bool showAcceptOrRejectButton;
  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
// with AutomaticKeepAliveClientMixin
{
  double iconSize = 16;
  double feedReactionCountSize = 16;

  Widget postWidgets() {
    List<Widget> widgets = [];
    if (widget.post.data != null) {
      widgets.add(AmityPostWidget([widget.post], false, false));
    }
    final childrenPosts = widget.post.children;
    if (childrenPosts != null && childrenPosts.isNotEmpty) {
      widgets.add(AmityPostWidget(childrenPosts, true, true));
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

    List<String> otherPostMenu = ['Report', 'Block User'];

    final isFlaggedByMe = widget.post.isFlaggedByMe ?? false;

    return PopupMenuButton(
      color: Colors.white,
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
                  Provider.of<FeedVM>(context, listen: false)
                      .deletePost(widget.post, widget.postIndex);
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
                  Provider.of<CommuFeedVM>(context, listen: false)
                      .deletePost(widget.post, widget.postIndex);
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
                      .deletePost(widget.post, widget.postIndex);
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
              print("unhandle postType");
            }
            break;
          case 'Block User':
            Provider.of<UserVM>(context, listen: false)
                .blockUser(widget.post.postedUserId!, () {
              if (widget.feedType == FeedType.global) {
                Provider.of<FeedVM>(context, listen: false)
                    .initAmityGlobalfeed();
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
      child: const Icon(
        Icons.more_horiz_rounded,
        size: 24,
        color: Colors.grey,
      ),
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> menuItems = [];
        // Add post owner options
        if (isPostOwner) {
          menuItems.addAll(postOwnerMenu.map((option) => PopupMenuItem(
                value: option,
                child: Text(option),
              )));
        }

        // Add report/unreport option
        if (!isPostOwner) {
          menuItems.add(PopupMenuItem(
            value: isFlaggedByMe ? 'Unreport Post' : 'Report Post',
            child: Text(isFlaggedByMe ? 'Unreport Post' : 'Report Post'),
          ));
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
                        )));
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 0),
              color: Colors.white,
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
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider(
                                              create: (context) => UserFeedVM(),
                                              child: UserProfileScreen(
                                                amityUser:
                                                    widget.post.postedUser!,
                                                amityUserId: widget
                                                    .post.postedUser!.userId!,
                                              ))));
                                },
                                child: getAvatarImage(widget
                                            .post.postedUser!.userId !=
                                        AmityCoreClient.getCurrentUser().userId
                                    ? widget.post.postedUser?.avatarUrl
                                    : Provider.of<AmityVM>(context)
                                        .currentamityUser!
                                        .avatarUrl))),
                        title: Wrap(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ChangeNotifierProvider(
                                            create: (context) => UserFeedVM(),
                                            child: UserProfileScreen(
                                              amityUser:
                                                  widget.post.postedUser!,
                                              amityUserId: widget
                                                  .post.postedUser!.userId!,
                                            ))));
                              },
                              child: Text(
                                widget.post.postedUser!.userId !=
                                        AmityCoreClient.getCurrentUser().userId
                                    ? widget.post.postedUser?.displayName ??
                                        "Display name"
                                    : Provider.of<AmityVM>(context)
                                            .currentamityUser!
                                            .displayName ??
                                        "",
                                style: widget.theme.textTheme.bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                              ),
                            ),
                            widget.showCommunity &&
                                    widget.post.targetType ==
                                        AmityPostTargetType.COMMUNITY
                                ? const Icon(
                                    Icons.arrow_right_rounded,
                                    color: Colors.black,
                                  )
                                : Container(),
                            widget.showCommunity &&
                                    widget.post.targetType ==
                                        AmityPostTargetType.COMMUNITY
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            TimeAgoWidget(
                              createdAt: widget.post.createdAt!,
                            ),
                            widget.post.editedAt != widget.post.createdAt
                                ? const Row(
                                    children: [
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(
                                        Icons.circle,
                                        size: 4,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("Edited"),
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
                                                        color: Colors.grey,
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
                                                        color: Colors.grey,
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
                                              color: Colors.grey,
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
                                              color: Colors.grey,
                                              fontSize: feedReactionCountSize,
                                              letterSpacing: 0.5),
                                        );
                                      }
                                    })
                                  ],
                                )),
                          ),
                    const Divider(
                      color: Colors.grey,
                      height: 8,
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
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.remove_red_eye,
                                //       size: iconSize.feedIconSize,
                                //       color: ApplicationColors.grey,
                                //     ),
                                //     SizedBox(width: 8.5),
                                //     Text(
                                //       S.of(context).onepointtwok,
                                //       style: TextStyle(
                                //           color: ApplicationColors.grey,
                                //           fontSize: 12,
                                //           letterSpacing: 1),
                                //     ),
                                //   ],
                                // ),
                                // Row(
                                //   children: [
                                //     FaIcon(
                                //       Icons.repeat_rounded,
                                //       color: ApplicationColors.grey,
                                //       size: iconSize.feedIconSize,
                                //     ),
                                //     SizedBox(width: 8.5),
                                //     Text(
                                //       '287',
                                //       style: TextStyle(
                                //           color: ApplicationColors.grey,
                                //           fontSize: 12,
                                //           letterSpacing: 0.5),
                                //     ),
                                //   ],
                                // ),

                                Container(
                                  child: Row(
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
                                                print(widget.post.myReactions);
                                                HapticFeedback.heavyImpact();
                                                Provider.of<PostVM>(context,
                                                        listen: false)
                                                    .addPostReaction(
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
                                                        .likeIcon(),
                                                    Text(
                                                      ' Like',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize:
                                                              feedReactionCountSize,
                                                          letterSpacing: 1),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                    ],
                                  ),
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
                                            color: Colors.grey,
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
                    color: Colors.white,
                    child: const Divider(
                      color: Colors.grey,
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
                        color: Colors.white,
                        child: LatestCommentComponent(
                            postId: widget.post.data!.postId,
                            comments: widget.post.latestComments!),
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
  }) : super(key: key);

  final String postId;

  final List<AmityComment> comments;

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
            // key: Key(widget.comments[index].commentId!),
            stream: widget.comments[index].listen.stream,
            initialData: widget.comments[index],
            builder: (context, snapshot) {
              var comments = widget.comments[index];
              var commentData = widget.comments[index].data as CommentTextData;

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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        // Navigate to user profile
                                      },
                                      child: getAvatarImage(
                                          comments.user?.avatarUrl),
                                    ),
                                    title:
                                        Text(comments.user?.displayName ?? ""),
                                    subtitle: TimeAgoWidget(
                                      createdAt: comments.createdAt!,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10.0),
                                    margin: const EdgeInsets.only(
                                        left: 70.0, right: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      commentData.text!,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  CommentActionComponent(
                                      amityComment: comments),
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
        stream: amityComment.listen.stream,
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
                            const Text(" Like"),
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
                                const Text(" Like"),
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
                                Text(" ${snapshot.data?.reactionCount ?? 0}"),
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
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color(0xff898E9E),
                  ),
                  onPressed: () {
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
