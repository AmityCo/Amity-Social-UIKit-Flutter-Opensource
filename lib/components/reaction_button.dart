import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/post_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ReactionWidget extends StatelessWidget {
  final AmityPost post;
  final FeedType feedType;
  final double feedReactionCountSize;

  const ReactionWidget({
    Key? key,
    required this.post,
    required this.feedType,
    required this.feedReactionCountSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.only(top: 6, bottom: 6, left: 0, right: 0)),
      minimumSize: MaterialStateProperty.all<Size>(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              post.myReactions!.contains("like")
                  ? TextButton(
                      onPressed: () {
                        print(post.myReactions);
                        HapticFeedback.heavyImpact();
                        Provider.of<PostVM>(context, listen: false)
                            .removePostReaction(post);
                      },
                      style: buttonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Provider.of<AmityUIConfiguration>(context)
                              .iconConfig
                              .likedIcon(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .primaryColor,
                              ),
                          Text(
                            ' Liked',
                            style: TextStyle(
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: feedReactionCountSize,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      child: TextButton(
                        onPressed: () {
                          print(post.myReactions);
                          HapticFeedback.heavyImpact();
                          Provider.of<PostVM>(context, listen: false)
                              .addPostReaction(post);
                        },
                        style: buttonStyle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Provider.of<AmityUIConfiguration>(context)
                                .iconConfig
                                .likeIcon(
                                  color: feedType == FeedType.user
                                      ? Provider.of<AmityUIConfiguration>(
                                              context)
                                          .appColors
                                          .userProfileTextColor
                                      : Colors.grey,
                                ),
                            Text(
                              ' Like',
                              style: TextStyle(
                                color: feedType == FeedType.user
                                    ? Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .userProfileTextColor
                                    : Colors.grey,
                                fontSize: feedReactionCountSize,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
