import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomLinkPreview extends StatefulWidget {
  final String url;

  const CustomLinkPreview({super.key, required this.url});

  @override
  _CustomLinkPreviewState createState() => _CustomLinkPreviewState();
}

class _CustomLinkPreviewState extends State<CustomLinkPreview> {
  Metadata? _metadata;
  bool _isLoading = true;
  late String _displayUrl;

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
    _displayUrl = _getDisplayUrl(widget.url);
  }

  Future<void> _fetchMetadata() async {
    final metadata = await AnyLinkPreview.getMetadata(link: widget.url);
    if (mounted) {
      setState(() {
        _metadata = metadata;
        _isLoading = false;
      });
    }
  }

  String _getDisplayUrl(String url) {
    final uri = Uri.parse(url);
    String host = uri.host;
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }
    return host;
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    );

    return Container(
        child: _isLoading
            ? const SizedBox()
            : _metadata != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Provider.of<AmityUIConfiguration>(context)
                            .appColors
                            .baseShade4,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_metadata!.image != null)
                          Image.network(
                            _metadata!.image!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                          child: Text(
                            _displayUrl,
                            style: style.copyWith(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, bottom: 16.0, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_metadata!.title != null)
                                Text(
                                  _metadata!.title!,
                                  style: style,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (_metadata!.desc != null)
                                Text(
                                  _metadata!.desc!,
                                  style: style.copyWith(fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox());
  }
}
