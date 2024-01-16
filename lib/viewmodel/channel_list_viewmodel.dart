import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/alert_dialog.dart';
import '../model/amity_channel_model.dart';
import '../repository/chat_repo_imp.dart';
import '../utils/navigation_key.dart';
import 'user_viewmodel.dart';

class ChannelVM extends ChangeNotifier {
  ScrollController? scrollController = ScrollController();
  AmityChatRepoImp channelRepoImp = AmityChatRepoImp();
  final List<Channels> _amityChannelList = [];
  Channels? amitySingleChannel;
  Map<String, ChannelUsers> channelUserMap = {};
  List<Channels> getChannelList() {
    return _amityChannelList;
  }

  Future<void> initVM() async {
    log("initVM");
    var accessToken = Provider.of<UserVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .accessToken;

    if (accessToken != null) {
      await channelRepoImp.initRepo(accessToken);
      await channelRepoImp.listenToChannel((messages) {
        ///get channel where channel id == new message channelId
        var channel = _amityChannelList.firstWhere((amityMessage) =>
            amityMessage.channelId == messages.messages?[0].channelId);
        log("${channel.channelId} got new message from ${messages.messages![0].userId}");
        channel.lastActivity = messages.messages![0].createdAt;

        channel.setLatestMessage(
            messages.messages![0].data!.text ?? "Not Text message: 📷");

        if (messages.messages![0].userId !=
            AmityCoreClient.getCurrentUser().userId) {
          ///add unread count by 1
          channel.setUnreadCount(channel.unreadCount + 1);
        }

        //move channel to the top
        _amityChannelList.remove(channel);
        _amityChannelList.insert(0, channel);
        notifyListeners();
      });

      await channelRepoImp.listenToChannelList((channel) {
        _amityChannelList.insert(0, channel);
        notifyListeners();
      });

      await refreshChannels();
    } else {
      log("accessToken is null");
    }
  }

  Future<void> refreshChannels() async {
    log("refreshChannels...");
    await channelRepoImp.fetchChannelsList((data, error) async {
      if (error == null && data != null) {
        _amityChannelList.clear();

        _addUnreadCountToEachChannel(data);

        if (data.channels != null) {
          for (var channel in data.channels!) {
            _addLatestMessage(channel);
            _amityChannelList.add(channel);
            String key =
                channel.channelId! + AmityCoreClient.getCurrentUser().userId!;
            if (channelUserMap[key] != null) {
              var count =
                  channel.messageCount! - channelUserMap[key]!.readToSegment!;
              channel.setUnreadCount(count);
            }
          }
        }
      } else {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error!);
      }

      notifyListeners();
    });
  }

  Future<void> initSingleChannel(
    String channelId,
  ) async {
    var accessToken = Provider.of<UserVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .accessToken;
    if (accessToken != null) {
      await channelRepoImp.initRepo(accessToken);
      await channelRepoImp.getChannelById(
        channelId: channelId,
        callback: (data, error) async {
          if (data != null) {
            log(">>>>>>>>>>>>>${data.channels![0].channelId}");
            amitySingleChannel = data.channels!.first;
            notifyListeners();
          } else {
            await AmityDialog()
                .showAlertErrorDialog(title: "Error!", message: error!);
          }
        },
      );
    } else {
      log("accessToken is null");
    }
  }

  Future<void> _addLatestMessage(Channels channel) async {
    await channelRepoImp.fetchChannelById(
      channelId: channel.channelId!,
      limit: 1,
      callback: (data, error) {
        if (data != null) {
          if (data.messages!.isNotEmpty) {
            var latestMessage =
                data.messages![0].data?.text ?? "Not Text message: 📷";
            log("get latest message from ${channel.channelId} as $latestMessage");
            channel.setLatestMessage(latestMessage);
            notifyListeners();
          } else {
            log("No latest message");
            channel.setLatestMessage("No message yet");
            notifyListeners();
          }
        } else {
          log("error from : _addLatestMessage => $error");
        }
      },
    );
  }

  Future<void> createGroupChannel(String displayName, List<String> userIds,
      Function(ChannelList? data, String? error) callback,
      {String? avatarFileId}) async {
    await channelRepoImp.createGroupChannel(displayName, userIds,
        (data, error) async {
      if (data != null) {
        log("createGroupChannel: success");
        callback(data, null);
      } else {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error!);
        callback(null, error);
      }
    }, avatarFileId: avatarFileId);
  }

  createConversationChannel(List<String> userIds,
      Function(ChannelList? data, String? error) callback) async {
    await channelRepoImp.createConversationChannel(userIds,
        (data, error) async {
      if (data != null) {
        log("createConversationChannel: success $data");

        callback(data, null);
      } else {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error!);
        callback(null, error);
      }
    });
  }

  void _addUnreadCountToEachChannel(ChannelList data) {
    for (var channelUser in data.channelUsers!) {
      channelUserMap[channelUser.channelId! + channelUser.userId!] =
          channelUser;
    }
    log("mapReadSegment complete");
  }

  void removeUnreadCount(String channelId) async {
    ///get channel where channel id == new message channelId

    try {
      if (_amityChannelList.isNotEmpty) {
        var channel = _amityChannelList
            .firstWhere((amityMessage) => amityMessage.channelId == channelId);

        ///set unread count = 0
        channel.setUnreadCount(0);

        notifyListeners();
      }
    } catch (error) {
      await AmityDialog()
          .showAlertErrorDialog(title: "Error!", message: error.toString());
      log(error.toString());
    }
  }
}
