import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../model/amity_channel_model.dart';
import '../model/amity_message_model.dart';
import '../model/amity_response_model.dart';
import '../utils/env_manager.dart';
import 'chat_repo.dart';

class AmityChatRepoImp implements AmityChatRepo {
  late Socket socket;

  @override
  Future<void> initRepo(String accessToken) async {
    log("initRepo...");
    socket = io.io('wss://api.${env!.region}.amity.co/?token=$accessToken',
        io.OptionBuilder().setTransports(["websocket"]).build());
    socket.onConnectError((data) => log("onConnectError:$data"));
    socket.onConnecting((data) => log("connecting..."));

    socket.onConnect((_) {
      log('connected');
    });

    socket.onDisconnect((data) => log("onDisconnect:$data"));
  }

  @override
  Future<void> fetchChannelById(
      {String? paginationToken,
      int? limit = 30,
      required String channelId,
      required Function(
        AmityMessage?,
        String?,
      ) callback}) async {
    log("fetchChannelById...");
    socket.emitWithAck('v3/message.query', {
      "channelId": channelId,
      "options": {"last": limit, "token": paginationToken}
    }, ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        var amityMessages = AmityMessage.fromJson(responsedata!.json!);

        callback(amityMessages, null);
      } else {
        //error

        callback(null, amityResponse.message);
      }
    });
  }

  @override
  Future<void> listenToChannel(Function(AmityMessage) callback) async {
    log("listenToChannelById...");
    socket.on('message.didCreate', (data) async {
      var messageObj = AmityMessage.fromJson(data);

      callback(messageObj);
    });
  }

  //   @override
  // Future<void> listenToChannelList(Function(AmityMessage) callback) async {
  //   log("listenToChannelById...");
  //   socket.on('channel.didCreate', (data) async {
  //     var messageObj = await AmityMessage.fromJson(data);

  //     callback(messageObj);
  //   });
  // }

  @override
  Future<void> reactMessage(String messageId) async {
    log("reactMessage...");
  }

  @override
  Future<void> sendImageMessage(String channelId, String text,
      Function(AmityMessage?, String?) callback) async {
    log("sendImageMessage...");
  }

  @override
  Future<void> sendTextMessage(String channelId, String text,
      Function(AmityMessage?, String?) callback) async {
    log("sendTextMessage...");
    log("fetchChannelById...");
    socket.emitWithAck('v3/message.create', {
      "channelId": channelId,
      "type": "text",
      "data": {"text": text}
    }, ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        log(responsedata!.json.toString());
        var amityMessages = AmityMessage.fromJson(responsedata.json!);

        callback(amityMessages, null);
      } else {
        //error
        callback(null, amityResponse.message);
      }
    });
  }

  void disposeRepo() {
    socket.clearListeners();
    socket.close();
  }

  Future<void> fetchChannelsList(
      Function(ChannelList? data, String? error) callback) async {
    log("fetchChannels...");
    socket.emitWithAck('v3/channel.query', {
      "filter": "member",
      "options": {
        "limit": 100,
      }
    }, ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        var amityChannels = ChannelList.fromJson(responsedata!.json!);

        callback(amityChannels, null);
      } else {
        //error
        callback(null, amityResponse.message);
      }
    });
  }

  Future<void> listenToChannelList(Function(Channels) callback) async {
    log("listenToChannelListUpdate...");
    socket.on('v3.channel.didCreate', (data) async {
      var channelObj = ChannelList.fromJson(data);

      callback(channelObj.channels![0]);
    });
  }

  Future<void> startReading(String channelId,
      {Function(String? data, String? error)? callback}) async {
    socket.emitWithAck('channel.startReading', {"channelId": channelId},
        ack: (data) async {
      var amityResponse = AmityResponse.fromJson(data);
      if (amityResponse.status == "success") {
        //success
        log("startReading: success");
        callback!("success", null);
      } else {
        //error
        log("startReading: error: ${amityResponse.message}");
        callback!(null, amityResponse.message);
      }
    });
  }

  Future<void> createGroupChannel(String displayName, List<String> userIds,
      Function(ChannelList? data, String? error) callback,
      {String? avatarFileId}) async {
    log("createChannels...");
    socket.emitWithAck('v3/channel.create', {
      "type": "community",
      "displayName": displayName,
      "avatarFileId": avatarFileId,
      "userIds": userIds
    }, ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        var amityChannel = ChannelList.fromJson(responsedata!.json!);
        callback(amityChannel, null);
      } else {
        //error
        callback(null, amityResponse.message);
      }
    });
  }

  Future<void> createConversationChannel(List<String> userIds,
      Function(ChannelList? data, String? error) callback) async {
    log("createChannels...");
    socket.emitWithAck('v3/channel.createConversation', {"userIds": userIds},
        ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        var amityChannel = ChannelList.fromJson(responsedata!.json!);
        callback(amityChannel, null);
      } else {
        //error
        callback(null, amityResponse.message);
      }
    });
  }

  Future<void> stopReading(String channelId,
      {Function(String? data, String? error)? callback}) async {
    socket.emitWithAck('channel.stopReading', {
      {"channelId": channelId}
    }, ack: (data) async {
      var amityResponse = AmityResponse.fromJson(data);
      if (amityResponse.status == "success") {
        //success
        log("stopReading: success");
        callback!("success", null);
      } else {
        //error
        log("stopReading: error: ${amityResponse.message}");
        callback!(null, amityResponse.message);
      }
    });
  }

  Future<void> markSeen(String channelId) async {
    socket.emitWithAck('v3/channel.maekSeen', {
      {"channelId": channelId, "readToSegment": 100}
    }, ack: (data) async {
      var amityResponse = AmityResponse.fromJson(data);
      if (amityResponse.status == "success") {
        //success
        log("merkSeen: success");
      } else {
        //error
        log("merkSeen: error: ${amityResponse.message}");
      }
    });
  }

  Future<void> getChannelById(
      {required String channelId,
      required Function(ChannelList? data, String? error) callback}) async {
    log("getChannelById...");
    socket.emitWithAck('v3/channel.get', {"channelId": channelId}, ack: (data) {
      var amityResponse = AmityResponse.fromJson(data);
      var responsedata = amityResponse.data;
      if (amityResponse.status == "success") {
        //success
        var channel = ChannelList.fromJson(responsedata!.json!);

        callback(channel, null);
      } else {
        //error

        callback(null, amityResponse.message);
      }
    });
  }
}
