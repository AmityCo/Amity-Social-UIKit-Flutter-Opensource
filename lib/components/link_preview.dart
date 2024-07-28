import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomLinkPreview extends StatelessWidget {
  final String url;

  const CustomLinkPreview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.375,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color:
              Provider.of<AmityUIConfiguration>(context).appColors.baseShade4,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: FutureBuilder<Metadata?>(
        future: AnyLinkPreview.getMetadata(link: url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.image != null)
                    Image.network(
                      data.image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text(
                      url,
                      style: style.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, bottom: 16.0, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.title != null)
                          Text(
                            data.title!,
                            style: style,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (data.desc != null)
                          Text(
                            data.desc!,
                            style: style.copyWith(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                  child: Text('Failed to load preview', style: style));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
