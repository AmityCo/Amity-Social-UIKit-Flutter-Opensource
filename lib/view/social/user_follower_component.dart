import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/follower_following_viewmodel.dart';

class AmityFollowerScreen extends StatefulWidget {
  final String userId;
  const AmityFollowerScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AmityFollowerScreen> createState() => _AmityFollowerScreenState();
}

class _AmityFollowerScreenState extends State<AmityFollowerScreen> {
  @override
  void initState() {
    Provider.of<FollowerVM>(context, listen: false)
        .getFollowerListOf(userId: widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowerVM>(builder: (context, vm, _) {
      final theme = Theme.of(context);
      return FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: RefreshIndicator(
          onRefresh: () async {
            await vm.getFollowerListOf(userId: widget.userId);
          },
          child: vm.getFollowerList.isEmpty
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Provider.of<AmityUIConfiguration>(context)
                                .primaryColor,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: vm.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vm.getFollowerList.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder<AmityFollowRelationship>(
                        // key: Key(vm.getFollowRelationships[index].sourceUserId! +
                        //     vm.getFollowRelationships[index].targetUserId!),
                        stream: vm.getFollowerList[index].listen.stream,
                        initialData: vm.getFollowerList[index],
                        builder: (context, snapshot) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                getAvatarImage(vm.getFollowerList[index]
                                    .sourceUser!.avatarUrl),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vm.getFollowerList[index].sourceUser!
                                                .displayName ??
                                            "displayname not found",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        vm.getFollowerList[index].sourceUser!
                                                .userId ??
                                            "displayname not found",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                          // return Text(snapshot.data!.status.toString());
                        });
                  },
                ),
        ),
      );
    });
  }
}
