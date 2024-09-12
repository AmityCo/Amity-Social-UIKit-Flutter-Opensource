import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_image.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_children_content_video.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_header.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/amity_post_detail_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/bloc/post_item_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/post_item_bottom.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_item/post_item_bottom_nonmember.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PostItem extends NewBaseComponent {
  final AmityPost post;
  final AmityPostCategory category;
  final bool hideMenu;
  final bool hideTarget;
  final AmityPostAction? action;

  PostItem({
    Key? key,
    String? pageId,
    required this.post,
    required this.category,
    required this.hideMenu,
    required this.hideTarget,
    this.action,
  }) : super(key: key, pageId: pageId, componentId: "post_item_component");

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<PostItemBloc, PostItemState>(builder: (context, state) {
      if (state is PostItemStateLoaded) {
        return renderPost(
          context: context,
          post: state.post,
          category: category,
          hideTarget: hideTarget,
        );
      } else if (state is PostItemStateReacting) {
        return renderPost(
          context: context,
          post: state.post,
          category: category,
          hideTarget: hideTarget,
          isReacting: true,
        );
      } else {
        return renderPost(
          context: context,
          post: post,
          category: category,
          hideTarget: hideTarget,
        );
      }
    });
  }

  Widget renderPost({
    required BuildContext context,
    required AmityPost post,
    required AmityPostCategory category,
    required bool hideTarget,
    bool isReacting = false,
  }) {
    onAddReaction(reactionType) {
      context
          .read<PostItemBloc>()
          .add(AddReactionToPost(post: post, reactionType: reactionType));
    }

    onRemoveReaction(reactionType) {
      context
          .read<PostItemBloc>()
          .add(RemoveReactionToPost(post: post, reactionType: reactionType));
    }

    onPostUpdated(post) {
      context.read<PostItemBloc>().add(PostItemLoaded(post: post));
    }

    var postAction = (action != null)
        ? action!.copyWith(
            onAddReaction: onAddReaction,
            onRemoveReaction: onRemoveReaction,
            onPostUpdated: onPostUpdated)
        : AmityPostAction(
            onAddReaction: onAddReaction,
            onRemoveReaction: onRemoveReaction,
            onPostDeleted: (String) {},
            onPostUpdated: onPostUpdated);

    var page = AmityPostDetailPage(
      postId: post.postId!,
      category: category,
      hideMenu: hideMenu,
      action: postAction,
    );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => page,
        ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmityPostHeader(
              post: post,
              theme: theme,
              category: category,
              hideTarget: hideTarget,
              action: postAction,
            ),
            getTextPostContent(post),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: getChildrenPostContent(context, post),
            ),
            hideMenu
                ? PostBottomNonMember()
                : getPostBottom(
                    post: post,
                    action: postAction,
                    isReacting: isReacting,
                  ),
          ],
        ),
      ),
    );
  }

  Widget getTextPostContent(AmityPost post) {
    String textContent = "";
    if (post.data is TextData) {
      textContent = (post.data as TextData).text ?? "";
    }
    return textContent.isNotEmpty
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              textContent,
              style: TextStyle(
                color: theme.baseColor,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        : Container();
  }

  Widget getImagePostContent(List<ImageData> images) {
    final imageUrl = images.first.image?.getUrl(AmityImageSize.LARGE) ?? "";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: AmityNetworkImage(imageUrl: imageUrl, placeHolderPath: 'assets/Icons/amity_ic_image_placeholder.svg'),
      ),
    );
  }

  Widget getVideoPostContent(List<VideoData> images) {
    return Container();
  }

  Widget getChildrenPostContent(BuildContext context, AmityPost post) {
    final noChildrenPost = post.children?.isEmpty ?? true;
    if (noChildrenPost) {
      return Container();
    } else if (post.children!.first.data is ImageData) {
      return PostContentImage(posts: post.children!);
    } else if (post.children!.first.data is VideoData) {
      return PostContentVideo(posts: post.children!);
    } else {
      return Container();
    }
  }

  Widget getPostBottom(
      {required AmityPost post,
      required AmityPostAction action,
      bool isReacting = false}) {
    return PostItemBottom(
      post: post,
      action: action,
      isReacting: isReacting,
      componentId: '',
      isOptimisticUi: true,
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 14), // Reduced padding
                tileColor: Colors.white.withOpacity(0.0),
                leading: Container(
                  height: 100, // Reduced height to make it slimmer
                  width: 40, // Added width to align the image
                  alignment:
                      Alignment.centerLeft, // Center alignment for the image
                  child: Image(
                    image: AssetImage(fileImage,
                        package: 'amity_uikit_beta_service'),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Reduce extra space
                  children: [
                    Text(
                      "${files[index].data!.fileInfo.fileName}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${(files[index].data!.fileInfo.fileSize)} KB',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
}
