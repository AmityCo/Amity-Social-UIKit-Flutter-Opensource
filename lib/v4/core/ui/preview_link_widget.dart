import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/utils/processed_text_cache.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviewLinkWidget extends StatefulWidget {
  final String text;
  final AmityThemeColor theme;
  final VoidCallback? onTap;

  PreviewLinkWidget({
    Key? key,
    required this.text,
    required this.theme,
    this.onTap,
  }) : super(key: key);

  final _getText =
      AmityUIKit4Manager.freedomBehavior.localizationBehavior.getText;
  final LaunchMode urlLaunchMode = AmityUIKit4Manager
      .freedomBehavior.postContentComponentBehavior.urlLaunchMode;

  @override
  State<PreviewLinkWidget> createState() => _PreviewLinkWidgetState();
}

class _PreviewLinkWidgetState extends State<PreviewLinkWidget> {
  Metadata? _metadata;
  String? _url;
  bool _isLoading = true;
  final ProcessedTextCache _textCache = ProcessedTextCache();

  @override
  void initState() {
    super.initState();

    if (widget.text.isNotEmpty) {
      // Check if the URL is already cached
      // If it is, then we can directly use it
      // Hacky: If it is not, then we will wait for the cache to be updated by the background process in Expandable Text
      final urlFromCache = extractUrlFromCache();
      if (urlFromCache != null) {
        _url = urlFromCache;
        _fetchMetadataInBackground(_url!);
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          _url = extractUrlFromCache();

          if (_url != null) {
            _fetchMetadataInBackground(_url!);
          }
        });
      }
    }
  }

  String? extractUrlFromCache() {
    if (_textCache.contains(widget.text)) {
      final entities = _textCache.get(widget.text);
      if (entities != null && entities.isNotEmpty) {
        try {
          final urlEntities = entities.where((element) =>
              element['type'] == 'url' && element.containsKey('text'));

          if (urlEntities.isNotEmpty) {
            return urlEntities.first['text'] as String?;
          }
        } catch (e) {
          debugPrint('Error extracting URL from cache: $e');
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
      final metadata = await AnyLinkPreview.getMetadata(link: link);
      if (mounted) {
        setState(() {
          _metadata = metadata;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_url == null) {
      return Container();
    }

    if (_isLoading && _metadata == null) {
      return _skeletonLoadingWidget();
    }

    return GestureDetector(
      onTap: widget.onTap ?? _launchUrl,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.theme.baseColorShade4,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior:
            Clip.antiAlias, // To ensure the image respects the border radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            SizedBox(
              height: 178,
              child: _buildHeaderImage(),
            ),
            _getDividerWidget(),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _contentWidget()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (_metadata != null && _metadata!.image != null) {
      return Image.network(
        _metadata!.image!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(false);
        },
      );
    } else {
      return _buildPlaceholderImage(true);
    }
  }

  Widget _buildPlaceholderImage(bool showError) {
    return Container(
      color: widget.theme.baseColorShade4,
      child: Center(
        child: SvgPicture.asset(
          showError
              ? 'assets/Icons/amity_ic_exclamation_triangle.svg'
              : 'assets/Icons/ic_gallery_white.svg',
          package: 'amity_uikit_beta_service',
          width: 44,
          height: 32,
          colorFilter: ColorFilter.mode(
            widget.theme.baseColorShade3, // Use black color
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  List<Widget> _contentWidget() {
    if (_metadata == null) {
      return [
        Text(
          widget._getText(
                  context, 'community_posts_preview_not_available_title') ??
              'Preview not available',
          style: AmityTextStyle.bodyBold(widget.theme.baseColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          widget._getText(
                  context, 'community_posts_preview_not_available_desc') ??
              'Please make sure the URL is correct and try again.',
          style: AmityTextStyle.body(widget.theme.baseColorShade2),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
      ];
    } else {
      return [
        Text(
          _url ?? '',
          style: AmityTextStyle.caption(widget.theme.baseColorShade2),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        if (_metadata?.title != null && _metadata!.title!.isNotEmpty)
          Text(
            _metadata?.title ?? '',
            style: AmityTextStyle.bodyBold(widget.theme.baseColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
      ];
    }
  }

  Widget _skeletonLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.theme.baseColorShade4,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 178,
            decoration: BoxDecoration(
              color: widget.theme.baseColorShade4,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          _getDividerWidget(),
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SkeletonRectangle(
                width: 239,
                height: 11,
              ),
              const SizedBox(height: 4),
              SkeletonRectangle(width: 176, height: 11),
              const SizedBox(height: 8),
            ]),
          ),
        ],
      ),
    );
  }

  void _launchUrl() async {
    if (_url != null) {
      String link = _url!;
      if (!_url!.startsWith("http")) {
        link = "https://$_url";
      }
      Uri uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: widget.urlLaunchMode);
      }
    }
  }

  Widget _getDividerWidget() {
    return Padding(
        padding: EdgeInsets.zero,
        child: Divider(
          color: widget.theme.baseColorShade4,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          height: 1,
        ));
  }
}
