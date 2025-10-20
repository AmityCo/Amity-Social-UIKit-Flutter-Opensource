import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/l10n/generated/app_localizations.dart';
import '../../../utils/amity_dialog.dart';
import 'mention_text_editing_controller.dart';

// Enum to represent loading status internally
enum AmityLoadingStatus { idle, loading, success, error }

/// Content type for determining error message.
enum MentionContentType { general, post, comment }

/// Display mode for suggestion list.
enum SuggestionDisplayMode { bottom, inline }

/// ----------------------
/// SuggestionListOverlay
/// ----------------------
/// This subwidget encapsulates the UI for the suggestion list overlay.
/// It calculates its height dynamically based on the number of items and row height,
/// but never exceeds the maximum height, which is computed as suggestionMaxRow * rowHeight.
/// An AnimatedContainer is used for smooth transitions. When the container is shrinking,
/// an extra 8.0 pixels are added.
class SuggestionListOverlay extends StatefulWidget {
  final int itemCount;
  final double rowHeight;
  final int
      suggestionMaxRow; // Maximum number of rows allowed (defaulted to 3 in parent).
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController scrollController;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  const SuggestionListOverlay({
    Key? key,
    required this.itemCount,
    required this.rowHeight,
    required this.suggestionMaxRow,
    required this.itemBuilder,
    required this.scrollController,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  }) : super(key: key);

  @override
  _SuggestionListOverlayState createState() => _SuggestionListOverlayState();
}

class _SuggestionListOverlayState extends State<SuggestionListOverlay> {
  @override
  Widget build(BuildContext context) {
    // Compute the maximum allowed height.
    final double maxAllowedHeight = widget.suggestionMaxRow * widget.rowHeight;
    final double dynamicHeight = widget.itemCount * widget.rowHeight;
    final bool isShrinking = dynamicHeight < maxAllowedHeight;
    // When shrinking, add an extra 8.0 pixels.
    final double computedHeight =
        isShrinking ? dynamicHeight + 8.0 : maxAllowedHeight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: computedHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: ListView.builder(
          controller: widget.scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero, // Align content to the top.
          physics: const ClampingScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.topLeft,
              child: widget.itemBuilder(context, index),
            );
          },
        ),
      ),
    );
  }
}

/// ----------------------
/// MentionTextField Widget
/// ----------------------
/// This widget displays the text field and manages the overlay.
/// The overlay creation now uses the SuggestionListOverlay subwidget, and the maximum
/// height is computed as suggestionMaxRow * rowHeight.
class MentionTextField extends StatefulWidget {
  const MentionTextField({
    Key? key,
    required this.theme,
    this.controller,
    this.maxLines,
    this.minLines,
    this.enabled,
    this.decoration,
    this.style,
    this.onChanged,
    this.onMentionSelected,
    this.keyboardType,
    this.scrollController,
    this.textAlignVertical,
    this.isDense,
    this.contentPadding,
    // External focus node.
    this.focusNode,
    // Overlays.
    this.suggestionOverlayBottomPaddingWhenKeyboardClosed = 0.0,
    this.suggestionOverlayBottomPaddingWhenKeyboardOpen = 0.0,
    // New: maximum number of rows allowed. Default is 3.
    this.suggestionMaxRow = 3,
    // Optional communityId parameter.
    this.communityId,
    // Optional channelId parameter for chat mentions
    this.channelId,
    // Maximum mentions allowed.
    this.maxMentions = 30,
    // Error message configuration.
    this.mentionContentType = MentionContentType.general,
    // Suggestion display mode.
    this.suggestionDisplayMode = SuggestionDisplayMode.bottom,
    // Additional input field callbacks
    this.onTap,
    this.onTapOutside,
    this.cursorColor,
    this.enableMention = true,
  }) : super(key: key);

