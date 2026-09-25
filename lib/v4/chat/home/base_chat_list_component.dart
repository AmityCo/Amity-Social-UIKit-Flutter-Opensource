import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/chat/archive/archived_chat_list_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/bloc/chat_list_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_empty_state.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_list_skeleton.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/channel_avatar.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BaseChatListComponent extends NewBaseComponent {
  BaseChatListComponent(
      {super.key,
      super.pageId,
      required super.componentId,
      required this.chatListType,
      this.channelTypes});

  final scrollController = ScrollController();
  final ChatListType chatListType;
  final List<AmityChannelType>? channelTypes;

  @override
  Widget buildComponent(BuildContext context) {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            context.read<ChatListBloc>().addEvent(ChatListLoadNextPage());
          }
        });

        if (state.showArchiveErrorDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showArchiveErrorDialog(context, state.error?.title ?? context.l10n.general_error_title,
                state.error?.message ?? context.l10n.general_error_message);
            context
                .read<ChatListBloc>()
                .addEvent(ChatListEventResetDialogState());
          });
        }

        if (state.isLoading && state.channels.isEmpty) {
          return ChatListSkeletonLoadingView();
        } else if (!state.isLoading && state.channels.isEmpty) {
          if (chatListType == ChatListType.ARCHIVED) {
            return ArchivedChatListEmptyState(theme: theme);
          } else {
            // Check if this is a group chat list (only COMMUNITY channels)
            final bool isGroupChatList = channelTypes != null && 
                channelTypes!.length == 1 && 
                channelTypes!.contains(AmityChannelType.COMMUNITY);
            return ChatListEmptyState(
              theme: theme,
              isGroupChatList: isGroupChatList,
            );
          }
        } else {
          return Column(
            children: [
              if (!state.isPushNotificationEnabled)
                Container(
                  color: token(AmityColorToken.surfaceBannerSubdueGeneral),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/Icons/amity_ic_chat_mute.svg',
                        package: 'amity_uikit_beta_service',
                        width: 12,
                        height: 12,
                        color: token(AmityColorToken.iconListHeaderGeneral),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.chat_notifications_disabled,
                        style: TextStyle(
                            color: token(AmityColorToken
                                .textBannerSubdueTextDescriptionGeneral),
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: state.channels.length,
                  itemBuilder: (context, index) {
                    final channel = state.channels[index];
                    final channelMember = state
                        .channelMembers[channel.channelId]; // Other participant

                    return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (channel.amityChannelType ==
                              AmityChannelType.COMMUNITY) {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                  builder: (context) => AmityGroupChatPage(
                                        channelId: channel.channelId ?? "",
                                      )),
                            )
                                .then((value) {
                              context
                                  .read<AmityToastBloc>()
                                  .add(AmityToastDismiss());
                            });
                          } else {
                            final channelId = channel.channelId;
                            final userId = channelMember?.userId;
                            final displayName =
                                channelMember?.user?.displayName;
                            final avatarUrl = channelMember?.user?.avatarUrl;

                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => AmityChatPage(
                                  key:
                                      Key("${channelId ?? ""}_${userId ?? ""}"),
                                  channelId: channelId,
                                  userId: userId ?? "",
                                  userDisplayName: displayName ?? "",
                                  avatarUrl: avatarUrl ?? "",
                                ),
                              ),
                            )
                                .then((value) {
                              context
                                  .read<AmityToastBloc>()
                                  .add(AmityToastDismiss());
                            });
                          }
                        },
                        child: renderChatListItem(
                            context, chatListType, channel, channelMember,
                            isMemberResolved: state.channelMembers
                                .containsKey(channel.channelId)));
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void _showArchiveErrorDialog(
      BuildContext context, String errorTitle, String errorMessage) {
    final localize = context.l10n;
    AmityV4Dialog().showAlertErrorDialog(
      title: errorTitle,
      message: errorMessage,
      closeText: localize.general_ok,
    );
  }

  Widget renderChatListItem(BuildContext context, ChatListType chatListType,
      AmityChannel channel, AmityChannelMember? channelMember,
      {bool isMemberResolved = true}) {
    // Enable archive functionality for both conversation and community channels
    if (chatListType == ChatListType.CONVERSATION) {
      return renderDismissibleListItem(
          chatListType,
          channel,
          channelMember,
          isMemberResolved,
          "assets/Icons/amity_ic_channel_archive.svg",
          context.l10n.chat_archive, (direction) {
        context.read<ChatListBloc>().addEvent(
            ChatListEventChannelArchive(
              channelId: channel.channelId!,
              successMessage: context.l10n.toast_chat_archived,
              errorMessage: context.l10n.toast_chat_archive_error,
              limitErrorTitle: context.l10n.chat_archive_limit_title,
              limitErrorMessage: context.l10n.chat_archive_limit_message,
            ));
      });
    } else if (chatListType == ChatListType.ARCHIVED) {
      return renderDismissibleListItem(
          chatListType,
          channel,
          channelMember,
          isMemberResolved,
          "assets/Icons/amity_ic_channel_unarchive.svg",
          context.l10n.chat_unarchive, (direction) {
        context.read<ChatListBloc>().addEvent(
            ChatListEventChannelUnarchive(
              channelId: channel.channelId!,
              successMessage: context.l10n.toast_chat_unarchived,
              errorMessage: context.l10n.toast_chat_unarchive_error,
            ));
      });
    } else {
      return ChatListItem(
          channel: channel,
          channelMember: channelMember,
          isMemberResolved: isMemberResolved);
    }
  }

  Widget renderDismissibleListItem(
      ChatListType chatListType,
      AmityChannel channel,
      AmityChannelMember? channelMember,
      bool isMemberResolved,
      String assetIcon,
      String actionText,
      void Function(DismissDirection)? onDismissed) {
    final channelId = channel.channelId;
    final userId = channelMember?.userId;
    return Dismissible(
        key: Key("item_${channelId ?? ""}_${userId ?? ""}"),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          if (onDismissed != null) {
            onDismissed(direction);
          }
          return false;
        },
        background: Builder(builder: (context) {
          return Container(
            color: token(
                AmityColorToken.surfaceSquareButtonDefaultSecondaryDefault),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  assetIcon,
                  package: 'amity_uikit_beta_service',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    token(AmityColorToken
                        .iconSquareButtonDefaultSecondaryDefault),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  actionText,
                  style: AmityTextStyle.captionBold(token(
                      AmityColorToken.textSquareButtonDefaultSecondaryDefault)),
                ),
              ],
            ),
          );
        }),
        child: ChatListItem(
            channel: channel,
            channelMember: channelMember,
            isMemberResolved: isMemberResolved));
  }
}

