import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget multiSelectUserList(
    {required BuildContext context,
    required ScrollController scrollController,
    required List<AmityUser> users,
    required List<AmityUser> selectedUsers,
    required AmityThemeColor theme,
    required void Function() loadMore,
    required void Function(AmityUser) onSelectUser,
    bool excludeCurrentUser = false,
    bool isLoadingMore = false}) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Column(children: [
      Expanded(
        child: ListView.separated(
          controller: scrollController,
          itemCount: users.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 4);
          },
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom
            if (index == users.length && isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
              );
            }

            final user = users[index];
            final currentUserId = AmityCoreClient.getUserId();
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0.0 : 0.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!excludeCurrentUser || user.userId != currentUserId)
                      multiSelectUserRow(
                        context,
                        user,
                        theme,
                        selectedUsers.any((selectedUser) =>
                            selectedUser.userId == user.userId),
                        onSelectUser,
                      ),
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

Widget userList(
    {required BuildContext context,
    required ScrollController scrollController,
    required List<AmityUser> users,
    required AmityThemeColor theme,
    required void Function() loadMore,
    required void Function(AmityUser) onTap,
    void Function(AmityUser)? onActionTap,
    bool excludeCurrentUser = false,
    bool hideActionForCurrentUser = false,
    Map<String, List<String>>? memberRoles,
    bool isLoadingMore = false}) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Column(children: [
      Expanded(
        child: ListView.separated(
          controller: scrollController,
          itemCount: users.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 4);
          },
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom
            if (index == users.length && isLoadingMore) {
              return Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
              );
            }

            
            final user = users[index];
            final currentUserId = AmityCoreClient.getUserId();
            final isCurrentUser = user.userId == currentUserId;
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0.0 : 0.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!excludeCurrentUser || !isCurrentUser)
                      userRow(
                        context,
                        user,
                        theme,
                        onTap,
                        onActionTap: hideActionForCurrentUser && isCurrentUser
                            ? null
                            : onActionTap,
                        memberRoles: memberRoles,
                      ),
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

// Custom user list that handles "(You)" display for current user
Widget groupUserList({
  required BuildContext context,
  required ScrollController scrollController,
  required List<AmityUser> users,
  required AmityThemeColor theme,
  required Map<String, List<String>>? memberRoles,
  required String? currentUserId,
  required VoidCallback loadMore,
  required void Function(AmityUser) onTap,
  required bool excludeCurrentUser,
  required void Function(AmityUser)? onActionTap,
  required bool hideActionForCurrentUser,
  required bool isCurrentUserModerator,
  Map<String, bool>? mutedUsers,  
  bool isLoadingMoreMember = false,
}) {
  return NotificationListener<ScrollNotification>(
    onNotification: (ScrollNotification scrollInfo) {
      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
        loadMore();
      }
      return false;
    },
    child: ListView.builder(
      controller: scrollController,
      itemCount: users.length + (isLoadingMoreMember ? 1 : 0), // Add loading item count
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index == users.length && isLoadingMoreMember) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
          );
        }

        final user = users[index];
        final isCurrentUser = user.userId == currentUserId;

        return _groupUserRow(
          context: context,
          user: user,
          theme: theme,
          isCurrentUser: isCurrentUser,
          memberRoles: memberRoles,
          mutedUsers: mutedUsers,
          onTap: onTap,
          onActionTap: (hideActionForCurrentUser && isCurrentUser)
              ? null
              : onActionTap,
          isCurrentUserModerator: isCurrentUserModerator,
        );
      },
    ),
  );
}

