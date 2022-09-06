import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AmityUIConfiguration extends ChangeNotifier {
  var primaryColor = Colors.grey;
  var placeHolderIcon = Icons.chat;
  var displaynameColor = Colors.black;
  ChannelListConfig channelListConfig = ChannelListConfig();
  MessageRoomConfig messageRoomConfig = MessageRoomConfig();

  void updateUI() {
    notifyListeners();
  }
}

class ChannelListConfig {
  var cardColor = Colors.white;
  var backgroundColor = Colors.grey[200];
  var latestMessageColor = Colors.grey[500];
  var latestTimeColor = Colors.grey[500];
  var channelDisplayname = Colors.black;
}

class MessageRoomConfig {
  var backgroundColor = Colors.white;
  var appbarColor = Colors.white;
  var textFieldBackGroundColor = Colors.white;
  var textFieldHintColor = Colors.grey[500];
}
