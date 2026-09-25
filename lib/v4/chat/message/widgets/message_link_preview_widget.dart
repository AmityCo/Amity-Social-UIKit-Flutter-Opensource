import 'package:amity_uikit_beta_service/v4/utils/processed_text_cache.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/message_color.dart';
import 'package:amity_uikit_beta_service/v4/core/config_repository.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_token_context.dart';
import 'package:amity_uikit_beta_service/v4/core/theme/amity_color_token.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays link previews specifically for chat messages
/// This is optimized for the chat message bubble UI
class MessageLinkPreviewWidget extends StatefulWidget {
  final String text;
  final AmityThemeColor theme;
  final VoidCallback? onTap;
  final bool
      isUserMessage; // To adapt UI based on whether it's a user message or not
  final MessageColor?
      messageColor; // Add messageColor for link preview backgrounds
  final ConfigProvider? configProvider; // Add configProvider from parent

  const MessageLinkPreviewWidget({
    Key? key,
    required this.text,
    required this.theme,
    this.onTap,
    this.isUserMessage = false,
    this.messageColor,
    this.configProvider,
  }) : super(key: key);

  @override
  State<MessageLinkPreviewWidget> createState() =>
      _MessageLinkPreviewWidgetState();
}

class _MessageLinkPreviewWidgetState extends State<MessageLinkPreviewWidget> {
  Metadata? _metadata;
  String? _url;
  bool _isLoading = true; // Track loading state
  bool _metadataFetchFailed = false;
  final ProcessedTextCache _textCache = ProcessedTextCache();

  @override
  void initState() {
    super.initState();
    _processText();
  }

  @override
  void didUpdateWidget(MessageLinkPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the text has changed, reset and process the new text
    if (widget.text != oldWidget.text) {
      // Clear previous state
      setState(() {
        _metadata = null;
        _url = null;
        _isLoading = true;
        _metadataFetchFailed = false;
      });

      // Process the new text
      _processText();
    }
  }