/// Start offsets of [query] in [text]: case-insensitive, anywhere in the text,
/// non-overlapping — the rule Android's `AmityChatListItem` highlights with,
/// so a search for "test" also emphasises "re**test**". Applies to both the
/// message preview and the channel/user name (the old word-start rule left
/// most real hits un-highlighted). Empty query matches nothing.
List<int> findCaseInsensitiveMatches(String text, String query) {
  final lowercaseText = text.toLowerCase();
  final lowercaseQuery = query.toLowerCase();
  if (lowercaseQuery.isEmpty) return const [];
  final matches = <int>[];
  var i = lowercaseText.indexOf(lowercaseQuery);
  while (i != -1) {
    matches.add(i);
    i = lowercaseText.indexOf(lowercaseQuery, i + lowercaseQuery.length);
  }
  return matches;
}

class ChatListItem extends BaseElement {
  final AmityChannel channel;
  final AmityChannelMember? channelMember; // Other member

  /// Whether the caller has finished looking the counterpart up. The bloc fills
  /// its member map lazily, so a null [channelMember] means "not loaded yet"
  /// until this is true — and only then does null mean "nobody is left".
  final bool isMemberResolved;
  final String searchQuery;
  final bool isArchived;
  final AmityMessage? searchMessage; // Optional message to override channel preview

  ChatListItem({
    Key? key,
    String? pageId,
    String? componentId,
    required this.channel,
    required this.channelMember,
    this.isMemberResolved = true,
    this.searchQuery = "",
    this.isArchived = false,
    this.searchMessage,
  }) : super(
          key: key,
          pageId: pageId,
          componentId: componentId,
          elementId: 'chat-list-item',
        );

