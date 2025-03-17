import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/Skeleton/user_skeleton_list.dart';
import 'package:amity_uikit_beta_service/v4/core/user_avatar.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/pending_requests/bloc/user_pending_follow_requests_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityUserPendingFollowRequestsPage extends NewBasePage {
  // User Profile Page determines pending requests count using FollowInfo object which is not a live object.
  // So we need to refetch pending requests count in Profile page, when we perform accept / decline action in this page.
  final Function? actionCallback;

  AmityUserPendingFollowRequestsPage({super.key, this.actionCallback})
      : super(pageId: 'user_pending_follow_request_page');

  final scrollController = ScrollController();

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPendingFollowRequestsBloc(),
      child: BlocBuilder<UserPendingFollowRequestsBloc,
          UserPendingFollowRequestsState>(
        builder: (context, state) {
          // Pagination
          scrollController.addListener(() {
            if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
              context
                  .read<UserPendingFollowRequestsBloc>()
                  .addEvent(UserPendingFollowRequestsLoadNextPage());
            }
          });

          return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("Follow requests (${state.users.length})",
                    style: AmityTextStyle.titleBold(theme.baseColor)),
                backgroundColor: theme.backgroundColor,
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: theme.baseColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              backgroundColor: theme.backgroundColor,
              body: Container(
                color: theme.backgroundColor,
                child: Column(
                  children: [
                    Container(
                      color: theme.backgroundShade1Color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                            "Declining a follow request is irreversible. The user must send a new request if declined.",
                            style:
                                AmityTextStyle.caption(theme.baseColorShade1)),
                      ),
                    ),
                    if (state.isLoading && state.users.isEmpty) ...[
                      Expanded(
                        child: UserSkeletonLoadingView(
                          itemCount: 8,
                        ),
                      ),
                    ] else if (!state.isLoading && state.users.isEmpty) ...[
                      getEmptyStateView(
                        theme,
                      )
                    ] else ...[
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: state.users.length,
                          itemBuilder: (context, index) {
                            return PendingRequestItem(
                                user: state.users[index],
                                actionCallback: () {
                                  actionCallback?.call();
                                });
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              ));
        },
      ),
    );
  }
}

Widget getEmptyStateView(AmityThemeColor theme) {
  return Expanded(
    child: Container(
      height: 400,
      color: theme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_follow_request_empty.svg',
            package: 'amity_uikit_beta_service',
          ),
          const SizedBox(height: 16),
          Text(
            'No requests to review',
            textAlign: TextAlign.center,
            style: AmityTextStyle.titleBold(theme.baseColorShade3),
          ),
        ],
      ),
    ),
  );
}

class PendingRequestItem extends BaseElement {
  final AmityFollowRelationship user;
  final Function actionCallback;

  PendingRequestItem(
      {Key? key,
      String? pageId,
      String? componentId,
      required this.user,
      required this.actionCallback})
      : super(
          key: key,
          pageId: pageId,
          componentId: componentId,
          elementId: "pending_request_item",
        );

  @override
  Widget buildElement(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return AmityUserProfilePage(
                        userId: user.sourceUserId ?? "");
                  },
                ));
              },
              child: Row(
                children: [
                  AmityUserAvatar(
                      avatarUrl: user.sourceUser?.avatarUrl,
                      displayName: user.sourceUser?.displayName ?? "",
                      isDeletedUser: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.sourceUser?.displayName ?? "",
                      style: AmityTextStyle.titleBold(theme.baseColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 0,
                      right: 0,
                      bottom: 10,
                    ),
                    decoration: ShapeDecoration(
                      color: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                          child: Text(
                        "Accept",
                        style: AmityTextStyle.bodyBold(Colors.white),
                      )),
                      onTap: () {
                        final followRequestsBloc =
                            context.read<UserPendingFollowRequestsBloc>();
                        final toastBloc = context.read<AmityToastBloc>();
                        followRequestsBloc.addEvent(
                          UserPendingFollowRequestsActionEvent(
                              action: UserPendingFollowRequestsAction.accept,
                              user: user.sourceUser!,
                              toastBloc: toastBloc,
                              callback: actionCallback),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 0,
                      right: 0,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.secondaryColor
                              .blend(ColorBlendingOption.shade3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: Text(
                          "Decline",
                          style: AmityTextStyle.bodyBold(
                            theme.secondaryColor,
                          ),
                        ),
                      ),
                      onTap: () {
                        final followRequestsBloc =
                            context.read<UserPendingFollowRequestsBloc>();
                        final toastBloc = context.read<AmityToastBloc>();

                        followRequestsBloc.addEvent(
                          UserPendingFollowRequestsActionEvent(
                              action: UserPendingFollowRequestsAction.decline,
                              user: user.sourceUser,
                              toastBloc: toastBloc,
                              callback: actionCallback),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Container(
            width: double.infinity,
            height: 8,
            color: theme.baseColorShade4,
          )
        ],
      ),
    );
  }
}
