import 'package:flutter/material.dart';

import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:provider/provider.dart';

import '../viewmodel/configuration_viewmodel.dart';
import '../utils/env_manager.dart';

getAvatarImage(String? url, {double? radius, String? fileId}) {
  if (url != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl: "$url?size=medium",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Color(0xFFD9E5FC),
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else if (fileId != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundColor: Color(0xFFD9E5FC), backgroundImage: (imageProvider)),
      imageUrl:
          "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=medium",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: Color(0xFFD9E5FC),
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(0xFFD9E5FC),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: radius,
      ),
    );
  }
}

getNotificationAvatarImage(String? url, {double? radius, String? fileId}) {
  if (url != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl: "$url?size=small",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: AmityUIConfiguration().primaryColor,
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else if (fileId != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl:
          "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=small",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: AmityUIConfiguration().primaryColor,
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AmityUIConfiguration().primaryColor,
      child: const Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }
}

getCommuAvatarImage(String? url, {double? radius, String? fileId}) {
  if (url != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl: url,
      fit: BoxFit.fill,
      placeholder: (context, url) => const CommuPlaceHolderWidget(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else if (fileId != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl:
          "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=full",
      fit: BoxFit.fill,
      placeholder: (context, url) => const CommuPlaceHolderWidget(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else {
    return CommuPlaceHolderWidget(
      radius: radius,
    );
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

getNotificationImage(String? url, {double? radius, String? fileId}) {
  if (url != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl: "$url?size=full",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: AmityUIConfiguration().primaryColor,
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else if (fileId != null) {
    var imageOPS = OptimizedCacheImage(
      imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: (imageProvider)),
      imageUrl:
          "https://api.${env!.region}.amity.co/api/v3/files/$fileId/download?size=full",
      fit: BoxFit.fill,
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: AmityUIConfiguration().primaryColor,
        child: const Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    return imageOPS;
  } else {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AmityUIConfiguration().primaryColor,
      child: const Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }
}

getImageProvider(String? url) {
  if (url != null) {
    return NetworkImage(url);
  } else {
    return const AssetImage("assets/images/user_placeholder.png");
  }
}
