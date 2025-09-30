import 'package:amity_uikit_beta_service/utils/processed_text_cache.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/message_color.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
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
    final imageWidth = bubbleWidth * 0.4; // Image is 40% of bubble width

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
                color: Colors.white,
                width: imageWidth,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    _metadata!.image!,
                    height: 96,
                    fit: BoxFit
                        .fitWidth, // Changed from cover to fill to stretch the image
                    errorBuilder: (context, error, stackTrace) {
                      // Show error icon instead of hiding the image section
                      return Container(
                        height: 96,
                        width: imageWidth,
                        color: widget.isUserMessage
                            ? widget.theme.primaryColor
                                .blend(ColorBlendingOption.shade1)
                            : widget.theme.backgroundShade1Color,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_message_preview_link_error.svg',
                            width: 18,
                            height: 18,
                            package: 'amity_uikit_beta_service',
                            color: widget.isUserMessage
                                ? widget.theme.primaryColor
                                    .blend(ColorBlendingOption.shade2)
                                : widget.theme.baseColorShade3,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Expanded(
              child: Container(
                height: 96,
                color: widget.messageColor != null
                    ? (widget.isUserMessage
                        ? widget.messageColor!.rightBubblePreviewLinkColor
                            .withOpacity(0.15)
                        : widget.messageColor!.leftBubblePreviewLinkColor)
                    : Colors.white,
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
                            widget.isUserMessage
                                ? Colors.white
                                : widget.theme.baseColor,
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
                        widget.isUserMessage
                            ? Colors.white
                            : widget.theme.baseColor,
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
    // Calculate dimensions for skeleton
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleWidth = screenWidth * 0.6; // Bubble is 60% of screen width
    final imageWidth = bubbleWidth * 0.4; // Image is 40% of bubble width

    return Shimmer(
      linearGradient: LinearGradient(
        colors: [
          widget.isUserMessage
              ? widget.theme.primaryColor.blend(ColorBlendingOption.shade1)
              : widget.theme.backgroundShade1Color,
          widget.isUserMessage
              ? widget.theme.primaryColor.blend(ColorBlendingOption.shade2)
              : widget.theme.backgroundShade1Color
                  .blend(ColorBlendingOption.shade2),
          widget.isUserMessage
              ? widget.theme.primaryColor.blend(ColorBlendingOption.shade1)
              : widget.theme.backgroundShade1Color,
        ],
        stops: const [
          0.1,
          0.3,
          0.4,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: bubbleWidth, // Use calculated bubble width
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // No background color here - we'll set it separately for each section
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            ShimmerLoading(
              isLoading: true,
              child: Container(
                height: 96,
                width: imageWidth, // Using calculated 40% of bubble width
                color: widget.isUserMessage
                    ? widget.theme.primaryColor
                        .blend(ColorBlendingOption.shade1)
                    : widget.theme.backgroundShade1Color,
              ),
            ),
            Expanded(
              child: Container(
                height: 96,
                color: widget.messageColor != null
                    ? (widget.isUserMessage
                        ? widget.messageColor!.rightBubblePreviewLinkColor
                            .withOpacity(0.15)
                        : widget.messageColor!.leftBubblePreviewLinkColor)
                    : Colors.white,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerLoading(
                      isLoading: true,
                      child: SkeletonText(
                        width: 80,
                        height: 8,
                        color: widget.isUserMessage
                            ? widget.theme.primaryColor
                                .blend(ColorBlendingOption.shade1)
                            : widget.theme.baseColorShade4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoading(
                      isLoading: true,
                      child: SkeletonText(
                        width: 54,
                        height: 8,
                        color: widget.isUserMessage
                            ? widget.theme.primaryColor
                                .blend(ColorBlendingOption.shade1)
                            : widget.theme.baseColorShade4,
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
    final imageWidth = bubbleWidth * 0.4; // Image is 40% of bubble width

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
            Container(
              height: 96,
              width: imageWidth,
              color: widget.isUserMessage
                  ? widget.theme.primaryColor.blend(ColorBlendingOption.shade1)
                  : widget.theme.backgroundShade1Color,
              child: Center(
                child: SvgPicture.asset(
                  'assets/Icons/amity_ic_message_preview_link_error.svg',
                  width: 18,
                  height: 18,
                  package: 'amity_uikit_beta_service',
                  color: widget.isUserMessage
                      ? widget.theme.primaryColor
                          .blend(ColorBlendingOption.shade2)
                      : widget.theme.baseColorShade3,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 96,
                color: widget.messageColor != null
                    ? (widget.isUserMessage
                        ? widget.messageColor!.rightBubblePreviewLinkColor
                            .withOpacity(0.15)
                        : widget.messageColor!.leftBubblePreviewLinkColor)
                    : Colors.white,
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Preview not available",
                        style: AmityTextStyle.captionBold(
                          widget.isUserMessage
                              ? Colors.white
                              : widget.theme.baseColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No display data",
                      style: AmityTextStyle.captionSmall(
                        widget.isUserMessage
                            ? Colors.white
                            : widget.theme.baseColor.withOpacity(0.8),
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
