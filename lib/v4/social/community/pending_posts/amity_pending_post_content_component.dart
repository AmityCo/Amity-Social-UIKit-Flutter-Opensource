// filepath: /Users/zryte/Documents/Amity-Social-Cloud-UIKit-Flutter/lib/v4/social/community/pending_posts/amity_pending_post_content_component.dart
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/expandable_text.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/preview_link_widget.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/amity_global_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_image.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_video.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_poll.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_post_action_cubit.dart';
import 'package:amity_uikit_beta_service/v4/social/community/pending_posts/pending_posts_cubit.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linkify/linkify.dart';

class AmityPendingPostContentComponent extends NewBaseComponent {
  final AmityPost post;
  final AmityPostAction? action;
  final bool isModerator;
  final VoidCallback? onDelete;

  AmityPendingPostContentComponent({
    super.key,
    super.pageId,
    required this.post,
    this.action,
    this.isModerator = false,
    this.onDelete,
  }) : super(componentId: "pending_post_content");

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => PendingPostActionCubit(
        post: post,
        parentCubit: context.read<PendingPostsCubit>(),
        context: context,
        theme: theme,
        toastBloc: context.read<AmityToastBloc>(),
        isModerator: isModerator, // Pass the isModerator property to the cubit
      ),
      child: BlocBuilder<PendingPostActionCubit, PendingPostActionState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(),
                _buildPostContent(),
                if (!state.isLoadingPost && state.isModerator)
                  _buildPostActions(context, state),

