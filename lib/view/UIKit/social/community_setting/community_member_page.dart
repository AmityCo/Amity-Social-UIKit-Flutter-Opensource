import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/social/select_user_page.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_member_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberManagementPage extends StatefulWidget {
  final String communityId;

  const MemberManagementPage({
    Key? key,
    required this.communityId,
  }) : super(key: key);

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<MemberManagementVM>(context, listen: false).initMember(
        communityId: widget.communityId,
      );
      Provider.of<MemberManagementVM>(context, listen: false).initModerators(
        communityId: widget.communityId,
      );
      Provider.of<MemberManagementVM>(context, listen: false)
          .checkCurrentUserRole(widget.communityId);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                var userList =
                    Provider.of<MemberManagementVM>(context, listen: false)
                        .userList;
                List<AmityUser> userIdList =
                    userList.map((user) => user.user!).toList();
                Navigator.of(context).push<List<AmityUser>>(MaterialPageRoute(
                    builder: (context) => UserListPage(
                          preSelectMember: userIdList,
                          onDonePressed: (users) async {
                            List<String> userIds =
                                users.map((user) => user.userId!).toList();
                            if (users.isNotEmpty) {
                              await Provider.of<CommunityVM>(context,
                                      listen: false)
                                  .addMembers(widget.communityId, userIds);
                              await Provider.of<MemberManagementVM>(context,
                                      listen: false)
                                  .initMember(
                                communityId: widget.communityId,
                              );
                              await Provider.of<MemberManagementVM>(context,
                                      listen: false)
                                  .initModerators(
                                communityId: widget.communityId,
                              );
                              Navigator.of(context).pop();
                            } else {
                              log('Failed to add members');
                            }
                          },
                        )));
              },
            ),
          ],
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text("Community",
              style: Provider.of<AmityUIConfiguration>(context).titleTextStyle),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(
                48.0), // Provide a height for the AppBar's bottom
            child: Row(
              children: [
                TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true, // Ensure that the TabBar is scrollable

                  labelColor: Color(0xFF1054DE), // #1054DE color
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF1054DE),
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Text',
                  ),

                  tabs: [
                    Tab(text: "Members"),
                    Tab(text: "Moderators"),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            MemberList(), // You need to create a MemberList widget
            ModeratorList(), // You need to create a ModeratorList widget
          ],
        ),
      ),
    );
  }
}
// Import statements remain the same

class MemberList extends StatelessWidget {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberManagementVM>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          controller: viewModel.scrollController,
          itemCount: viewModel.userList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => UserFeedVM(),
                        child: UserProfileScreen(
                          amityUser: viewModel.userList[index].user!,
                          amityUserId: viewModel.userList[index].user!.userId!,
                        ))));
              },
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD9E5FC),
                backgroundImage: viewModel.userList[index].user?.avatarUrl ==
                        null
                    ? null
                    : NetworkImage(viewModel.userList[index].user!.avatarUrl!),
                child: viewModel.userList[index].user?.avatarUrl != null
                    ? null
                    : const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              title: Text(
                viewModel.userList[index].user?.displayName ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showOptionsBottomSheet(
                      context, viewModel.userList[index], viewModel,
                      showDemoteButton: false);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class ModeratorList extends StatelessWidget {
  const ModeratorList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberManagementVM>(
      builder: (context, viewModel, child) {
        return ListView.builder(
          itemCount: viewModel.moderatorList.length,
          controller: viewModel.scrollControllerForModerator,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                        create: (context) => UserFeedVM(),
                        child: UserProfileScreen(
                          amityUser: viewModel.moderatorList[index].user!,
                          amityUserId: viewModel.userList[index].user!.userId!,
                        ))));
              },
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD9E5FC),
                backgroundImage:
                    viewModel.moderatorList[index].user?.avatarUrl == null
                        ? null
                        : NetworkImage(
                            viewModel.moderatorList[index].user!.avatarUrl!),
                child: viewModel.moderatorList[index].user?.avatarUrl != null
                    ? null
                    : const Icon(Icons.person,
                        size: 20,
                        color: Colors
                            .white), // Adjust to use the correct attribute for avatar URL
              ),
              title: Text(
                viewModel.moderatorList[index].user?.displayName ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.black,
                ),
                onPressed: () {
                  _showOptionsBottomSheet(
                      context, viewModel.moderatorList[index], viewModel);
                },
              ),
            );
          },
        );
      },
    );
  }
}

void _showOptionsBottomSheet(BuildContext context, AmityCommunityMember member,
    MemberManagementVM viewModel,
    {bool showDemoteButton = true}) {
  bool isModerator = viewModel.currentUserRoles.contains('community-moderator');

  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Wrap(
            children: isModerator
                ? [
                    member.roles!.contains('community-moderator') &
                            !showDemoteButton
                        ? const SizedBox()
                        : ListTile(
                            title: Text(
                              member.roles!.contains('community-moderator')
                                  ? 'Dismiss moderator'
                                  : 'Promote to moderator',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              if (member.roles!
                                  .contains('community-moderator')) {
                                await viewModel.demoteFromModerator(
                                    viewModel.communityId, [member.userId!]);
                              } else {
                                await viewModel.promoteToModerator(
                                    viewModel.communityId, [member.userId!]);
                              }
                              await viewModel.initModerators(
                                  communityId: viewModel.communityId);
                              await viewModel.initMember(
                                communityId: viewModel.communityId,
                              );
                            },
                          ),
                    ListTile(
                      title: Text(
                        member.user!.isFlaggedByMe ? "Undo Report" : "Report",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () async {
                        if (member.user!.isFlaggedByMe) {
                          await viewModel.undoReportUser(member.user!);
                        } else {
                          await viewModel.reportUser(member.user!);
                        }
                        await viewModel.initModerators(
                            communityId: viewModel.communityId);
                        await viewModel.initMember(
                          communityId: viewModel.communityId,
                        );
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Block User',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        viewModel.blockUser(member.user!);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Remove from community',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await ConfirmationDialog().show(
                          context: context,
                          title: 'Remove user from Community?',
                          detailText:
                              "This user won't no longer be able to search, post and interact in this community",
                          onConfirm: () {
                            viewModel.removeMembers(
                                viewModel.communityId, [member.userId!]);
                          },
                        );
                        await viewModel.initModerators(
                            communityId: viewModel.communityId);
                        await viewModel.initMember(
                          communityId: viewModel.communityId,
                        );
                      },
                    ),
                  ]
                : [
                    ListTile(
                      title: const Text(
                        'Block User',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        viewModel.blockUser(member.user!);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'Report',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        viewModel.reportUser(member.user!);
                        Navigator.pop(context);
                      },
                    ),
                  ],
          ),
        );
      });
}
