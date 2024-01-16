import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityUIConfiguration extends ChangeNotifier {
  Color primaryColor = const Color(0xFF1054DE);
  IconData placeHolderIcon = Icons.chat;
  Color displaynameColor = Colors.black;
  AmityIconConfig iconConfig = AmityIconConfig();
  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();

  TextStyle titleTextStyle = const TextStyle(
    fontSize: 17,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  TextStyle hintTextStyle = const TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w400,
  );

  void updateUI() {
    notifyListeners();
  }
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
