import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/channel_list_viewmodel.dart';
import '../../viewmodel/channel_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import 'chat_screen.dart';

class ChatItems {
  String image;
  String name;

  ChatItems(this.image, this.name);
}

class AmitySLEChannelScreen extends StatefulWidget {
  const AmitySLEChannelScreen({Key? key}) : super(key: key);

  @override
  AmitySLEChannelScreenState createState() => AmitySLEChannelScreenState();
}

class AmitySLEChannelScreenState extends State<AmitySLEChannelScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if (Provider.of<UserVM>(context, listen: false).accessToken == "") {
        await Provider.of<UserVM>(context, listen: false).initAccessToken();
      } else {
        Provider.of<UserVM>(context, listen: false).accessToken;
      }
      // ignore: use_build_context_synchronously
      Provider.of<ChannelVM>(context, listen: false).initVM();
    });
    super.initState();
  }

  int getLength(ChannelVM vm) {
    return vm.getChannelList().length;
  }

  String getDateTime(String dateTime) {
    var convertedTimestamp =
        DateTime.parse(dateTime); // Converting into [DateTime] object
    var result = GetTimeAgo.parse(
      convertedTimestamp,
    );

    if (result == "0 seconds ago") {
      return "just now";
    } else {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    // final bHeight = mediaQuery.size.height -
    //     mediaQuery.padding.top -
    //     AppBar().preferredSize.height;

    final theme = Theme.of(context);
    return Consumer<ChannelVM>(builder: (context, vm, _) {
      return RefreshIndicator(
        color: Provider.of<AmityUIConfiguration>(context).primaryColor,
        onRefresh: () async {
          await vm.refreshChannels();
        },
        child: Scaffold(
          body: FadedSlideAnimation(
            beginOffset: const Offset(0, 0.3),
            endOffset: const Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .channelListConfig
                        .backgroundColor,
                    margin: const EdgeInsets.only(top: 5),
                    child: ListView.builder(
                      controller: vm.scrollController,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: getLength(vm),
                      itemBuilder: (context, index) {
                        var messageCount =
                            vm.getChannelList()[index].unreadCount;

                        bool rand = messageCount > 0 ? true : false;
                        // if ((Random().nextInt(10)) % 2 == 0) {
                        //   _rand = true;
                        // } else {
                        //   _rand = false;
                        // }
                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                        create: (context) => MessageVM(),
                                        child: ChatSingleScreen(
                                          key: UniqueKey(),
                                          channel: vm.getChannelList()[index],
                                        ),
                                      )));
                            },
                            leading: Stack(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: FadedScaleAnimation(
                                    child: getCommuAvatarImage(null,
                                        fileId: vm
                                            .getChannelList()[index]
                                            .avatarFileId),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: rand
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Provider.of<
                                                        AmityUIConfiguration>(
                                                    context)
                                                .primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 0, 4, 2),
                                          child: Center(
                                            child: Text(
                                              vm
                                                  .getChannelList()[index]
                                                  .unreadCount
                                                  .toString(),
                                              style: theme.textTheme.bodyLarge!
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 8),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                            title: Text(
                              vm.getChannelList()[index].displayName ??
                                  "Display name",
                              style: TextStyle(
                                color: rand
                                    ? Provider.of<AmityUIConfiguration>(context)
                                        .primaryColor
                                    : Provider.of<AmityUIConfiguration>(context)
                                        .channelListConfig
                                        .channelDisplayname,
                                fontSize: 13.3,
                              ),
                            ),
                            subtitle: Text(
                              vm.getChannelList()[index].latestMessage,
                              style: theme.textTheme.titleSmall!.copyWith(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .channelListConfig
                                        .latestMessageColor,
                                fontSize: 10.7,
                              ),
                            ),
                            trailing: Text(
                              (vm.getChannelList()[index].lastActivity == null)
                                  ? ""
                                  : getDateTime(
                                      vm.getChannelList()[index].lastActivity!),
                              style: theme.textTheme.bodyLarge!.copyWith(
                                  color:
                                      Provider.of<AmityUIConfiguration>(context)
                                          .channelListConfig
                                          .latestTimeColor,
                                  fontSize: 9.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   heroTag: 'chat',
          //   child: Icon(Icons.person_add),
          //   backgroundColor:  Provider.of<AmityUIConfiguration>(context)
          //              .primaryColor,
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) => UserList(
          //         UniqueKey(),
          //       ),
          //     ));
          //   },
          // ),
        ),
      );
    });
  }
}