  /// The 1-1 counterpart is gone: their user record is flagged deleted, the
  /// membership is, or — once the lookup has resolved — there is no other
  /// member at all. Never true while the lookup is still pending.
  bool get _isCounterpartDeleted =>
      isMemberResolved &&
      (channelMember == null ||
          channelMember!.isDeleted == true ||
          channelMember!.user?.isDeleted == true);

  @override
  Widget buildElement(BuildContext context) {
    Widget displayNameWidget;

    String? previewText;
    Widget? previewIcon;
    
    // Use searchMessage if provided, otherwise fall back to channel preview
    if (searchMessage != null) {
      // Handle search message display
      if (searchMessage!.isDeleted == true) {
        previewText = context.l10n.chat_message_deleted;
        previewIcon = SvgPicture.asset(
          'assets/Icons/amity_ic_preview_deleted_message.svg',
          package: 'amity_uikit_beta_service',
          width: 18,
          height: 18,
          color: token(AmityColorToken.iconListDescriptionGeneral),
        );
      } else {
        final messageData = searchMessage!.data;
        if (messageData is MessageTextData) {
          previewText = messageData.text;
        } else if (messageData is MessageImageData) {
          previewText = context.l10n.chat_message_photo;
          previewIcon = SvgPicture.asset(
            'assets/Icons/amity_ic_preview_image_message.svg',
            package: 'amity_uikit_beta_service',
            width: 18,
            height: 20,
            color: token(AmityColorToken.iconListDescriptionGeneral),
          );
        } else if (messageData is MessageVideoData) {
          previewText = context.l10n.chat_message_video_sent;
          previewIcon = SvgPicture.asset(
            'assets/Icons/amity_ic_preview_video_message.svg',
            package: 'amity_uikit_beta_service',
            width: 18,
            height: 20,
            color: token(AmityColorToken.iconListDescriptionGeneral),
          );
        } else if (messageData is MessageFileData ||
            messageData is MessageAudioData) {
          previewText = context.l10n.chat_message_no_preview;
        } else if (messageData is MessageCustomData) {
          previewText = messageData.rawData.toString();
        } else {
          previewText = context.l10n.chat_message_no_content;
        }
      }
    } else {
      // Handle channel preview message display (original logic)
      if (channel.messagePreview?.isDeleted == true) {
        previewText = context.l10n.chat_message_deleted;
        previewIcon = SvgPicture.asset(
          'assets/Icons/amity_ic_preview_deleted_message.svg',
          package: 'amity_uikit_beta_service',
          width: 18,
          height: 18,
          color: token(AmityColorToken.iconListDescriptionGeneral),
        );
      } else {
        final previewMessage = channel.messagePreview?.data;
        if (previewMessage is MessageTextData) {
          previewText = previewMessage.text;
        } else if (previewMessage is MessageImageData) {
          previewText = context.l10n.chat_message_photo_sent;
          previewIcon = SvgPicture.asset(
            'assets/Icons/amity_ic_preview_image_message.svg',
            package: 'amity_uikit_beta_service',
            width: 18,
            height: 20,
            color: token(AmityColorToken.iconListDescriptionGeneral),
          );
        } else if (previewMessage is MessageVideoData) {
          previewText = context.l10n.chat_message_video;
          previewIcon = SvgPicture.asset(
            'assets/Icons/amity_ic_preview_video_message.svg',
            package: 'amity_uikit_beta_service',
            width: 18,
            height: 20,
            color: token(AmityColorToken.iconListDescriptionGeneral),
          );
        } else if (previewMessage is MessageFileData ||
            previewMessage is MessageAudioData) {
          // To be implement
          previewText = context.l10n.chat_message_no_preview;
        } else if (previewMessage is MessageCustomData) {
          previewText = previewMessage.rawData.toString();
        } else {
          previewText = context.l10n.chat_no_message_yet;
        }
      }
    }
    if (channel.amityChannelType == AmityChannelType.COMMUNITY) {
      String displayName = channel.displayName ?? "";
      
      // Only highlight channel name if NOT in search message mode
      if (searchQuery.isNotEmpty && searchMessage == null && _hasExactWordMatch(displayName, searchQuery)) {
        displayNameWidget = Row(
          children: [
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: _buildHighlightedNameTextSpan(displayName, searchQuery),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              "(${(channel.memberCount ?? 0).formattedCompactString()})",
              style: AmityTextStyle.caption(
                  token(AmityColorToken.textListSubheadDefaultDefault)),
            ),
          ],
        );
      } else {
        displayNameWidget = Row(
          children: [
            Flexible(
              child: Text(
                displayName,
                style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textListHeaderDefaultDefault)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              "(${(channel.memberCount ?? 0).formattedCompactString()})",
              style: AmityTextStyle.caption(
                  token(AmityColorToken.textListSubheadDefaultDefault)),
            ),
          ],
        );
      }
    } else {
      var displayName = channelMember?.user?.displayName;

      if (_isCounterpartDeleted) {
        displayName = context.l10n.user_profile_deleted_name;
      } else if (displayName == null || displayName.isEmpty) {
        // Android's fallback while there is no member to name: the channel's
        // own display name, then the generic placeholder.
        final channelName = channel.displayName;
        displayName = (channelName != null && channelName.isNotEmpty)
            ? channelName
            : context.l10n.user_profile_unknown_name;
      }

      // Only highlight channel name if NOT in search message mode
      if (searchQuery.isNotEmpty && searchMessage == null && _hasExactWordMatch(displayName, searchQuery)) {
        displayNameWidget = RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: _buildHighlightedNameTextSpan(displayName, searchQuery),
        );
      } else {
        displayNameWidget = Text(
          displayName,
          style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textListHeaderDefaultDefault)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    // A message-search result is a shorter, single-line row than the chat-list row.
    final isSearchResult = searchMessage != null;

    return Container(
      // A minimum, not a fixed height: the trailing column's fallback font
      // metrics can run a pixel over 46, which a fixed 62 turned into a
      // RenderFlex overflow on every search-result row.
      constraints: BoxConstraints(minHeight: isSearchResult ? 62 : 82),
      // Opaque row surface, so the swipe action stays hidden behind the row.
      color: token(AmityColorToken.surfaceListDefaultDefault),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (channel.amityChannelType == AmityChannelType.COMMUNITY)
            AmityChannelAvatar.withChannel(
              channel: channel,
              avatarSize: const Size(40, 40),
              showPrivateBadge: (channel.isPublic == false),
            )
          else
            AmityChatAvatar(
                channelMember: channelMember,
                isDeleted: _isCounterpartDeleted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: displayNameWidget),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (previewIcon != null) ...[
                      previewIcon,
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: _buildPreviewText(previewText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isSearchResult ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(channel.lastActivity?.toChatTimestamp(context) ?? "",
                  style: AmityTextStyle.caption(
                      token(AmityColorToken.textListTrailingSubtextDefault))),
              SizedBox(height: isSearchResult ? 4 : 10),
              if (isSearchResult)
                // The badge slot stays empty on a search result, but the layout keeps its space.
                const SizedBox(width: 52, height: 24)
              else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isArchived) ...[
                    Container(
                      padding: const EdgeInsets.only(left: 4, right: 6, top: 3.5, bottom: 3.5),
                      decoration: BoxDecoration(
                        color: token(
                            AmityColorToken.surfaceBadgeSemanticBadgeChatArchived),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/Icons/amity_ic_search_chat_archive_badge.svg',
                            package: 'amity_uikit_beta_service',
                            width: 12,
                            height: 12,
                            colorFilter: ColorFilter.mode(
                              token(AmityColorToken
                                  .iconBadgeSemanticBadgeChatArchivedDefault),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            context.l10n.chat_archived_label,
                            style: AmityTextStyle.captionSmall(token(
                                AmityColorToken.textBadgeSemanticBadgeChatArchivedDefault)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (channel.isMentioned == true) ...[
                    mentionIndicatorWidget(),
                    const SizedBox(width: 4),
                  ],
                  unreadCountWidget(channel.unreadCount ?? 0),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The un-matched part of a preview — search result or plain row — stays
  /// Regular on the Default token; only the matched runs carry the Highlight
  /// token's bolder weight (see [_buildHighlightedTextSpan]). Styling the whole
  /// snippet as Highlight made the match indistinguishable from its context.
  TextStyle _previewStyle() => AmityTextStyle.body(
      token(AmityColorToken.textListTextDescriptionDefaultDefault));

  Widget _buildPreviewText(String? previewText) {
    final maxPreviewLines = searchMessage != null ? 1 : 2;

    if (previewText == null || previewText.isEmpty) {
      return Text(
        "",
        style: _previewStyle(),
        maxLines: maxPreviewLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // If we have a search query and this is from a search message, highlight it
    if (searchQuery.isNotEmpty && searchMessage != null && _hasExactWordMatch(previewText, searchQuery)) {
      return RichText(
        maxLines: maxPreviewLines,
        overflow: TextOverflow.ellipsis,
        text: _buildHighlightedTextSpan(previewText, searchQuery),
      );
    } else {
      return Text(
        previewText,
        style: _previewStyle(),
        maxLines: maxPreviewLines,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  List<int> _findExactWordMatches(String text, String query) =>
      findCaseInsensitiveMatches(text, query);

  /// Helper method to check if text contains exact word matches
  bool _hasExactWordMatch(String text, String query) {
    return _findExactWordMatches(text, query).isNotEmpty;
  }

  /// Builds a TextSpan with exact word matches highlighted
  /// Only highlights matches that start with the query (at beginning or after space)
  /// Optimized for 2-line display by limiting search scope
  TextSpan _buildHighlightedTextSpan(String text, String query) {
    // Performance optimization: Estimate max characters that can fit in 2 lines
    // Assuming roughly 40 characters per line on average mobile screen
    const int maxCharsForTwoLines = 80;
    
    // Truncate text if it's too long to prevent heavy processing
    String searchableText = text.length > maxCharsForTwoLines 
        ? text.substring(0, maxCharsForTwoLines) 
        : text;
    
    // Find all exact word matches
    final matches = _findExactWordMatches(searchableText, query);
    
    if (matches.isEmpty) {
      return TextSpan(
        text: searchableText,
        style: _previewStyle(),
      );
    }
    
    List<TextSpan> spans = [];
    int currentIndex = 0;
    
    // Build spans with highlighted matches
    for (int matchIndex in matches) {
      // Add text before the match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: searchableText.substring(currentIndex, matchIndex),
          style: _previewStyle(),
        ));
      }
      
      // Add the highlighted match
      spans.add(TextSpan(
        text: searchableText.substring(matchIndex, matchIndex + query.length),
        style: AmityTextStyle.bodyBold(
            token(AmityColorToken.textListTextDescriptionDefaultHighlight)),
      ));
      
      currentIndex = matchIndex + query.length;
    }
    
    // Add remaining text after the last match
    if (currentIndex < searchableText.length) {
      spans.add(TextSpan(
        text: searchableText.substring(currentIndex),
        style: _previewStyle(),
      ));
    }
    
    // If we truncated the original text, add ellipsis indication
    if (text.length > maxCharsForTwoLines) {
      spans.add(TextSpan(
        text: "...",
        style: _previewStyle(),
      ));
    }
    
    return TextSpan(children: spans);
  }

  /// Builds a TextSpan for channel names with exact word matches highlighted
  /// Only highlights matches that start with the query (at beginning or after space)
  TextSpan _buildHighlightedNameTextSpan(String text, String query) {
    // Find all exact word matches
    final matches = _findExactWordMatches(text, query);
    
    if (matches.isEmpty) {
      return TextSpan(
        text: text,
        style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textListHeaderDefaultDefault)),
      );
    }
    
    List<TextSpan> spans = [];
    int currentIndex = 0;
    
    // Build spans with highlighted matches
    for (int matchIndex in matches) {
      // Add text before the match
      if (matchIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, matchIndex),
          style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textListHeaderDefaultDefault)),
        ));
      }
      
      // Add the highlighted match
      spans.add(TextSpan(
        text: text.substring(matchIndex, matchIndex + query.length),
        style: AmityTextStyle.titleBold(
            token(AmityColorToken.textListHeaderDefaultHighlight)),
      ));
      
      currentIndex = matchIndex + query.length;
    }
    
    // Add remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: AmityTextStyle.titleBold(
                    token(AmityColorToken.textListHeaderDefaultDefault)),
      ));
    }
    
