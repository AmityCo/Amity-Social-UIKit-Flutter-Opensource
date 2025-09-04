import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/utils/user_image.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import '../../../utils/amity_dialog.dart';
import 'mention_text_editing_controller.dart';

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
    // Maximum mentions allowed.
    this.maxMentions = 30,
    // Error message configuration.
    this.mentionContentType = MentionContentType.general,
    // Suggestion display mode.
    this.suggestionDisplayMode = SuggestionDisplayMode.bottom,
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
  final int maxMentions;
  final MentionContentType mentionContentType;
  final SuggestionDisplayMode suggestionDisplayMode;

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
  StreamSubscription? _communityMemberStreamSubscription;
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
        if (_mentionController.isMentioning()) {
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
      mentionTextStyle: const TextStyle(),
      runTextStyle: widget.style ?? const TextStyle(color: Colors.black),
    );
    _mentionController.addListener(() {
      widget.onChanged?.call(_mentionController.text);
      _updateOverlay();
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
    if (_overlayEntry != null) {
      _removeOverlay();
      _updateOverlay();
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
    _communityMemberLiveCollection?.dispose();
    _communitySubscription?.cancel();
    if (widget.controller == null) {
      _mentionController.dispose();
    }
    if (_ownFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onSuggestionChanged(MentionSyntax? syntax, String? substring) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      log("substring: $substring");
      if (substring == null) {
        _clearUsersAndOverlay();
        _removeOverlay();
        return;
      }
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
    _amityUsersController?.dispose();
    _amityUsersController = null;
    _communityMemberStreamSubscription?.cancel();
    _communityMemberLiveCollection?.dispose();
    _communityMemberLiveCollection = null;
  }

  void _startNewSearch(String query) {
    _amityUsersController?.dispose();
    _amityUsersController = null;
    _communityMemberStreamSubscription?.cancel();
    _communityMemberLiveCollection?.dispose();
    _communityMemberLiveCollection = null;
    setState(() {
      _isFetching = true;
      _hasMore = true;
    });
    log("mention communityId: ${widget.communityId ?? 'null'}");
    final bool useCommunitySearch =
        widget.communityId != null && !_communityIsPublic;
    if (useCommunitySearch) {
      final searchQuery = query;
      log("Initializing Community Live Collection with query: '$searchQuery'");
      _communityMemberLiveCollection =
          AmitySocialClient.newCommunityRepository()
              .membership(widget.communityId!)
              .searchMembers(searchQuery)
              .filter(AmityCommunityMembershipFilter.MEMBER)
              .includeDeleted(false)
              .getLiveCollection();
      _communityMemberStreamSubscription = _communityMemberLiveCollection!
          .getStreamController()
          .stream
          .listen((members) {
        if (members.isEmpty && _communityMembers.isNotEmpty) {
          log("New community search returned 0, keeping previous results.");
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
    } else {
      late PagingController<AmityUser> controller;
      if (query.length < 3) {
        controller = PagingController<AmityUser>(
          pageFuture: (token) => AmityCoreClient.newUserRepository()
              .getUsers()
              .sortBy(AmityUserSortOption.DISPLAY)
              .getPagingData(token: token, limit: 20),
          pageSize: 20,
        );
      } else {
        controller = PagingController<AmityUser>(
          pageFuture: (token) => AmityCoreClient.newUserRepository()
              .searchUserByDisplayName(query)
              .sortBy(AmityUserSortOption.DISPLAY)
              .getPagingData(token: token, limit: 20),
          pageSize: 20,
        );
      }
      controller.addListener(() {
        if (controller.error == null && mounted) {
          if (controller.loadedItems.isEmpty && _amityUsers.isNotEmpty) {
            log("New user search returned 0, keeping previous results.");
          } else {
            setState(() {
              _amityUsers = controller.loadedItems;
              _isFetching = controller.isFetching;
              _hasMore = controller.hasMoreItems;
            });
          }
          _updateOverlay();
        }
      });
      _amityUsersController = controller;
      _amityUsersController?.fetchNextPage();
    }
  }

  void _loadMore() {
    if (widget.communityId != null && !_communityIsPublic) {
      if (!_isFetching && _hasMore && _communityMemberLiveCollection != null) {
        _communityMemberLiveCollection!.loadNext();
      }
    } else {
      if (!_isFetching && _hasMore && _amityUsersController != null) {
        _amityUsersController?.fetchNextPage();
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

  // Remove and re-create the overlay entry so that updated state is reflected.
  void _updateOverlay() {
    final currentLine = _getCurrentLine();
    if (!_mentionController.isMentioning() ||
        currentLine.trim().isEmpty ||
        currentLine.contains('\n')) {
      _removeOverlay();
      _cancelNoMatchTimer();
      return;
    }
    final int itemCount = (widget.communityId != null && !_communityIsPublic)
        ? _communityMembers.length
        : _amityUsers.length;
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
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
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
    final int itemCount = (widget.communityId != null && !_communityIsPublic)
        ? _communityMembers.length
        : _amityUsers.length;
    if (itemCount == 0) {
      return OverlayEntry(builder: (context) => const SizedBox.shrink());
    }
    // Compute maximum allowed height from suggestionMaxRow.
    final double maxAllowedHeight = widget.suggestionMaxRow * _rowHeight;
    final double dynamicHeight = itemCount * _rowHeight;
    final double containerHeight =
        dynamicHeight < maxAllowedHeight ? dynamicHeight : maxAllowedHeight;

    // Build the suggestion list overlay using the subwidget.
    Widget suggestionList = SuggestionListOverlay(
      itemCount: itemCount,
      rowHeight: _rowHeight,
      suggestionMaxRow: widget.suggestionMaxRow,
      scrollController: _listScrollController,
      backgroundColor: widget.theme.backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      itemBuilder: (context, index) {
        if (widget.communityId != null && !_communityIsPublic) {
          if (index >= _communityMembers.length) return const SizedBox.shrink();
          return _buildMemberRow(_communityMembers[index]);
        } else {
          if (index >= _amityUsers.length) return const SizedBox.shrink();
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
      log("Computed topPosition: $topPosition");
      return OverlayEntry(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _mentionController.dismissCurrentMention();
            _removeOverlay();
          },
          child: Stack(
            children: [
              Positioned(
                left: horizontalMargin,
                top: topPosition,
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
              Positioned(
                right: 2,
                top: topPosition - 6,
                child: _buildDismissButton(),
              ),
            ],
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
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _mentionController.dismissCurrentMention();
            _removeOverlay();
          },
          child: Stack(
            children: [
              Positioned(
                left: 8.0,
                right: 8.0,
                bottom: bottomOffset,
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
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
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
            ],
          ),
        ),
      );
    }
  }

  Widget _buildUserRow(AmityUser user) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onSelectMention(user),
      child: Container(
        width: double.infinity,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: AmityUserImage(
                    user: user,
                    theme: widget.theme,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      user.displayName ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AmityTextStyle.bodyBold(widget.theme.baseColor),
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: AmityUserImage(
                    user: user,
                    theme: widget.theme,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                user.displayName ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AmityTextStyle.bodyBold(widget.theme.baseColor),
              ),
            ),
          ],
        ),
      ),
    );
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
        displayName: user.displayName ?? 'Unknown',
        avatarUrl: user.avatarUrl ?? '',
      ),
    );
    final currentMentionsCount = _mentionController.getMentionUserIds().length;
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
