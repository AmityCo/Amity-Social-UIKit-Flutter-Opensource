import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/env_manager.dart';
import '../viewmodel/configuration_viewmodel.dart';

Widget getAvatarImage(String? url, {double? radius = 20, String? fileId}) {
  return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD9E5FC),
      backgroundImage: url != null ? NetworkImage("$url?size=medium") : null,
      child: url != null
          ? const SizedBox()
          : Icon(
              Icons.person,
              color: Colors.white,
              size: radius! * 1.5,
            ));
}

Widget getNotificationAvatarImage(String? url,
    {double? radius, String? fileId}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: AmityUIConfiguration().primaryColor,
    backgroundImage: url != null
        ? NetworkImage("$url?size=small")
        : (fileId != null
            ? NetworkImage(
                "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=small")
            : const AssetImage("assets/images/user_placeholder.png",
                package: "amity_uikit_beta_service") as ImageProvider),
  );
}

Widget getCommuAvatarImage(String? url, {double? radius, String? fileId}) {
  if (url != null) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(url),
    );
  } else if (fileId != null) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(
        "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=full",
      ),
    );
  } else {
    return CommuPlaceHolderWidget(radius: radius);
  }
}

class CommuPlaceHolderWidget extends StatelessWidget {
  final double? radius;
  const CommuPlaceHolderWidget({
    Key? key,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Provider.of<AmityUIConfiguration>(context).primaryColor,
      child: Icon(
        Provider.of<AmityUIConfiguration>(context).placeHolderIcon,
        color: Colors.white,
      ),
    );
  }
}

Widget getNotificationImage(String? url, {double? radius, String? fileId}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: AmityUIConfiguration().primaryColor,
    backgroundImage: url != null
        ? NetworkImage("$url?size=full")
        : (fileId != null
            ? NetworkImage(
                "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=full")
            : const AssetImage("assets/images/user_placeholder.png",
                package: "amity_uikit_beta_service") as ImageProvider),
  );
}

ImageProvider<Object> getImageProvider(String? url) {
  if (url != null) {
    return NetworkImage(url);
  } else {
    return const AssetImage("assets/images/user_placeholder.png",
        package: "amity_uikit_beta_service");
  }
}