                // Show loading indicator for action area when still checking moderator status
                if (state.isLoadingPost) skeletonRow(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions(BuildContext context, PendingPostActionState state) {
    final cubit = context.read<PendingPostActionCubit>();
    final behavior =
        AmityUIKit4Manager.behavior.pendingPostContentComponentBehavior;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Left button (Accept) - taking up half the width minus padding
          behavior.buildPostAcceptButton?.call(
                context,
                isApprovingPost: state.isApprovingPost,
                onPressed:
                    state.isApprovingPost ? null : () => cubit.approvePost(),
              ) ??
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isApprovingPost
                          ? null
                          : () => cubit.approvePost(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.isApprovingPost
                            ? theme.primaryColor.withOpacity(0.6)
                            : theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isApprovingPost
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Accept',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ),
          // Right button (Decline) - taking up half the width minus padding
          behavior.buildPostDeclineButton?.call(
                context,
                isDecliningPost: state.isDecliningPost,
                onPressed:
                    state.isDecliningPost ? null : () => cubit.declinePost(),
              ) ??
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: state.isDecliningPost
                          ? null
                          : () => cubit.declinePost(),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: theme.baseColorShade3, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isDecliningPost
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.secondaryColor,
                                ),
                              ),
                            )
                          : Text(
                              'Decline',
                              style: TextStyle(color: theme.secondaryColor),
                            ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Build post header with options menu for non-moderators
  Widget _buildPostHeader() {
    return BlocBuilder<PendingPostActionCubit, PendingPostActionState>(
      builder: (context, state) {
        // Use data from state if available (not loading), otherwise use initial post
        final displayPost = state.isLoadingPost ? post : state.post;
        var timestampText = displayPost.createdAt?.toSocialTimestamp() ?? "";

        return Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
          child: Row(
            children: [
              // User avatar - make it clickable
              GestureDetector(
                onTap: () => _goToUserProfilePage(
                    context, displayPost.postedUser?.userId ?? ""),
                child: AmityUserAvatar(
                  avatarUrl: displayPost.postedUser?.avatarUrl,
                  displayName: displayPost.postedUser?.displayName ?? "",
                  isDeletedUser: false,
                  avatarSize: const Size(32, 32),
                ),
              ),
              const SizedBox(width: 8),

              // User name and post details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _goToUserProfilePage(
                          context, displayPost.postedUser?.userId ?? ""),
                      child: Text(
                          displayPost.postedUser?.displayName ?? "Unknown User",
                          style: AmityTextStyle.body(theme.baseColor)),
                    ),

                    // Post creation time
                    Text(timestampText,
                        style: AmityTextStyle.caption(theme.baseColorShade2)),
                  ],
                ),
              ),

              // Add 3-dot menu for non-moderators when data is fully loaded
              if (!state.isLoadingPost && !state.isModerator)
                GestureDetector(
                  onTap: () => _showPostAction(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.only(
                        top: 8, left: 4, right: 16, bottom: 8),
                    child: _getPostOptionIcon(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _getPostOptionIcon() {
    return Container(
      width: 16,
      height: 16,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SvgPicture.asset(
        'assets/Icons/amity_ic_post_item_option.svg',
        package: 'amity_uikit_beta_service',
        width: 16,
        height: 12,
      ),
    );
  }

  void _showPostAction(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor: theme.backgroundColor,
        builder: (_) {
          return SizedBox(
            height: 152,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildListTile(
                    assetPath: 'assets/Icons/amity_ic_delete.svg',
                    title: 'Delete post',
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context);
                      _deletePost(context);
                    }),
              ],
            ),
          );
        });
  }

  Widget _buildListTile({
    required String assetPath,
    required String title,
    required Function()? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset(
            assetPath,
            package: 'amity_uikit_beta_service',
            colorFilter: ColorFilter.mode(
              isDestructive ? theme.alertColor : theme.baseColor,
              BlendMode.srcIn,
            ),
            width: 32,
            height: 32,
          )),
      title: Transform.translate(
        offset: const Offset(-5, 0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive ? theme.alertColor : theme.baseColor,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  void _deletePost(BuildContext context) async {
    final toastBloc = context.read<AmityToastBloc>();

    try {
      // Call the API to delete the post
      await AmitySocialClient.newPostRepository()
          .deletePost(postId: post.postId!);

      // Call the onDelete callback to remove from list
      onDelete?.call();

      toastBloc.add(const AmityToastShort(
        message: "Post deleted.",
        icon: AmityToastIcon.success,
      ));
    } catch (error) {
      toastBloc.add(const AmityToastShort(
        message: "Failed to delete post. Please try again.",
        icon: AmityToastIcon.warning,
      ));
    }
  }

  Widget _buildPostContent() {
    return BlocBuilder<PendingPostActionCubit, PendingPostActionState>(
      builder: (context, state) {
        if (state.isLoadingPost) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content placeholder
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: theme.baseColorShade4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: theme.baseColorShade4,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        }

        // Regular content when loaded
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTextPostContent(context),
              if ((state.post.children == null ||
                      state.post.children!.isEmpty) &&
                  state.post.data is TextData)
                PreviewLinkWidget(
                  key: ValueKey('preview_${state.post.postId}'),
                  text: (state.post.data as TextData).text ?? '',
                  theme: theme,
                ),
              SizedBox(
                width: double.infinity,
                child: _getChildrenPostContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  String? extractUrlFromText(String text) {
    if (text.isEmpty) return null;

    final elements = linkify(
      text,
      options: const LinkifyOptions(
        humanize: false,
        defaultToHttps: true,
      ),
    );

    for (var element in elements) {
      if (element is LinkableElement) {
        return element.url;
      }
    }

    return null;
  }

  Widget _getChildrenPostContent() {
    return BlocBuilder<PendingPostActionCubit, PendingPostActionState>(
      builder: (context, state) {
        if (state.isLoadingPost) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.baseColorShade4,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }

        final noChildrenPost = state.post.children?.isEmpty ?? true;
        if (noChildrenPost) {
          return Container();
        } else if (state.post.children!.first.data is ImageData) {
          return PostContentImage(posts: state.post.children!, theme: theme);
        } else if (state.post.children!.first.data is VideoData) {
          return PostContentVideo(posts: state.post.children!, theme: theme);
        } else if (state.post.children!.first.data is PollData) {
          return PostPollContent(
              post: state.post.children!.first,
              style: AmityPostContentComponentStyle.feed,
              theme: theme,
              hideMenu: true,
              goToDetail: () {});
        } else if (state.post.children!.first.data is FileData) {
          return _listMediaGrid(state.post.children!);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _listMediaGrid(List<AmityPost> files) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        String fileImage = _getFileImage(files[index].data!.fileInfo.fileName!);

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: theme.baseColorShade4,
              width: 1.0,
            ),
          ),
          margin: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              ListTile(
                onTap: () {
                  _launchUrl(
                    files[index].data!.fileInfo.fileUrl!,
                  );
                },
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                tileColor: Colors.white.withOpacity(0.0),
                leading: Container(
                  height: 100,
                  width: 40,
                  alignment: Alignment.centerLeft,
                  child: Image(
                    image: AssetImage(fileImage,
                        package: 'amity_uikit_beta_service'),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${files[index].data!.fileInfo.fileName}",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.baseColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(files[index].data!.fileInfo.fileSize)} KB',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.baseColorShade2,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _getFileImage(String filePath) {
    String extension = filePath.split('.').last;
    switch (extension) {
      case 'audio':
        return 'assets/images/fileType/audio_small.png';
      case 'avi':
        return 'assets/images/fileType/avi_large.png';
      case 'csv':
        return 'assets/images/fileType/csv_large.png';
      case 'doc':
        return 'assets/images/fileType/doc_large.png';
      case 'exe':
        return 'assets/images/fileType/exe_large.png';
      case 'html':
        return 'assets/images/fileType/html_large.png';
      case 'img':
        return 'assets/images/fileType/img_large.png';
      case 'mov':
        return 'assets/images/fileType/mov_large.png';
      case 'mp3':
        return 'assets/images/fileType/mp3_large.png';
      case 'mp4':
        return 'assets/images/fileType/mp4_large.png';
      case 'pdf':
        return 'assets/images/fileType/pdf_large.png';
      case 'ppx':
        return 'assets/images/fileType/ppx_large.png';
      case 'rar':
        return 'assets/images/fileType/rar_large.png';
      case 'txt':
        return 'assets/images/fileType/txt_large.png';
      case 'xls':
        return 'assets/images/fileType/xls_large.png';
      case 'zip':
        return 'assets/images/fileType/zip_large.png';
      default:
        return 'assets/images/fileType/default.png';
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget getTextPostContent(BuildContext context) {
    return BlocBuilder<PendingPostActionCubit, PendingPostActionState>(
      builder: (context, state) {
        // Define text styles first
        final normalStyle = AmityTextStyle.body(theme.baseColor);
        final mentionStyle = AmityTextStyle.body(theme.primaryColor);

        // For loading state, show placeholder text boxes
        if (state.isLoadingPost) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: theme.baseColorShade4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: theme.baseColorShade4,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        // Get the text content from the post.
        String textContent = "";
        if (state.post.data is TextData) {
          textContent = (state.post.data as TextData).text ?? "";
        }

        List<AmityUserMentionMetadata>? mentionedUsers;

        if (state.post.metadata != null &&
            state.post.metadata!['mentioned'] != null) {
          // Obtain the mention metadata from the post.
          final mentionedGetter =
              AmityMentionMetadataGetter(metadata: state.post.metadata!);
          mentionedUsers = mentionedGetter.getMentionedUsers();

          // Sort mention metadata by starting index (if not already sorted).
          mentionedUsers.sort((a, b) => a.index.compareTo(b.index));
        }

        // Return a container with ExpandableText widget for the post content
        return textContent.isEmpty
            ? Container()
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ExpandableText(
                    text: textContent,
                    mentionedUsers: mentionedUsers,
                    maxLines: 8,
                    style: normalStyle,
                    linkStyle: mentionStyle,
                    onMentionTap: (userId) =>
                        _goToUserProfilePage(context, userId)));
      },
    );
  }

  void _goToUserProfilePage(BuildContext context, String userId) {
    AmityUIKit4Manager.behavior.pendingPostContentComponentBehavior
        .goToUserProfilePage(
      context,
      userId,
    );
  }
}