  void _processText() {
    if (widget.text.isNotEmpty) {
      // First try to get URL from text directly
      _extractUrlsFromText();

      if (_url == null) {
        // If no URL found directly, try from cache
        final urlFromCache = _extractUrlFromCache();
        if (urlFromCache != null) {
          _url = urlFromCache;
          _fetchMetadataInBackground(_url!);
        } else {
          // Check again after a small delay in case cache is updated elsewhere
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              _url = _extractUrlFromCache();
              if (_url != null) {
                _fetchMetadataInBackground(_url!);
              }
            }
          });
        }
      } else {
        _fetchMetadataInBackground(_url!);
      }
    }
  }

  void _extractUrlsFromText() {
    // Simple URL regex for direct extraction as a fallback
    final urlRegex = RegExp(r'https?:\/\/[^\s]+');
    final match = urlRegex.firstMatch(widget.text);
    if (match != null) {
      _url = match.group(0);
    }
  }

  String? _extractUrlFromCache() {
    if (_textCache.contains(widget.text)) {
      final entities = _textCache.get(widget.text);
      if (entities != null && entities.isNotEmpty) {
        try {
          final urlEntities = entities.where((element) =>
              element['type'] == 'url' && element.containsKey('text'));

          if (urlEntities.isNotEmpty) {
            final extractedUrl = urlEntities.first['text'] as String?;
            return extractedUrl;
          }
        } catch (e) {
          // Error extracting URL from cache
        }
      }
    }
    return null;
  }

  Future<void> _fetchMetadataInBackground(String url) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String link = url;
      if (!url.startsWith("http")) {
        link = "https://$url";
      }

      // Create a flag to track if the fetch completed or timed out
      bool isCompleted = false;

      // Create a timer to track timeout
      Future.delayed(const Duration(seconds: 5), () {
        // Only mark as failed if the fetch hasn't completed yet
        if (!isCompleted && mounted) {
          setState(() {
            _metadataFetchFailed = true;
            _isLoading = false;
          });
        }
      });

      try {
        // Attempt to fetch metadata
        final metadata = await AnyLinkPreview.getMetadata(link: link);
        isCompleted = true;

        // Only update the state if we're still mounted
        if (mounted) {
          setState(() {
            _metadata = metadata;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error getting link metadata: $e");
        // Error fetching metadata

        // Mark as completed to prevent timeout from triggering setState
        isCompleted = true;

        // Only update the state if we're still mounted
        if (mounted) {
          setState(() {
            _metadataFetchFailed = true;
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null) {
      return Container(); // No URL to preview
    }
    if (_isLoading) {
      // If still loading or metadata not available yet, show skeleton loader
      return _simpleSkeletonLoadingWidget();
    } else if (_metadataFetchFailed || _metadata == null) {
      // If metadata fetch failed, show a fallback preview
      return _buildFallbackPreview();
    }
    // Calculate dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleWidth = screenWidth * 0.6; // Bubble is 60% of screen width

    return GestureDetector(
      onTap: widget.onTap ?? _launchUrl,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: bubbleWidth, // Use calculated bubble width (60% of screen)
        ),
        decoration: BoxDecoration(
          // No border
          borderRadius: BorderRadius.circular(10),
          // No background color here - we'll set it separately for each section
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_metadata?.image != null)
              Container(
                color: context.amityToken(AmityColorToken.surfaceMediaImageLoading),
                width: _mediaHalfSize,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    _metadata!.image!,
                    width: _mediaHalfSize,
                    height: _mediaHalfSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Broken media falls back to the same placeholder half as
                      // the unavailable card.
                      return _brokenMediaHalf(context);
                    },
                  ),
                ),
              ),
            Expanded(
              child: Container(
                height: _mediaHalfSize,
                color: _infoPaneColor(context),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_metadata?.title != null &&
                        _metadata!.title!.isNotEmpty)
                      Flexible(
                        child: Text(
                          _metadata!.title!,
                          style: AmityTextStyle.captionBold(
                            context.amityToken(AmityColorToken.textCardPreviewLinkTitleDefault),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (_metadata?.title != null &&
                        _metadata!.title!.isNotEmpty)
                      const SizedBox(height: 2),
                    Text(
                      _getDisplayHost(_url!),
                      style: AmityTextStyle.captionSmall(
                        context.amityToken(AmityColorToken.textCardPreviewLinkDomainDefault),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleSkeletonLoadingWidget() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleWidth = screenWidth * 0.6; // Bubble is 60% of screen width

    // Only the two bars shimmer. The panes behind them are static, which is
    // the whole point of this state: Android says it outright in
    // AmityChatLinkPreview.kt:241 — the info pane is "the
    // Surface/Card/PreviewLink/Skeleton pane with two shimmer bars ... NOT a
    // solid block".
    //
    // This used to wrap the entire card in Shimmer and put ShimmerLoading on
    // both panes. ShimmerLoading shader-masks its child, so the gradient
    // painted over everything — and the gradient itself was flat, because it
    // interpolated Surface/Card/PreviewLink/Default to
    // Surface/Card/PreviewLink/Skeleton and both resolve to the same
    // #636878. The result was one uniform slab with no bars and no sweep,
    // which is what QA saw (PDT-5146).
    return Shimmer(
      linearGradient: ConfigRepository().getShimmerGradient(),
      child: Container(
        constraints: BoxConstraints(maxWidth: bubbleWidth),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Media half: the media-loading surface with the spinner over it,
            // no shimmer mask (Android: "no extra overlay").
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: _mediaHalfSize,
                  width: _mediaHalfSize,
                  color: context
                      .amityToken(AmityColorToken.surfaceMediaImageLoading),
                ),
                // Chat-local media spinner (deliberately not the brand loader);
                // colors-v2 carries no semantic token for it yet.
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    backgroundColor: Color(0x33FFFFFF),
                  ),
                ),
              ],
            ),
            // Info pane: static skeleton surface carrying the two bars.
            Expanded(
              child: Container(
                height: _mediaHalfSize,
                color: context.amityToken(
                    AmityColorToken.surfaceCardPreviewLinkSkeleton),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 80x8 and 54x8 at r12, Surface/SkeletonEffect/Default —
                    // Android's numbers (AmityChatLinkPreview.kt:253-271).
                    ShimmerLoading(
                      isLoading: true,
                      child: SkeletonText(
                        width: 80,
                        height: 8,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        color: context.amityToken(
                            AmityColorToken.surfaceSkeletonEffectDefault),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoading(
                      isLoading: true,
                      child: SkeletonText(
                        width: 54,
                        height: 8,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        color: context.amityToken(
                            AmityColorToken.surfaceSkeletonEffectDefault),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a simple fallback preview when metadata fetch fails
  Widget _buildFallbackPreview() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleWidth = screenWidth * 0.6; // Bubble is 60% of screen width

    return GestureDetector(
      onTap: widget.onTap ?? _launchUrl,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: bubbleWidth, // Use calculated bubble width
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image placeholder with error icon
            _brokenMediaHalf(context),
            Expanded(
              child: Container(
                height: _mediaHalfSize,
                color: _infoPaneColor(context),
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Preview not available",
                        style: AmityTextStyle.captionBold(
                          context.amityToken(AmityColorToken.textCardPreviewLinkTitleDefault),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No display data",
                      style: AmityTextStyle.captionSmall(
                        context.amityToken(AmityColorToken.textCardPreviewLinkDomainDefault),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The card is a square media half beside an equally tall info pane.
  static const double _mediaHalfSize = 113;

  /// One info-pane surface for both directions; the direction only decides which
  /// config override key can replace it.
  Color _infoPaneColor(BuildContext context) {
    final override = widget.isUserMessage
        ? widget.messageColor?.rightBubblePreviewLinkColor
        : widget.messageColor?.leftBubblePreviewLinkColor;
    return override ??
        context.amityToken(AmityColorToken.surfaceCardPreviewLinkDefault);
  }

  /// Placeholder media half shared by the broken-image and unavailable cards.
  Widget _brokenMediaHalf(BuildContext context) {
    return Container(
      height: _mediaHalfSize,
      width: _mediaHalfSize,
      color: context.amityToken(AmityColorToken.surfaceMediaImageBroken),
      child: Center(
        child: SvgPicture.asset(
          'assets/Icons/amity_ic_message_preview_link_error.svg',
          width: 40,
          height: 40,
          package: 'amity_uikit_beta_service',
          color: context.amityToken(AmityColorToken.iconMediaImageBroken),
        ),
      ),
    );
  }

  /// Remove www. prefix from host for display purposes
  String _getDisplayHost(String url) {
    try {
      final uri = Uri.parse(url);
      String host = uri.host;
      if (host.startsWith('www.')) {
        host = host.substring(4); // Remove 'www.' prefix
      }
      return host;
    } catch (e) {
      // If URL parsing fails, return the original URL
      return url;
    }
  }

  void _launchUrl() async {
    if (_url != null) {
      String link = _url!;
      if (!_url!.startsWith("http")) {
        link = "https://$_url";
      }
      Uri uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Could not launch URL
      }
    }
  }
}