// Custom user row that handles display name with "(You)" and truncation
Widget _groupUserRow({
  required BuildContext context,
  required AmityUser user,
  required AmityThemeColor theme,
  required bool isCurrentUser,
  required Map<String, List<String>>? memberRoles,
  Map<String, bool>? mutedUsers,
  required void Function(AmityUser) onTap,
  required void Function(AmityUser)? onActionTap,
  required bool isCurrentUserModerator,
}) {
  return GestureDetector(
    onTap: () => onTap(user),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 0),
          _avatarImage(user, theme, memberRoles: memberRoles),
          const SizedBox(width: 8),
          _groupDisplayNameWithBrandIcon(user, theme, isCurrentUser, mutedUsers, isCurrentUserModerator),
          if (onActionTap != null)
            IconButton(
              icon: SvgPicture.asset(
                'assets/Icons/amity_ic_three_dot_horizontal.svg',
                package: 'amity_uikit_beta_service',
                color: theme.baseColor,
              ),
              onPressed: () => onActionTap(user),
              splashRadius: 20,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

// Custom display name that handles "(You)" and text truncation
Widget _groupDisplayNameWithBrandIcon(
    AmityUser user, AmityThemeColor theme, bool isCurrentUser, Map<String, bool>? mutedUsers, bool isCurrentUserModerator) {
  return Expanded(
    child: Row(
      children: [
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              String displayName = user.displayName ?? "";
              String fullText =
                  isCurrentUser ? "$displayName${context.l10n.user_list_you_suffix}" : displayName;

              // Calculate available width (subtract brand icon width if needed)
              double availableWidth = constraints.maxWidth;
              if (user.isBrand ?? false) {
                availableWidth -= 22; // Brand icon width + padding
              }
              if (mutedUsers?[user.userId] == true && isCurrentUserModerator) {
                availableWidth -= 20; // Muted icon width + padding
              }

              // Create TextPainter to measure text
              final textPainter = TextPainter(
                text: TextSpan(
                  text: fullText,
                  style: AmityTextStyle.bodyBold(theme.baseColor),
                ),
                maxLines: 1,
                textDirection: TextDirection.ltr,
              );
              textPainter.layout(maxWidth: availableWidth);

              String finalText = fullText;

              // If text overflows, truncate the display name and add "(You)"
              if (textPainter.didExceedMaxLines ||
                  textPainter.width > availableWidth) {
                if (isCurrentUser) {
                  // Calculate how much space we need for the you suffix
                  final youTextPainter = TextPainter(
                    text: TextSpan(
                      text: context.l10n.user_list_you_suffix,
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                    textDirection: TextDirection.ltr,
                  );
                  youTextPainter.layout();

                  // Calculate available width for the display name
                  double nameWidth = availableWidth - youTextPainter.width;

                  // Create TextPainter for just the display name to find truncation point
                  final nameTextPainter = TextPainter(
                    text: TextSpan(
                      text: displayName,
                      style: AmityTextStyle.bodyBold(theme.baseColor),
                    ),
                    textDirection: TextDirection.ltr,
                  );
                  nameTextPainter.layout(maxWidth: nameWidth);

                  if (nameTextPainter.didExceedMaxLines ||
                      nameTextPainter.width > nameWidth) {
                    // Find the truncation point
                    int truncateAt = displayName.length;
                    while (truncateAt > 0) {
                      String truncated =
                          "${displayName.substring(0, truncateAt)}...";
                      final testPainter = TextPainter(
                        text: TextSpan(
                          text: truncated,
                          style: AmityTextStyle.bodyBold(theme.baseColor),
                        ),
                        textDirection: TextDirection.ltr,
                      );
                      testPainter.layout();

                      if (testPainter.width <= nameWidth) {
                        finalText = "$truncated${context.l10n.user_list_you_suffix}";
                        break;
                      }
                      truncateAt--;
                    }

                    // Fallback if name is too short
                    if (truncateAt <= 1) {
                      finalText = "...${context.l10n.user_list_you_suffix}";
                    }
                  }
                } else {
                  // For non-current users, just truncate normally
                  finalText = displayName;
                }
              }

              return Text(
                finalText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AmityTextStyle.bodyBold(theme.baseColor),
              );
            },
          ),
        ),
        if (user.isBrand ?? false) _brandBadge(),
        if (mutedUsers?[user.userId] == true && isCurrentUserModerator) _mutedIcon(),
      ],
    ),
  );
}

// Copy of avatarImage function from user_list.dart
Widget _avatarImage(AmityUser user, AmityThemeColor theme,
    {Map<String, List<String>>? memberRoles}) {
  // Check if user is a moderator
  final userRoles = memberRoles?[user.userId] ?? [];
  final isModerator = userRoles.contains('channel-moderator') ||
      userRoles.contains('moderator');

  return Container(
    padding: const EdgeInsets.all(4),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            width: 40,
            height: 40,
            child: AmityUserImage(user: user, theme: theme, size: 40),
          ),
        ),
        if (isModerator)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.blend(ColorBlendingOption.shade3),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_community_moderator.svg',
                  package: 'amity_uikit_beta_service',
                  width: 12,
                  height: 12,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// Copy of brandBadge function