    return TextSpan(children: spans);
  }

  Widget mentionIndicatorWidget() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: token(AmityColorToken.surfaceBadgeSemanticBadgeChatMention),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_chat_room_mention.svg',
          package: 'amity_uikit_beta_service',
          width: 14,
          height: 14,
          color:
              token(AmityColorToken.iconBadgeSemanticBadgeChatMentionDefault),
        ),
      ),
    );
  }

  Widget unreadCountWidget(int unreadCount) {
    if (unreadCount == 0 && channel.hasMention != true) {
      return const SizedBox.shrink();
    }

    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        // The unread count is a notification badge, not a generic atomic one.
        // Android binds Surface/Badge/SemanticBadge/General/Notification here
        // (AmityChatListItem.kt: AmityBadgePreset(GENERAL, "Notification")),
        // which follows alert_color; the atomic tier follows primary_color, so
        // the badge came out blue instead of red.
        color: token(
            AmityColorToken.surfaceBadgeSemanticBadgeGeneralNotification),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: AmityTextStyle.caption(token(
            AmityColorToken.textBadgeSemanticBadgeGeneralDefaultDefault)),
      ),
    );
  }
}

class AmityChatAvatar extends BaseElement {
  final AmityChannelMember? channelMember;
  final String avatarPlaceholder =
      "assets/Icons/amity_ic_user_avatar_placeholder.svg";

