import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityUIConfiguration extends ChangeNotifier {
  var appColors = AppColors();
  Color get primaryColor => appColors.primary;

  IconData placeHolderIcon = Icons.chat;
  Color displaynameColor = Colors.black;
  AmityIconConfig iconConfig = AmityIconConfig();
  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();
  // Color userProfileBGColor = Colors.white;
  // Color userProfileTextColor = Colors.black;
  // Color userProfileIconColor = Colors.grey;
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 17,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );
  double textheight = 1.2;
  TextStyle hintTextStyle = const TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w400,
  );

  void updateUI() {
    notifyListeners();
  }
}

class AppColors {
  final Color primary;
  // final Color primaryShade1;
  // final Color primaryShade2;
  final Color primaryShade3;
  // final Color primaryShade4;

  final Color base;
  // final Color baseInverse;
  // final Color baseDefault;
  // final Color baseShade1;
  // final Color baseShade2;
  // final Color baseShade3;
  final Color baseShade4;
  final Color baseBackground;

  // final Color secondaryDefault;
  // final Color secondaryShade1;
  // final Color secondaryShade2;
  // final Color secondaryShade3;
  // final Color secondaryShade4;

  // final Color alert;

  // final Color actionButton;
  // final Color hyperlink;
  // final Color highlight;

  //addditional
  final userProfileBGColor;
  final userProfileTextColor;
  final userProfileIconColor;

  AppColors({
    this.primary = const Color(0xFF1054de),
    // this.primaryShade1 = const Color(0xFF4a82f2),
    // this.primaryShade2 = const Color(0xFFa0bd8f),
    this.primaryShade3 = const Color(0xFFd9e5fc),
    // this.primaryShade4 = const Color(0xFFFFFFFF),
    this.base = const Color(0xFF000000),
    // this.baseInverse = const Color(0xFFFFFFFF),
    // this.baseDefault = const Color(0xFF292b32),
    // this.baseShade1 = const Color(0xFF636878),
    // this.baseShade2 = const Color(0xFF8989e9),
    // this.baseShade3 = const Color(0xFFa5a9b5),
    this.baseShade4 = const Color(0xFFebecef),
    this.baseBackground = const Color(0xFFFFFFFF),
    this.userProfileBGColor = const Color(0xFFFFFFFF),
    this.userProfileTextColor = const Color(0xff898E9E),
    this.userProfileIconColor = const Color(0xff898E9E),
    // this.secondaryDefault = const Color(0xFF292632),
    // this.secondaryShade1 = const Color(0xFF636878),
    // this.secondaryShade2 = const Color(0xFF8989e9),
    // this.secondaryShade3 = const Color(0xFFa5a9b5),
    // this.secondaryShade4 = const Color(0xFFebecef),
    // this.alert = const Color(0xFFfa4d30),
    // this.actionButton = const Color(0x80000000), // 50% opacity
    // this.hyperlink = const Color(0xCCFFFFFF), // 80% opacity
    // this.highlight = const Color(0xFF1054de),
  });
}

class AmityIconConfig {
  Widget likeIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/like.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget commentIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/comment.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget officialIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/Checkmark.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget shareIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/share.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget replyIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/reply.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget postIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/post.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget editIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/edit.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }

  Widget likedIcon(
      {double iconSize = 16,
      Color color = Colors.grey,
      BlendMode blendmode = BlendMode.srcIn}) {
    return SvgPicture.asset(
      "assets/Icons/liked.svg",
      height: iconSize,
      colorFilter: ColorFilter.mode(color, blendmode),
      package: 'amity_uikit_beta_service',
    );
  }
}

class ChannelListConfig {
  Color cardColor = Colors.white;
  Color backgroundColor = Colors.grey[200]!;
  Color latestMessageColor = Colors.grey[500]!;
  Color latestTimeColor = Colors.grey[500]!;
  Color channelDisplayname = Colors.black;
}

class MessageRoomConfig {
  Color backgroundColor = Colors.white;
  Color appbarColor = Colors.white;
  Color textFieldBackGroundColor = Colors.white;
  Color textFieldHintColor = Colors.grey[500]!;
}
