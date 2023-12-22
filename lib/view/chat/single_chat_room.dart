import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/channel_list_viewmodel.dart';
import '../../viewmodel/channel_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import 'chat_screen.dart';

class SingleChatRoom extends StatefulWidget {
  final String channelId;
  const SingleChatRoom({
    super.key,
    required this.channelId,
  });

  @override
  State<SingleChatRoom> createState() => _SingleChatRoomState();
}

class _SingleChatRoomState extends State<SingleChatRoom> {
  @override
  void initState() {
    if (Provider.of<UserVM>(context, listen: false).accessToken == "") {
    } else {}

    Provider.of<ChannelVM>(context, listen: false)
        .initSingleChannel(widget.channelId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<ChannelVM>(context).amitySingleChannel == null
        ? Scaffold(
            body: Row(
              children: [
                Expanded(
                    child: Column(
                  children: const [CircularProgressIndicator()],
                ))
              ],
            ),
          )
        : ChangeNotifierProvider(
            create: (context) => MessageVM(),
            child: ChatSingleScreen(
                key: Key(widget.channelId),
                channel: Provider.of<ChannelVM>(context).amitySingleChannel!),
          );
  }
}