  late final String? avatarUrl;
  late final bool isDeletedUser;
  late final String displayName;

  AmityChatAvatar(
      {required this.channelMember,
      required bool isDeleted,
      super.key,
      super.pageId = "",
      super.componentId = "",
      super.elementId = "chat-avatar"}) {
    avatarUrl = channelMember?.user?.avatarUrl;
    // Decided by the row, which knows whether the member lookup has resolved;
    // `channelMember?.isDeleted ?? true` here drew every not-yet-loaded row
    // as a deleted user.
    isDeletedUser = isDeleted;
    displayName = channelMember?.user?.displayName ?? "";
  }

  bool get _isModerator {
    final roles = channelMember?.roles?.roles ?? const <String>[];
    return roles.contains('moderator') ||
        roles.contains('community-moderator') ||
        roles.contains('channel-moderator');
  }

  @override
  Widget buildElement(BuildContext context) {
    Widget avatarWidget;

    if (isDeletedUser) {
      // Avatar atom, Icon type: `Surface/Avatar/Profile/Default` disc with the
      // solid `user-s` glyph on `Icon/Avatar/Default` — solid weight is what
      // marks deletion apart from the regular no-photo fallback.
      avatarWidget = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: token(AmityColorToken.surfaceAvatarProfileDefault),
          border: Border.all(
            color: token(AmityColorToken.borderAvatarProfileDefault),
            width: 2,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/Icons/amity_ic_user_s.svg",
            package: 'amity_uikit_beta_service',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
                token(AmityColorToken.iconAvatarDefault), BlendMode.srcIn),
          ),
        ),
      );
    } else {
      final isAvatarAvailable = avatarUrl != null && avatarUrl!.isNotEmpty;
      if (isAvatarAvailable) {
        avatarWidget = Container(
          width: 40,
          height: 40,
          // The profile ring is drawn over the photo edge so the avatar keeps its 40 pt slot.
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: token(AmityColorToken.borderAvatarProfileDefault),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return SvgPicture.asset(
                    avatarPlaceholder,
                    package: 'amity_uikit_beta_service',
                  );
                }
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return avatarCharacter();
              },
            ),
          ),
        );
      } else {
        avatarWidget = avatarCharacter();
      }
    }

    if (!_isModerator) {
      return avatarWidget;
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: token(AmityColorToken
                    .surfaceBadgeSemanticBadgeUserStatusModerator),
                border: Border.all(
                  color: token(AmityColorToken.borderAvatarProfileDefault),
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_community_moderator.svg',
                  package: 'amity_uikit_beta_service',
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    token(AmityColorToken
                        .iconBadgeSemanticBadgeUserStatusModeratorDefault),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget avatarCharacter() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: token(AmityColorToken.surfaceAvatarProfileDefault),
        shape: BoxShape.circle,
        border: Border.all(
          color: token(AmityColorToken.borderAvatarProfileDefault),
          width: 2,
        ),
      ),
      child: Center(
          child: Text(
        displayName.isEmpty ? "" : displayName[0].toUpperCase(),
        style: AmityTextStyle.custom(20, FontWeight.w400, Colors.white),
      )),
    );
  }
}

enum ChatListType {
  CONVERSATION,
  ARCHIVED,
}