Widget _brandBadge() {
  return Container(
    padding: const EdgeInsets.only(left: 4),
    child: SvgPicture.asset(
      'assets/Icons/amity_ic_brand.svg',
      package: 'amity_uikit_beta_service',
      fit: BoxFit.fill,
      width: 18,
      height: 18,
    ),
  );
}

// Muted icon for muted users
Widget _mutedIcon() {
  return Container(
    padding: const EdgeInsets.only(left: 2),
    child: SvgPicture.asset(
      'assets/Icons/amity_ic_group_chat_muted_member.svg',
      package: 'amity_uikit_beta_service',
      fit: BoxFit.fill,
      width: 18,
      height: 18,
    ),
  );
}

Widget horizontalUserList(
    {required BuildContext context,
    required ScrollController scrollController,
    required List<AmityUser> users,
    required AmityThemeColor theme,
    required void Function() loadMore,
    required void Function(AmityUser) onTap,
    bool excludeCurrentUser = false}) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      itemCount: users.length,
      separatorBuilder: (context, index) {
        return const SizedBox(width: 4);
      },
      itemBuilder: (context, index) {
        final user = users[index];
        final currentUserId = AmityCoreClient.getUserId();
        if (excludeCurrentUser && user.userId == currentUserId) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 0.0,
              right: index == users.length - 1 ? 16.0 : 0.0),
          child: horizontalUserItem(context, user, theme, onTap: onTap),
        );
      },
    ),
  );
}

Widget gridUserList(
    {required BuildContext context,
    required ScrollController scrollController,
    required List<AmityUser> users,
    required AmityThemeColor theme,
    required void Function() loadMore,
    required void Function(AmityUser) onTap,
    Function()? onAddTap,
    bool excludeCurrentUser = false}) {
  scrollController.addListener(() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMore();
    }
  });

  // Show all users instead of limiting to 4 rows
  final visibleUsers = users;

  // Calculate total item count including special items
  final hasAddButton = onAddTap != null;
  final hasCurrentUser = !excludeCurrentUser;
  final specialItemCount = (hasAddButton ? 1 : 0) + (hasCurrentUser ? 1 : 0);
  final totalItemCount = visibleUsers.length + specialItemCount;
  final currentUserId = AmityCoreClient.getUserId();

  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 19.0,
        childAspectRatio: 0.85,
      ),
      controller: scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalItemCount,
      itemBuilder: (context, index) {
        if (hasAddButton && index == 0) {
          return addUserItem(context, theme, onAddTap);
        }

        // Current user is the second item (or first if no add button)
        if (hasCurrentUser && index == (hasAddButton ? 1 : 0)) {
          return FutureBuilder<AmityUser?>(
            future: Future.value(AmityCoreClient.getCurrentUser()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                return horizontalUserItem(context, snapshot.data!, theme,
                    isCurrentUser: snapshot.data!.userId == currentUserId,
                    onTap: (_) {
                  // Do nothing when tapping on current user
                });
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        }

        // Adjust index to account for special items
        final adjustedIndex = index - specialItemCount;
        if (adjustedIndex < 0 || adjustedIndex >= visibleUsers.length) {
          return const SizedBox.shrink();
        }

        // Regular user item
        final user = visibleUsers[adjustedIndex];
        return horizontalUserItem(context, user, theme, onTap: onTap);
      },
    ),
  );
}

