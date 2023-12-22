import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/alert_dialog.dart';
import '../../../utils/navigation_key.dart';
import '../../model/amity_channel_model.dart';
import '../model/amity_message_model.dart';
import '../repository/chat_repo_imp.dart';
import 'channel_list_viewmodel.dart';
import 'user_viewmodel.dart';

class MessageVM extends ChangeNotifier {
  //asd
  TextEditingController textEditingController = TextEditingController();
  ScrollController? scrollController =
      ScrollController(keepScrollOffset: false);
  AmityChatRepoImp channelRepoImp = AmityChatRepoImp();
  List<Messages>? amityMessageList;
  bool isChatLoading = true;
  late String channelId;
  bool ispaginationLoading = false;

  ///init
  Future<void> initVM(String channelId, Channels channel) async {
    this.channelId = channelId;
    isChatLoading = true;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });

    log("initVM");
    var accessToken = Provider.of<UserVM>(
            NavigationService.navigatorKey.currentContext!,
            listen: false)
        .accessToken;
    if (accessToken != null) {
      await channelRepoImp.initRepo(accessToken);
      await channelRepoImp.listenToChannel((messages) async {
        log(messages.messages![0].channelId.toString());
        log(channelId);
        if (messages.messages?[0].channelId == channelId) {
          log("get new messgae...: ${messages.messages?[0].data?.text}");
          amityMessageList?.add(messages.messages!.first);
          channel.messageCount = channel.messageCount! + 1;
          channel.setUnreadCount(channel.unreadCount - 1);
          if (messages.messages?[0].userId ==
              AmityCoreClient.getCurrentUser().userId) {
            scrollToBottom();
          }
        }

        notifyListeners();
      });

      channelRepoImp.fetchChannelById(
          channelId: channelId,
          callback: (data, error) async {
            if (error == null) {
              notifyListeners();
              scrollController?.addListener(() async {
                if (!ispaginationLoading) {
                  var currentMessageCount = amityMessageList!.length;
                  var totalMessageCount = channel.messageCount!;

                  if ((scrollController!.position.pixels ==
                          (scrollController!.position.maxScrollExtent)) &&
                      (currentMessageCount < totalMessageCount)) {
                    ispaginationLoading = true;

                    log("ispaginationLoading = false");
                    var token = data!.paging!.previous;

                    log("minScrollExtent");
                    await channelRepoImp.fetchChannelById(
                      channelId: channelId,
                      paginationToken: token,
                      callback: (pagingData, error) async {
                        if (error == null) {
                          log("paging data: $pagingData");

                          if (pagingData!.paging!.previous == null) {
                            scrollController!.removeListener(() {
                              removeListener(() {
                                log("remove listener");
                              });
                            });
                          } else {
                            data.paging!.previous = pagingData.paging!.previous;
                          }

                          var reversedMessage = pagingData.messages!.reversed;
                          for (var message in reversedMessage) {
                            log(message.data!.text.toString());
                            amityMessageList?.insert(0, message);
                          }
                          notifyListeners();
                          ispaginationLoading = false;
                        } else {
                          ispaginationLoading = false;
                          log(error);
                          await AmityDialog().showAlertErrorDialog(
                              title: "Error!", message: error);
                        }
                      },
                    );
                  } else {
                    log("pagination is not ready: $currentMessageCount/$totalMessageCount");
                  }
                }
              });
              amityMessageList = [];
              log("success");
              amityMessageList?.clear();
              for (var message in data!.messages!) {
                amityMessageList?.add(message);
              }
              scrollToBottom();

              channelRepoImp.startReading(
                channelId,
                callback: (data, error) {
                  if (error == null) {
                    log("set unread count = 0");
                    Provider.of<ChannelVM>(
                            NavigationService.navigatorKey.currentContext!,
                            listen: false)
                        .removeUnreadCount(channelId);
                  }
                },
              );

              notifyListeners();
            } else {
              log(error);
              await AmityDialog()
                  .showAlertErrorDialog(title: "Error!", message: error);
            }
          });
    } else {
      log("accessToken is null");
    }
  }

  Future<void> sendMessage() async {
    String text = textEditingController.text;
    textEditingController.clear();
    channelRepoImp.sendTextMessage(channelId, text, (data, error) async {
      if (data != null) {
        log("sendMessage: success");
      } else {
        log(error.toString());
        await AmityDialog()
            .showAlertErrorDialog(title: "Error!", message: error!);
      }
    });
  }

  void scrollToBottom() {
    log("scrollToBottom ");
    // scrollController!.animateTo(
    //   1000000,
    //   curve: Curves.easeOut,
    //   duration: const Duration(milliseconds: 500),
    // );
    scrollController?.jumpTo(0);
  }

  @override
  Future<void> dispose() async {
    await channelRepoImp.stopReading(channelId);

    channelRepoImp.disposeRepo();
    scrollController = null;
    amityMessageList?.clear();
    super.dispose();
  }
}
