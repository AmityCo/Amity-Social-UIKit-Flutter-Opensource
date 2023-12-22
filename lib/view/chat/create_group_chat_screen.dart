import 'dart:developer';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animations/faded_scale_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/channel_list_viewmodel.dart';
import '../../viewmodel/channel_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/custom_image_picker.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../components/custom_user_avatar.dart';

import 'chat_screen.dart';

class CreateChatGroup extends StatefulWidget {
  const CreateChatGroup({
    Key? key,
    required this.userIds,
  }) : super(key: key);

  final List<String> userIds;

  @override
  CreateChatGroupState createState() => CreateChatGroupState();
}

class CreateChatGroupState extends State<CreateChatGroup> {
  String displayName = "";
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<UserVM>(context, listen: false).getUsers();
    });
  }

  Future<void> onCreateTap() async {
    Provider.of<UserVM>(context, listen: false)
        .selectedUserList
        .add(AmityCoreClient.getUserId());
    log("check user id list ${Provider.of<UserVM>(context, listen: false).selectedUserList}");
    Provider.of<ChannelVM>(context, listen: false).createGroupChannel(
        displayName,
        Provider.of<UserVM>(context, listen: false).selectedUserList,
        (channel, error) {
      Provider.of<UserVM>(context, listen: false).clearSelectedUser();
      if (channel != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) => MessageVM(),
                  child: ChatSingleScreen(
                    key: UniqueKey(),
                    channel: channel.channels![0],
                  ),
                )));
      }
    },
        avatarFileId: Provider.of<ImagePickerVM>(context, listen: false)
            .amityImage
            ?.fileId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserVM>(builder: (context, vm, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Setup group",
                style: TextStyle(color: Colors.black)),
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child:
                  const Icon(Icons.chevron_left, color: Colors.black, size: 35),
            ),
            actions: [
              displayName != ""
                  ? TextButton(
                      onPressed: () {
                        onCreateTap();
                      },
                      child: const Text("Create"),
                    )
                  : Container()
            ],
          ),
          body: SafeArea(
              child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                width: double.infinity,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    FadedScaleAnimation(
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<ImagePickerVM>(context, listen: false)
                              .showBottomSheet(context);
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              Provider.of<ImagePickerVM>(context, listen: true)
                                          .amityImage !=
                                      null
                                  ? NetworkImage(Provider.of<ImagePickerVM>(
                                          context,
                                          listen: false)
                                      .amityImage!
                                      .fileUrl!)
                                  : getImageProvider(null),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Provider.of<AmityUIConfiguration>(context)
                              .primaryColor,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      displayName = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Group name",
                    alignLabelWithHint: false,
                    border: InputBorder.none,
                    labelStyle: TextStyle(height: 1),
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 3,
              ),
            ],
          )));
    });
  }
}