Widget addUserItem(
    BuildContext context, AmityThemeColor theme, Function() onTap) {
  return Container(
    width: 64,
    height: 75, // Increased from 62 to match horizontalUserItem
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 8),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.baseColorShade4,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/Icons/amity_ic_create_group_add_member_button.svg',
                        package: 'amity_uikit_beta_service',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Container(
                    width:
                        64, // Set a fixed width to ensure alignment consistency
                    alignment: Alignment.center, // Center the text horizontally
                    child: Text(
                      context.l10n.user_list_add,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: AmityTextStyle.caption(theme.baseColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget horizontalUserItem(
    BuildContext context, AmityUser user, AmityThemeColor theme,
    {bool isCurrentUser = false, required void Function(AmityUser) onTap}) {
  return Container(
    width: 64,
    height: 75,
    child: Container(
      padding: const EdgeInsets.only(top: 12, left: 0, right: 0, bottom: 8),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            AmityUserImage(user: user, theme: theme, size: 40),
                      ),
                    ),
                    // Only show close button if it's not the current user
                    if (!isCurrentUser)
                      Positioned(
                        top: -1,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            onTap(user);
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    if (isCurrentUser)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primaryColor
                                  .blend(ColorBlendingOption.shade3),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/Icons/amity_ic_community_moderator.svg',
                                package: 'amity_uikit_beta_service',
                                width: 12,
                                height: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Container(
                  width:
                      64, // Set a fixed width to ensure alignment consistency
                  alignment: Alignment.center, // Center the row horizontally
                  child: Text(
                    isCurrentUser ? context.l10n.user_list_you : user.displayName ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: AmityTextStyle.caption(theme.baseColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget userRow(BuildContext context, AmityUser user, AmityThemeColor theme,
    void Function(AmityUser) onTap,
    {void Function(AmityUser)? onActionTap,
    Map<String, List<String>>? memberRoles}) {
  return GestureDetector(
    onTap: () {
      onTap(user);
    },
    child: SizedBox(
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          avatarImage(user, theme, memberRoles: memberRoles),
          const SizedBox(width: 8),
          displayNameWithBrandIcon(user, theme),
          if (onActionTap != null)
            IconButton(
              icon: SvgPicture.asset(
                'assets/Icons/amity_ic_three_dot_horizontal.svg',
                package: 'amity_uikit_beta_service',
                color: theme.baseColor,
                width: 24,
                height: 24,
              ),
              onPressed: () => onActionTap(user),
              splashRadius: 20,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

Widget multiSelectUserRow(BuildContext context, AmityUser user,
    AmityThemeColor theme, bool isSelected, void Function(AmityUser) onTap) {
  return GestureDetector(
    onTap: () {
      onTap(user);
    },
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      height: 56,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          avatarImage(user, theme),
          const SizedBox(width: 8),
          displayNameWithBrandIcon(user, theme),
          Checkbox(
            value: isSelected,
            onChanged: (_) => onTap(user),
            activeColor: theme.primaryColor,
            shape: const CircleBorder(),
            side: BorderSide(color: theme.baseColorShade3, width: 2),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

Widget avatarImage(AmityUser user, AmityThemeColor theme,
    {Map<String, List<String>>? memberRoles}) {
  // Check if user is a moderator
  final userRoles = memberRoles?[user.userId] ?? [];
  final isModerator = userRoles.contains('channel-moderator') ||
      userRoles.contains('community-moderator') ||
      userRoles.contains('moderator');

  return Container(
    padding: const EdgeInsets.all(4),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            width: 40,
            height: 40,
            child: AmityUserImage(user: user, theme: theme, size: 40),
          ),
        ),
        if (isModerator)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.blend(ColorBlendingOption.shade3),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_community_moderator.svg',
                  package: 'amity_uikit_beta_service',
                  width: 12,
                  height: 12,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

Widget displayName(String displayName, AmityThemeColor theme) {
  return Expanded(
    child: Text(
      overflow: TextOverflow.ellipsis,
      displayName,
      maxLines: 1,
      style: AmityTextStyle.bodyBold(theme.baseColor),
    ),
  );
}

Widget displayNameWithBrandIcon(AmityUser user, AmityThemeColor theme) {
  return Expanded(
    child: Row(
      children: [
        Flexible(
          child: Text(
            user.displayName ?? "",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AmityTextStyle.bodyBold(theme.baseColor),
          ),
        ),
        if (user.isBrand ?? false) brandBadge(),
      ],
    ),
  );
}

Widget userSkeletonList(AmityThemeColor theme, ConfigProvider configProvider,
    {int itemCount = 5}) {
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            child: Shimmer(
              linearGradient: configProvider.getShimmerGradient(),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return skeletonItem();
                },
              ),
            ),
          ),
        ),
      ],
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
            padding:
                const EdgeInsets.only(top: 8, left: 16, right: 12, bottom: 8),
            child: const SkeletonImage(
              height: 40,
              width: 40,
              borderRadius: 40,
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 140, height: 10),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget brandBadge() {
  return Container(
    padding: const EdgeInsets.only(left: 4),
    child: SvgPicture.asset(
      'assets/Icons/amity_ic_brand.svg',
      package: 'amity_uikit_beta_service',
      fit: BoxFit.fill,
      width: 18,
      height: 18,
    ),
  );
}