  final AmityThemeColor theme;
  final MentionTextEditingController? controller;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final InputDecoration? decoration;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<AmityUser>? onMentionSelected;
  final TextInputType? keyboardType;
  final ScrollController? scrollController;
  final TextAlignVertical? textAlignVertical;
  final bool? isDense;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final double suggestionOverlayBottomPaddingWhenKeyboardClosed;
  final double suggestionOverlayBottomPaddingWhenKeyboardOpen;
  final int suggestionMaxRow; // Maximum number of rows (default 3).
  final String? communityId;
  final String? channelId; // Channel ID for chat mentions
  final int maxMentions;
  final MentionContentType mentionContentType;
  final SuggestionDisplayMode suggestionDisplayMode;
  final VoidCallback? onTap; // Called when text field is tapped
  final TapRegionCallback?
      onTapOutside; // Called when user taps outside the text field
  final Color? cursorColor; // Color of the text cursor
  final bool enableMention; // Enable/disable mention functionality

  @override
  State<MentionTextField> createState() => _MentionTextFieldState();
}

class _MentionTextFieldState extends State<MentionTextField>
    with WidgetsBindingObserver {
  late MentionTextEditingController _mentionController;
  late FocusNode _focusNode;
  bool _ownFocusNode = false;
  OverlayEntry? _overlayEntry;
  PagingController<AmityUser>? _amityUsersController;
  CommunityMemberLiveCollection? _communityMemberLiveCollection;
  ChannelMemberSearchLiveCollection?
      _channelMemberLiveCollection; // Can be either ChannelMemberLiveCollection or ChannelMemberSearchLiveCollection
  StreamSubscription? _communityMemberStreamSubscription;
  StreamSubscription? _channelMemberStreamSubscription;
  // Subscription for community details.
  StreamSubscription<AmityCommunity>? _communitySubscription;
  List<AmityCommunityMember> _communityMembers = [];
  bool _isFetching = false;
  bool _hasMore = true;
  List<AmityUser> _amityUsers = [];
  Timer? _debounceTimer;
  Timer? _noMatchCloseTimer;
  final ScrollController _listScrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  // Local variable for community public status.
  bool _communityIsPublic = false;

  static const double _rowHeight = 56.0;

  bool _shouldDisableMentions() {
    // Check if mention functionality is disabled via parameter
    return !widget.enableMention;
  }

  bool _shouldShowMentionAll() {
    try {
      return AmityCoreClient.mentionConfigurations?.isMentionAllEnabled ?? true;
    } catch (e) {
      return true;
    }
  }

  String _getUserDisplayName(AmityUser user, BuildContext context) {
    if (user.isDeleted ?? false) {
      return AppLocalizations.of(context)?.user_profile_deleted_name ?? 'Deleted user';
    }
    return user.displayName ?? (AppLocalizations.of(context)?.user_profile_unknown_name ?? 'Unknown');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _ownFocusNode = true;
      _focusNode = FocusNode();
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Only show mention suggestions if mentions are not disabled
        if (!_shouldDisableMentions() && _mentionController.isMentioning()) {
          final substring = _mentionController.getSearchText();
          _onSuggestionChanged(_mentionController.getSearchSyntax(), substring);
        }
      }
    });
    if (widget.communityId != null) {
      _communitySubscription = AmitySocialClient.newCommunityRepository()
          .live
          .getCommunity(widget.communityId!)
          .listen((community) {
        setState(() {
          _communityIsPublic = community.isPublic ?? false;
        });
      });
    }
    if (widget.controller != null) {
      _mentionController = widget.controller!;
      _mentionController.chainOnSuggestionChanged(_onSuggestionChanged);
    } else {
      _mentionController = MentionTextEditingController(
        onSuggestionChanged: _onSuggestionChanged,
      );
    }
    _mentionController.updateConfig(
      mentionBgColor: Colors.transparent,
      mentionTextColor: widget.theme.highlightColor,
      mentionTextStyle: AmityTextStyle.bodyBold(widget.theme.highlightColor),
      runTextStyle: widget.style ?? const TextStyle(color: Colors.black),
    );
    _mentionController.addListener(() {
      widget.onChanged?.call(_mentionController.text);
      // Only update overlay if mentions are not disabled
      if (!_shouldDisableMentions()) {
        _updateOverlay();
      }
    });
    _listScrollController.addListener(() {
      final maxScroll = _listScrollController.position.maxScrollExtent;
      final currentScroll = _listScrollController.position.pixels;
      const threshold = 50.0;
      if (maxScroll - currentScroll <= threshold) {
        _loadMore();
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // For layout changes (keyboard), just reposition - no need to recreate
    // This is safe because we're not changing data, only layout
    if (_overlayEntry != null) {
      // This will make the overlay rebuild in place without removing it
      _overlayEntry!.markNeedsBuild();

      // Add a small delay to prevent rapid consecutive rebuilds
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _overlayEntry != null) {
          _overlayEntry!.markNeedsBuild();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeOverlay();
    _debounceTimer?.cancel();
    _noMatchCloseTimer?.cancel();
    _listScrollController.dispose();
    _amityUsersController?.dispose();
    _communityMemberStreamSubscription?.cancel();
    _channelMemberStreamSubscription?.cancel();
    _communityMemberLiveCollection?.dispose();
    _channelMemberLiveCollection?.dispose();
    _communitySubscription?.cancel();
    if (widget.controller == null) {
      _mentionController.dispose();
    }
    if (_ownFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  // This method has been removed as we're now using LiveCollection exclusively

  void _onSuggestionChanged(MentionSyntax? syntax, String? substring) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (substring == null) {
        if (widget.channelId != null) {
          _startNewSearch("");
          return;
        }
        _clearUsersAndOverlay();
        _removeOverlay();
        return;
      }

      // Check if mentions should be disabled
      if (_shouldDisableMentions()) {
        _clearUsersAndOverlay();
        _removeOverlay();
        return;
      }

      // Handle both empty string (just @ case) and non-empty search queries
      // Empty string should fetch all users like the initial @ case
      _startNewSearch(substring);
    });
  }

  void _clearUsersAndOverlay() {
    setState(() {
      _amityUsers.clear();
      _communityMembers.clear();
      _isFetching = false;
      _hasMore = true;
    });
    // Clean up user search
    _amityUsersController?.dispose();
    _amityUsersController = null;

    // Clean up channel member search
    _channelMemberStreamSubscription?.cancel();
    _channelMemberLiveCollection?.dispose();
    _channelMemberLiveCollection = null;

    // Clean up community member search
    _communityMemberStreamSubscription?.cancel();
    _communityMemberLiveCollection?.dispose();
    _communityMemberLiveCollection = null;
  }

  void _startNewSearch(String query) {
    // Clean up previous search resources
    _amityUsersController?.dispose();
    _amityUsersController = null;
    _communityMemberStreamSubscription?.cancel();
    _communityMemberLiveCollection?.dispose();
    _communityMemberLiveCollection = null;
    _channelMemberStreamSubscription?.cancel();
    _channelMemberLiveCollection?.dispose();
    _channelMemberLiveCollection = null;
    setState(() {
      _isFetching = true;
      _hasMore = true;
    });

    // Determine which search mode to use
    final bool useChannelSearch = widget.channelId != null;
    final bool useCommunitySearch =
        widget.communityId != null && !_communityIsPublic;

    // === CHANNEL MODE ===
    if (useChannelSearch) {

      // Clean up previous resources
      _channelMemberStreamSubscription?.cancel();
      _channelMemberLiveCollection?.dispose();

      try {
        // Search members by display name
        _channelMemberLiveCollection = AmityChatClient.newChannelRepository()
            .membership(widget.channelId!)
            .searchMembers(query)
            .membershipFilter([
          AmityChannelMembership.MEMBER,
          AmityChannelMembership.MUTED
        ]).getLiveCollection();

        // Listen for channel member results
        _channelMemberStreamSubscription = _channelMemberLiveCollection!
            .getStreamController()
            .stream
            .listen((members) {
          // Extract users from channel members
          final newUsers = members
              .map((member) => member.user)
              .where((user) => user != null)
              .cast<AmityUser>()
              .toList();

          setState(() {
            _amityUsers = newUsers;
            _isFetching = false; // LiveCollection handles loading internally
            _hasMore = _channelMemberLiveCollection!.hasNextPage();
          });
          _updateOverlay();
        }, onError: (error) {
          setState(() {
            _isFetching = false;
          });
        });

        // Start loading channel members
        _channelMemberLiveCollection!.loadNext();
      } catch (e) {
        setState(() {
          _isFetching = false;
        });
      }
    }
    // === COMMUNITY MODE ===
    else if (useCommunitySearch) {

      _communityMemberLiveCollection =
          AmitySocialClient.newCommunityRepository()
              .membership(widget.communityId!)
              .searchMembers(query)
              .filter(AmityCommunityMembershipFilter.MEMBER)
              .includeDeleted(false)
              .getLiveCollection();

      _communityMemberStreamSubscription = _communityMemberLiveCollection!
          .getStreamController()
          .stream
          .listen((members) {
        if (members.isEmpty && _communityMembers.isNotEmpty) {
        } else {
          setState(() {
            _communityMembers = members;
            _isFetching = false;
            _hasMore = _communityMemberLiveCollection!.hasNextPage();
          });
        }
        _updateOverlay();
      });

      _communityMemberLiveCollection!.loadNext();
    }
    // === DEFAULT USER MODE ===
    else {
      _amityUsersController = PagingController<AmityUser>(
        pageFuture: (token) {
          if (query.length < 3) {
            // For short queries, just get users sorted by display name
            return AmityCoreClient.newUserRepository()
                .getUsers()
                .sortBy(AmityUserSortOption.DISPLAY)
                .getPagingData(token: token, limit: 20);
          } else {
            // For longer queries, search by display name
            return AmityCoreClient.newUserRepository()
                .searchUserByDisplayName(query)
                .matchType(AmityUserSearchMatchType.PARTIAL)                
                .sortBy(AmityUserSortOption.DISPLAY)
                .getPagingData(token: token, limit: 20);
          }
        },
        pageSize: 20,
      );

      // Listen for user results
      _amityUsersController!.addListener(() {
        if (_amityUsersController!.error == null && mounted) {
          if (_amityUsersController!.loadedItems.isEmpty &&
              _amityUsers.isNotEmpty) {
          } else {
            final newUsers = _amityUsersController!.loadedItems;

            setState(() {
              _amityUsers = newUsers;

              _isFetching = _amityUsersController!.isFetching;
              _hasMore = _amityUsersController!.hasMoreItems;
            });
          }
          _updateOverlay();
        }
      });

      // Start loading users
      _amityUsersController!.fetchNextPage();
    }
  }

  void _loadMore() {
    // Channel members search (for chat)
    if (widget.channelId != null) {
      if (!_isFetching && _hasMore && _channelMemberLiveCollection != null) {
        _channelMemberLiveCollection!.loadNext();
      }
    }
    // Community members search
    else if (widget.communityId != null && !_communityIsPublic) {
      if (!_isFetching && _hasMore && _communityMemberLiveCollection != null) {
        _communityMemberLiveCollection!.loadNext();
      }
    }
    // Regular user search
    else {
      if (!_isFetching && _hasMore && _amityUsersController != null) {
        _amityUsersController!.fetchNextPage();
      }
    }
  }

  String _getCurrentLine() {
    final text = _mentionController.text;
    final selection = _mentionController.selection;
    if (selection.baseOffset < 0 || selection.baseOffset > text.length)
      return "";
    final index = selection.baseOffset - 1;
    if (index < 0) return "";

    final lastNewline = text.lastIndexOf('\n', selection.baseOffset - 1);
    return lastNewline == -1
        ? text.substring(0, selection.baseOffset)
        : text.substring(lastNewline + 1, selection.baseOffset);
  }

  void _cancelNoMatchTimer() {
    if (_noMatchCloseTimer != null) {
      _noMatchCloseTimer!.cancel();
      _noMatchCloseTimer = null;
    }
  }

  // Update the overlay without unnecessary recreation
  void _updateOverlay() {
    // Check if mentions are disabled first
    if (_shouldDisableMentions()) {
      _removeOverlay();
      _cancelNoMatchTimer();
      return;
    }

    final currentLine = _getCurrentLine();
    if (!_mentionController.isMentioning() || currentLine.contains('\n')) {
      _removeOverlay();
      _cancelNoMatchTimer();
      return;
    }

    // Allow empty line if we're mentioning (just @ symbol case)
    // This enables showing all users when only @ is present
    if (currentLine.trim().isEmpty && !_mentionController.isMentioning()) {
      _removeOverlay();
      _cancelNoMatchTimer();
      return;
    }

    // Determine which search mode to use
    final bool useCommunityMode =
        widget.communityId != null && !_communityIsPublic;
    final bool useChannelMode = widget.channelId != null;

    // Get base item count (actual search results)
    final int baseItemCount =
        useCommunityMode ? _communityMembers.length : _amityUsers.length;

    // For channel mode, handle @All display logic
    if (useChannelMode) {
      _cancelNoMatchTimer();

      final String searchText = _mentionController.getSearchText();
      final bool isEmptySearch = searchText.trim().isEmpty;

      // For empty search (just @): show @All + all users
      // For non-empty search: show only matching users (no @All)
      if (isEmptySearch || baseItemCount > 0) {
        if (_overlayEntry == null) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        } else {
          _overlayEntry!.remove();
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        }
        return;
      } else {
        // Has search text but no results - hide overlay after delay
        if (_overlayEntry != null && _noMatchCloseTimer == null) {
          _noMatchCloseTimer = Timer(const Duration(seconds: 3), () {
            _removeOverlay();
            _noMatchCloseTimer = null;
          });
        }
        return;
      }
    }

    // For non-channel modes, use baseItemCount as itemCount
    final int itemCount = baseItemCount;

    // For other modes, only show if we have results
    if (itemCount == 0) {
      if (_overlayEntry != null && _noMatchCloseTimer == null) {
        _noMatchCloseTimer = Timer(const Duration(seconds: 3), () {
          _removeOverlay();
          _noMatchCloseTimer = null;
        });
      }
      return;
    } else {
      _cancelNoMatchTimer();
    }

    // ALWAYS recreate the overlay when data changes to ensure it has the latest data.
    // 
    // Why not use markNeedsBuild()?
    // - markNeedsBuild() works for LAYOUT changes (keyboard, positioning)
    // - But for DATA changes, the builder function captures old variables (closure)
    // - Example: If _amityUsers was [] when overlay created, markNeedsBuild() still shows []
    // 
    // Performance note:
    // - Recreating overlay causes brief flicker, but necessary for data updates
    // - This only happens when search results change, not on every keystroke (debounced)
    // - The flicker is acceptable tradeoff for showing correct results
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDismissButton() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        elevation: 3,
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: () {
            _mentionController.dismissCurrentMention();
            _removeOverlay();
          },
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: SvgPicture.asset(
            'assets/Icons/amity_ic_close_viewer.svg',
            package: 'amity_uikit_beta_service',
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    // Determine which mode we're in
    final bool useCommunityMode =
        widget.communityId != null && !_communityIsPublic;
    final bool useChannelMode = widget.channelId != null;

    // Get base item count (actual search results)
    final int baseItemCount =
        useCommunityMode ? _communityMembers.length : _amityUsers.length;

    // For channel mode, handle @All display logic
    final int itemCount;
    if (useChannelMode) {
      final String searchText = _mentionController.getSearchText();
      final bool isEmptySearch = searchText.trim().isEmpty;
      
      if (isEmptySearch && _shouldShowMentionAll()) {
        // Just @ symbol - show @All + all users
        itemCount = baseItemCount + 1;
      } else {
        // Has search text - show only search results (no @All)
        itemCount = baseItemCount;
      }
    } else {
      itemCount = baseItemCount; // No @All for non-channel modes
    }

    if (itemCount == 0) {
      return OverlayEntry(builder: (context) => const SizedBox.shrink());
    }

    // Compute maximum allowed height from suggestionMaxRow
    final double maxAllowedHeight = widget.suggestionMaxRow * _rowHeight;
    final double dynamicHeight = itemCount * _rowHeight;
    final double containerHeight =
        dynamicHeight < maxAllowedHeight ? dynamicHeight : maxAllowedHeight;

    // Build the suggestion list overlay using the subwidget
    Widget suggestionList = SuggestionListOverlay(
      itemCount: itemCount,
      rowHeight: _rowHeight,
      suggestionMaxRow: widget.suggestionMaxRow,
      scrollController: _listScrollController,
      backgroundColor: widget.theme.backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      itemBuilder: (context, index) {
        final bool useChannelMode = widget.channelId != null;

        if (useChannelMode) {
          final String searchText = _mentionController.getSearchText();
          final bool isEmptySearch = searchText.trim().isEmpty;
          
          // For channel mode with empty search, show @All first, then users
          if (isEmptySearch && _shouldShowMentionAll()) {
            if (index == 0) {
              return _buildAllMentionRow();
            }
            // Adjust index for users (subtract 1 because @All took first position)
            final adjustedIndex = index - 1;
            if (adjustedIndex >= _amityUsers.length) return const SizedBox.shrink();
            return _buildUserRow(_amityUsers[adjustedIndex]);
          }
          
          // For channel mode with search text, show only search results (no @All)
          if (!isEmptySearch) {
            if (index >= _amityUsers.length) return const SizedBox.shrink();
            return _buildUserRow(_amityUsers[index]);
          }
          
          return const SizedBox.shrink();
        }

        if (useCommunityMode) {
          // Community mode - show community members
          if (index >= _communityMembers.length)
            return const SizedBox.shrink();
          return _buildMemberRow(_communityMembers[index]);
        } else {
          // Default mode - show users
          if (index >= _amityUsers.length)
            return const SizedBox.shrink();
          return _buildUserRow(_amityUsers[index]);
        }
      },
    );

    if (widget.suggestionDisplayMode == SuggestionDisplayMode.inline) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final mediaQuery = MediaQuery.of(context);
      final screenSize = mediaQuery.size;
      // Use fixed horizontal margins (8.0 on each side) like bottom mode.
      const double horizontalMargin = 8.0;
      final double availableWidth = screenSize.width - (horizontalMargin * 2);
      final double topPosition =
          (screenSize.height - (position.dy + size.height + containerHeight) <
                  0)
              ? position.dy - containerHeight - 2
              : position.dy + size.height;
      return OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent, // Transparent material to capture taps
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Changed to opaque to capture all taps
            onTap: () {
              _mentionController.dismissCurrentMention();
              _removeOverlay();
            },
            child: Container(
              width: MediaQuery.of(context).size.width, // Full screen width
              height: MediaQuery.of(context).size.height, // Full screen height
              color: Colors.transparent, // Transparent container
              child: Stack(
                children: [
                  Positioned(
                    left: horizontalMargin,
                    top: topPosition,
                    child: GestureDetector(
                      // This prevents taps on the suggestion list from dismissing
                      onTap: () {/* Do nothing, preventing tap propagation */},
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: availableWidth,
                          maxHeight: containerHeight,
                        ),
                        child: Material(
                          elevation: 4,
                          color: Colors.transparent,
                          shadowColor: Colors.black54,
                          borderRadius: BorderRadius.circular(12.0),
                          child: suggestionList,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: topPosition - 6,
                    child: _buildDismissButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      final window = WidgetsBinding.instance.window;
      final keyboardHeight = window.viewInsets.bottom / window.devicePixelRatio;
      final basePadding = (keyboardHeight > 0)
          ? widget.suggestionOverlayBottomPaddingWhenKeyboardOpen
          : widget.suggestionOverlayBottomPaddingWhenKeyboardClosed;
      final bottomOffset = basePadding + keyboardHeight;
      return OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent, // Transparent material to capture taps
          child: GestureDetector(
            behavior:
                HitTestBehavior.opaque, // Changed to opaque to capture all taps
            onTap: () {

              _mentionController.dismissCurrentMention();
              _removeOverlay();
            },
            child: Container(
              width: MediaQuery.of(context).size.width, // Full screen width
              height: MediaQuery.of(context).size.height, // Full screen height
              color: Colors.transparent, // Transparent container
              child: Stack(
                children: [
                  Positioned(
                    left: 8.0,
                    right: 8.0,
                    bottom: bottomOffset,
                    child: GestureDetector(
                      // This prevents taps on the suggestion list from dismissing
                      onTap: () {/* Do nothing, preventing tap propagation */},
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            elevation: 2,
                            shadowColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              height: containerHeight,
                              decoration: BoxDecoration(
                                color: widget.theme.backgroundColor,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: suggestionList,
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -4,
                            child: _buildDismissButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  // Widget to build the @All mention row at the top of the suggestion list when in channel mode
  Widget _buildAllMentionRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onSelectAllMention(),
      child: Container(
        width: double.infinity,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          // Highlight the @All option with a subtle background color
          color: widget.theme.primaryColor.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 32,
                  height: 32,
                  color: widget.theme.primaryColor,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/Icons/amity_ic_mention_all.svg',
                    package: 'amity_uikit_beta_service',
                    width: 16,
                    height: 16,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "All",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AmityTextStyle.captionBold(widget.theme.baseColor),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                "Notify everyone",
                style: AmityTextStyle.caption(widget.theme.baseColorShade3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(AmityUser user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onSelectMention(user),
      child: Container(
        width: double.infinity,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: AmityUserImage(
                    user: user,
                    theme: widget.theme,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      _getUserDisplayName(user, context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AmityTextStyle.captionBold(widget.theme.baseColor),
                    ),
                  ),
                  if (user.isBrand ?? false) brandBadge(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMemberRow(AmityCommunityMember member) {
    final AmityUser? user = member.user;
    if (user == null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (member.user == null) {
          _removeOverlay();
        } else {
          if (mounted) setState(() {});
        }
      });
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onSelectMention(user),
      child: Container(
        width: double.infinity,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: AmityUserImage(
                    user: user,
                    theme: widget.theme,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getUserDisplayName(user, context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AmityTextStyle.captionBold(widget.theme.baseColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelectAllMention() {
    // Insert @All mention
    _mentionController.insertMention(
      UserMention(
        id: "all", // Special ID for @all mentions
        displayName: "All",
        avatarUrl: "", // No avatar for @all mentions
      ),
    );

    // Close the overlay
    _removeOverlay();

    // Optional: Print a log message (or show a toast in a real app)
  }

  void _removeLastMention() {
    final mentions = _mentionController.getMentions();
    if (mentions.isNotEmpty) {
      final lastMention = mentions.last;
      final start = lastMention["startIndex"] as int;
      final end = lastMention["endIndex"] as int;
      final newText = _mentionController.text.replaceRange(start, end, '');
      _mentionController.text = newText;
    }
  }

  void _onSelectMention(AmityUser user) {
    _mentionController.insertMention(
      UserMention(
        id: user.userId ?? '',
        displayName: _getUserDisplayName(user, context),
        avatarUrl: user.avatarUrl ?? '',
      ),
    );
    final currentMentionsCount =
        _mentionController.getAllMentionUserIds().length;
    if (currentMentionsCount > widget.maxMentions) {
      const errorTitle = "Too many users mentioned";
      String errorMessage;
      switch (widget.mentionContentType) {
        case MentionContentType.post:
          errorMessage =
              "You can only mention up to ${widget.maxMentions} users per post.";
          break;
        case MentionContentType.comment:
          errorMessage =
              "You can only mention up to ${widget.maxMentions} users per comment.";
          break;
        default:
          errorMessage =
              "You can only mention up to ${widget.maxMentions} users.";
          break;
      }
      AmityV4Dialog()
          .showAlertErrorDialog(
        title: errorTitle,
        message: errorMessage,
        closeText: "OK",
      )
          .then((_) {
        _removeLastMention();
      });
      return;
    }
    widget.onMentionSelected?.call(user);
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = TextField(
      controller: _mentionController,
      focusNode: _focusNode,
      scrollController: widget.scrollController,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      enabled: widget.enabled,
      textAlignVertical: widget.textAlignVertical,
      cursorColor: widget.cursorColor,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      decoration: widget.decoration ??
          InputDecoration(
            isDense: widget.isDense ?? true,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            hintText: 'Type @ to mention...',
            border: InputBorder.none,
          ),
      style: widget.style ?? TextStyle(color: widget.theme.baseColor),
      onChanged: widget.onChanged,
    );
    if (widget.suggestionDisplayMode == SuggestionDisplayMode.inline) {
      textField = CompositedTransformTarget(
        link: _layerLink,
        child: textField,
      );
    }
    return textField;
  }
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
