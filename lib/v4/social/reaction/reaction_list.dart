import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/bloc/reaction_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AmityReactionList extends NewBaseComponent {
  final String referenceId;
  final AmityReactionReferenceType referenceType;
  late int? reactionCount = 0;

  // State tracking variables
  int _selectedTabIndex = 0;
  String? _currentReactionFilter;
  String? _userReactionName;
  AmityReaction? _userReaction;

  AmityReactionList({
    Key? key,
    String? pageId,
    required this.referenceId,
    required this.referenceType,
  }) : super(key: key, pageId: pageId, componentId: 'reactions_component');

  @override
  Widget buildComponent(BuildContext context) {
    // Initialize user reaction data for messages if needed
    if (referenceType == AmityReactionReferenceType.MESSAGE) {
      _initUserReactionData();
    }

    return BlocProvider(
      create: (context) => ReactionListBloc(
          referenceId: referenceId, referenceType: referenceType),
      child: Builder(
        builder: (context) {
          // Initialize the bloc
          context.read<ReactionListBloc>().add(ReactionListEventInit());

          return BlocBuilder<ReactionListBloc, ReactionListState>(
            builder: (context, state) => _buildStateBasedView(context, state),
          );
        },
      ),
    );
  }

  // Central method to handle different UI states
  Widget _buildStateBasedView(BuildContext context, ReactionListState state) {
    // Update reaction count when available
    if (state is ReactionListLoaded) {
      reactionCount = state.list.length;
    } else if (state is ReactionListFiltering) {
      reactionCount = state.previousList.length;
    }

    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor),
      child: Column(
        children: [
          bottomSheetHandle(),
          _buildReactionTabs(state is ReactionListLoaded ||
                  state is ReactionListFiltering ||
                  (state is ReactionListLoading && state.reactionMap != null)
              ? state.reactionMap
              : null),
          _buildDivider(),
          Expanded(
            child: _buildListBasedOnState(context, state),
          ),
        ],
      ),
    );
  }

  // Build appropriate list view based on state
  Widget _buildListBasedOnState(BuildContext context, ReactionListState state) {
    if (state is ReactionListLoaded) {
      return _buildReactionListView(context, state.list);
    } else if (state is ReactionListFiltering ||
        (state is ReactionListLoading && state.reactionMap != null)) {
      final skeletonCount = _calculateItemCount(state.reactionMap);
      return buildSkeletonListView(itemCount: skeletonCount);
    } else {
      return buildSkeletonListView(itemCount: 3);
    }
  }

  // Initialize user reaction data for messages
  Future<void> _initUserReactionData() async {
    try {
      final message =
          await AmityChatClient.newMessageRepository().getMessage(referenceId);
      final userReactions = message.myReactions;
      _userReactionName = (userReactions != null && userReactions.isNotEmpty)
          ? userReactions.first
          : null;
    } catch (e) {
      debugPrint('Error fetching message for user reaction: $e');
    }
  }

  // Calculate item count for lists
  int _calculateItemCount(Map<String, int>? reactionMap) {
    if (reactionMap == null) return 3;

    if (_currentReactionFilter == null) {
      return reactionMap.values.fold(0, (sum, count) => sum + count);
    }

    return reactionMap[_currentReactionFilter!] ?? 3;
  }

  // Build the reaction list view with optional user reaction at top
  Widget _buildReactionListView(
      BuildContext context, List<AmityReaction> reactions) {
    final ScrollController scrollController = ScrollController();

    // Find user's reaction and prepare data for display
    final userReactionToShow = _getUserReaction(reactions);

    // Filter list to exclude user's reaction if showing separately
    final filteredList = userReactionToShow != null
        ? reactions.where((r) => r != userReactionToShow).toList()
        : reactions;

    // Setup scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        context.read<ReactionListBloc>().add(ReactionListEventLoadMore());
      }
    });

    return ListView.builder(
      controller: scrollController,
      itemCount: (userReactionToShow != null ? 1 : 0) + filteredList.length,
      itemBuilder: (context, index) {
        if (index == 0 && userReactionToShow != null) {
          return reactionRow(context, userReactionToShow);
        } else {
          final actualIndex = userReactionToShow != null ? index - 1 : index;
          return reactionRow(context, filteredList[actualIndex]);
        }
      },
    );
  }

  // Get user's reaction if it should be shown
  AmityReaction? _getUserReaction(List<AmityReaction> reactions) {
    // Only show user reaction if current filter allows it
    if (!_shouldShowUserReaction(
        filter: _currentReactionFilter, userReaction: _userReactionName)) {
      return null;
    }

    // Find user reaction in the list
    if (_userReactionName != null && _userReactionName!.isNotEmpty) {
      _userReaction = reactions.firstWhere(
        (reaction) =>
            reaction.creator?.userId == AmityCoreClient.getUserId() &&
            reaction.reactionName == _userReactionName,
        orElse: () => AmityReaction(),
      );

      return _userReaction;
    }

    return null;
  }

  // Determine if user's reaction should be shown at top
  bool _shouldShowUserReaction({String? filter, String? userReaction}) {
    return filter == null || filter == userReaction;
  }

  // Build a divider line
  Widget _buildDivider() {
    return Divider(
      color: theme.baseColorShade4,
      thickness: 0.5,
      height: 0,
    );
  }

  // Bottom sheet handle bar
  Widget bottomSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 15),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: theme.baseColorShade3,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Build reaction tabs based on reaction map
  Widget _buildReactionTabs(Map<String, int>? reactionMap) {
    if (reactionMap == null) {
      return Container();
    }

    if (reactionMap.isNotEmpty) {
      return _buildMessageReactionTabs(reactionMap);
    } else if ((referenceType == AmityReactionReferenceType.POST ||
            referenceType == AmityReactionReferenceType.COMMENT) &&
        reactionCount != null) {
      return _buildPostCommentReactionTab();
    }

    return Container();
  }

  // Build reaction tabs for messages
  Widget _buildMessageReactionTabs(Map<String, int> reactionMap) {
    final tabsData = _generateTabsData(reactionMap);

    // Reset index if out of bounds
    if (_selectedTabIndex >= tabsData.length) {
      _selectedTabIndex = 0;
    }

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        color: theme.backgroundColor,
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
                tabsData.length,
                (index) =>
                    _buildTabItem(context, setState, tabsData[index], index)),
          ),
        ),
      );
    });
  }

  // Build individual tab item
  Widget _buildTabItem(BuildContext context, StateSetter setState,
      Map<String, dynamic> tabData, int index) {
    final bool isSelected = _selectedTabIndex == index;
    final textColor = isSelected ? theme.primaryColor : theme.baseColorShade2;
    final tabTextStyle = AmityTextStyle.titleBold(textColor);

    final String displayText = tabData['type'] == 'all'
        ? "All ${tabData['count']}"
        : "${tabData['count']}";

    final contentWidth =
        _calculateTabWidth(displayText, tabData['imagePath'], tabTextStyle);

    return GestureDetector(
      onTap: () =>
          _handleTabTap(context, setState, index, tabData['reactionName']),
      child: Container(
        padding: EdgeInsets.only(
          left: index == 0 ? 16 : 10,
          right: 10,
          top: 16,
        ),
        child: Column(
          children: [
            // Tab content
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tabData['imagePath'] != null) ...[
                  SvgPicture.asset(
                    tabData['imagePath'],
                    package: 'amity_uikit_beta_service',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(displayText, style: tabTextStyle),
              ],
            ),
            const SizedBox(height: 8),
            // Indicator bar
            Container(
              height: 2,
              width: contentWidth,
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle tab tap
  void _handleTabTap(BuildContext context, StateSetter setState, int index,
      String? reactionName) {
    setState(() {
      _selectedTabIndex = index;
    });

    _currentReactionFilter = reactionName;
    context
        .read<ReactionListBloc>()
        .add(ReactionListEventFilterByName(reactionName));
  }

  // Generate tabs data from reaction map
  List<Map<String, dynamic>> _generateTabsData(Map<String, int> reactionMap) {
    List<Map<String, dynamic>> tabsData = [];
    List<Map<String, dynamic>> reactionTabs = [];

    // Create individual reaction tabs
    reactionMap.forEach((reactionName, count) {
      final reactionConfig = configProvider.getReaction(reactionName);

      reactionTabs.add({
        'type': 'reaction',
        'count': count,
        'name': reactionName,
        'imagePath': reactionConfig.imagePath,
        'reactionName': reactionName,
      });
    });

    // Sort by count (highest to lowest)
    reactionTabs
        .sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    // Add "All" tab if multiple reactions
    if (reactionMap.length > 1) {
      final totalCount = reactionMap.values.reduce((a, b) => a + b);
      tabsData.add({
        'type': 'all',
        'count': totalCount,
        'name': 'All',
        'imagePath': null,
        'reactionName': null,
      });
    }

    tabsData.addAll(reactionTabs);
    return tabsData;
  }

  // Calculate tab width for proper layout
  double _calculateTabWidth(String text, String? imagePath, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width + (imagePath != null ? 28 : 0);
  }

  // Build reaction tab for posts/comments
  Widget _buildPostCommentReactionTab() {
    final String countText = "${reactionCount?.formattedCompactString()}";
    final likeReaction = configProvider.getReaction("like");

    return Container(
      color: theme.backgroundColor,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  likeReaction.imagePath,
                  package: 'amity_uikit_beta_service',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  countText,
                  style: AmityTextStyle.titleBold(theme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: _calculateTabWidth(countText, likeReaction.imagePath,
                      AmityTextStyle.titleBold(theme.primaryColor)) +
                  28,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build skeleton list view with item count limit
  Widget buildSkeletonListView({int? itemCount}) {
    final int count = (itemCount ?? reactionCount ?? 3).clamp(0, 5);

    return Container(
      alignment: Alignment.topCenter,
      child: Shimmer(
        linearGradient: configProvider.getShimmerGradient(),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(count, (_) => skeletonItem()),
        ),
      ),
    );
  }

  // Individual skeleton item
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
              width: 64,
              height: 56,
              padding:
                  const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
              child: const SkeletonImage(
                height: 40,
                width: 40,
                borderRadius: 40,
              ),
            ),
            const SkeletonText(width: 180),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // Builds a single reaction row
  Widget reactionRow(BuildContext context, AmityReaction reaction) {
    final isCurrentUser =
        reaction.creator?.userId == AmityCoreClient.getUserId();

    return GestureDetector(
      onTap: () => _handleReactionTap(context, reaction, isCurrentUser),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatarImage(reaction),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    reaction.creator?.displayName ?? "",
                    style: TextStyle(
                      color: theme.baseColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  if (referenceType == AmityReactionReferenceType.MESSAGE &&
                      isCurrentUser)
                    Text(
                      "Tap to remove reaction",
                      style: AmityTextStyle.caption(theme.baseColorShade1),
                    ),
                ],
              ),
            ),
            SvgPicture.asset(
              configProvider.getReaction(reaction.reactionName ?? "").imagePath,
              package: 'amity_uikit_beta_service',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // Handle reaction tap
  void _handleReactionTap(
      BuildContext context, AmityReaction reaction, bool isCurrentUser) {
    if (referenceType == AmityReactionReferenceType.MESSAGE && isCurrentUser) {
      // Remove user's reaction
      AmityChatClient.newMessageRepository()
          .getMessage(referenceId)
          .then((message) {
        message.react().removeReaction(reaction.reactionName ?? "");
        Navigator.of(context).pop();
      });
    } else {
      // Navigate to user profile
      final userId = reaction.creator?.userId;
      if (userId != null) {
        AmityUIKit4Manager.behavior.postContentComponentBehavior.goToUserProfilePage(
          context,
          userId,
        );
      }
    }
  }

  // Build user avatar image
  Widget avatarImage(AmityReaction reaction) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          width: 32,
          height: 32,
          child: AmityUserImage(user: reaction.creator, theme: theme, size: 32),
        ),
      ),
    );
  }
}
