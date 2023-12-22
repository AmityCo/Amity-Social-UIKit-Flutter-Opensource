import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/channel_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../components/custom_user_avatar.dart';
import '../../model/amity_channel_model.dart';
import '../../model/amity_message_model.dart';

class ChatSingleScreen extends StatelessWidget {
  final Channels channel;

  const ChatSingleScreen({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Provider.of<AmityUIConfiguration>(context)
          .messageRoomConfig
          .backgroundColor,
      leadingWidth: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.chevron_left,
                  color:
                      Provider.of<AmityUIConfiguration>(context).primaryColor,
                  size: 30)),
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: FadedScaleAnimation(
              child: getCommuAvatarImage(null, fileId: channel.avatarFileId),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              channel.displayName ?? "N/A",
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headline6!.copyWith(
                fontSize: 16.7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
    final bHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;

    const textfielHeight = 60.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: myAppBar,
      body: SafeArea(
        child: Stack(
          children: [
            FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: SingleChildScrollView(
                reverse: true,
                controller: Provider.of<MessageVM>(context, listen: false)
                    .scrollController,
                child: MessageComponent(
                  bheight: bHeight - textfielHeight,
                  theme: theme,
                  mediaQuery: mediaQuery,
                  channelId: channel.channelId!,
                  channel: channel,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ChatTextFieldComponent(
                    theme: theme,
                    textfielHeight: textfielHeight,
                    mediaQuery: mediaQuery),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatTextFieldComponent extends StatelessWidget {
  const ChatTextFieldComponent({
    Key? key,
    required this.theme,
    required this.textfielHeight,
    required this.mediaQuery,
  }) : super(key: key);

  final ThemeData theme;
  final double textfielHeight;
  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: theme.canvasColor,
          border: Border(top: BorderSide(color: theme.highlightColor))),
      height: textfielHeight,
      width: mediaQuery.size.width,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          // SizedBox(
          //   width: 5,
          // ),
          // Icon(
          //   Icons.emoji_emotions_outlined,
          //   color: theme.primaryIconTheme.color,
          //   size: 22,
          // ),
          const SizedBox(width: 10),
          SizedBox(
            width: mediaQuery.size.width * 0.7,
            child: TextField(
              controller: Provider.of<MessageVM>(context, listen: false)
                  .textEditingController,
              decoration: const InputDecoration(
                hintText: "Write your message",
                hintStyle: TextStyle(fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              Provider.of<MessageVM>(context, listen: false).sendMessage();
            },
            child: Icon(
              Icons.send,
              color: Provider.of<AmityUIConfiguration>(context).primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
    );
  }
}

class MessageComponent extends StatefulWidget {
  const MessageComponent({
    Key? key,
    required this.theme,
    required this.mediaQuery,
    required this.channelId,
    required this.bheight,
    required this.channel,
  }) : super(key: key);
  final String channelId;
  final Channels channel;

  final ThemeData theme;

  final MediaQueryData mediaQuery;

  final double bheight;

  @override
  State<MessageComponent> createState() => _MessageComponentState();
}

class _MessageComponentState extends State<MessageComponent> {
  @override
  void initState() {
    Provider.of<MessageVM>(context, listen: false)
        .initVM(widget.channelId, widget.channel);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getTimeStamp(Messages msg) {
    String hour = DateTime.parse(msg.editedAt!).hour.toString();
    String minute = "";
    if (DateTime.parse(msg.editedAt!).minute > 9) {
      minute = DateTime.parse(msg.editedAt!).minute.toString();
    } else {
      minute = "0${DateTime.parse(msg.editedAt!).minute}";
    }
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageVM>(builder: (context, vm, _) {
      return vm.amityMessageList == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: widget.theme.highlightColor,
                        color: Provider.of<AmityUIConfiguration>(context)
                            .primaryColor,
                      )
                    ],
                  ),
                )
              ],
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: vm.amityMessageList?.length,
                itemBuilder: (context, index) {
                  var data = vm.amityMessageList![index].data;
                  log(data!.text.toString());
                  bool isSendbyCurrentUser =
                      vm.amityMessageList?[index].userId !=
                          AmityCoreClient.getCurrentUser().userId;
                  return Column(
                    crossAxisAlignment: isSendbyCurrentUser
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: isSendbyCurrentUser
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        children: [
                          if (!isSendbyCurrentUser)
                            Text(
                              getTimeStamp(vm.amityMessageList![index]),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 8),
                            ),
                          vm.amityMessageList![index].data!.text == null
                              ? Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.red),
                                  child: const Text("Unsupport type message😰",
                                      style: TextStyle(color: Colors.white)),
                                )
                              : Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            widget.mediaQuery.size.width * 0.7),
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 4, 10, 4),
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isSendbyCurrentUser
                                          ? const Color(0xfff1f1f1)
                                          : Provider.of<AmityUIConfiguration>(
                                                  context)
                                              .primaryColor,
                                    ),
                                    child: Text(
                                      vm.amityMessageList?[index].data!.text ??
                                          "N/A",
                                      style: widget.theme.textTheme.bodyText1!
                                          .copyWith(
                                              fontSize: 14.7,
                                              color: isSendbyCurrentUser
                                                  ? Colors.black
                                                  : Colors.white),
                                    ),
                                  ),
                                ),
                          if (isSendbyCurrentUser)
                            Text(
                              getTimeStamp(vm.amityMessageList![index]),
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 8),
                            ),
                        ],
                      ),
                      if (index + 1 == vm.amityMessageList?.length)
                        const SizedBox(
                          height: 90,
                        )
                    ],
                  );
                },
              ),
            );
    });
  }
}
