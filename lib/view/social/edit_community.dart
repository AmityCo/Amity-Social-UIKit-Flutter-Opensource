import 'package:amity_sdk/amity_sdk.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/custom_user_avatar.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../viewmodel/community_viewmodel.dart';
import '../../viewmodel/configuration_viewmodel.dart';
import '../../viewmodel/custom_image_picker.dart';
import '../UIKit/social/category_list.dart';

class EditCommunityScreen extends StatefulWidget {
  final AmityCommunity community;
  const EditCommunityScreen(this.community, {super.key});
  @override
  EditCommunityScreenState createState() => EditCommunityScreenState();
}

class EditCommunityScreenState extends State<EditCommunityScreen> {
  CommunityType communityType = CommunityType.public;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    // Provider.of<CommunityVM>(context, listen: false)
    //     .getUser(AmityCoreClient.getCurrentUser());

    _displayNameController.text = widget.community.displayName ?? "";
    _descriptionController.text = widget.community.description ?? "";
    _categoryController.text = "null";
    communityType = widget.community.isPublic!
        ? CommunityType.public
        : CommunityType.private;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final myAppBar = AppBar(
      title: Text(
        "Edit Community",
        style: theme.textTheme.titleLarge,
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
      ),
      elevation: 0,
      actions: [
        TextButton(
          onPressed: () async {
            await Provider.of<CommunityVM>(context, listen: false)
                .updateCommunity(
                    widget.community.communityId ?? "",
                    widget.community.avatarImage,
                    _displayNameController.text,
                    _descriptionController.text,
                    Provider.of<CategoryVM>(context, listen: false)
                        .getSelectedCategory(),
                    communityType == CommunityType.public ? true : false);
          },
          child: Text(
            "Save",
            style: theme.textTheme.labelLarge!.copyWith(
                color: Provider.of<AmityUIConfiguration>(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
    final bheight = mediaQuery.size.height -
        mediaQuery.padding.top -
        myAppBar.preferredSize.height;
    return Consumer<CommunityVM>(builder: (context, vm, _) {
      return Scaffold(
        appBar: myAppBar,
        body: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
          child: Container(
            color: Colors.white,
            height: bheight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Provider.of<ImagePickerVM>(context, listen: false)
                                  .showBottomSheet(context);
                            },
                            child: FadedScaleAnimation(
                                child: CircleAvatar(
                              radius: 50,
                              backgroundImage: getImageProvider(
                                  widget.community.avatarImage?.fileUrl),
                            ))),
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
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        alignment: Alignment.centerLeft,
                        color: Colors.grey[200],
                        width: double.infinity,
                        child: Text(
                          "Community Info",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Container(
                      //   color: Colors.white,
                      //   width: double.infinity,
                      //   padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //   child: TextField(
                      //     enabled: false,
                      //     controller:
                      //         TextEditingController(text: ""),//vm.amityUser.userId),
                      //     decoration: InputDecoration(
                      //       labelText: "Community Name",
                      //       labelStyle: TextStyle(height: 1),
                      //       border: InputBorder.none,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            alignLabelWithHint: false,
                            border: InputBorder.none,
                            labelStyle: TextStyle(height: 1),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Description",
                            alignLabelWithHint: false,
                            border: InputBorder.none,
                            labelStyle: TextStyle(height: 1),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          controller: _categoryController,
                          readOnly: true,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CategoryList(
                                    community: widget.community,
                                    categoryTextController:
                                        _categoryController)));
                          },
                          decoration: const InputDecoration(
                            labelText: "Category",
                            alignLabelWithHint: false,
                            border: InputBorder.none,
                            labelStyle: TextStyle(height: 1),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[200],
                        thickness: 3,
                      ),
                      Column(
                        children: [
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.public),
                            ),
                            title: const Text('Public'),
                            subtitle: const Text(
                                'Anyone can join, view and search this community'),
                            trailing: Radio(
                              value: CommunityType.public,
                              activeColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .primaryColor,
                              groupValue: communityType,
                              onChanged: (CommunityType? value) {
                                setState(() {
                                  communityType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.lock),
                            ),
                            title: const Text('Private'),
                            subtitle: const Text(
                                'Only members invited by the moderators can join, view and search this community'),
                            trailing: Radio(
                              value: CommunityType.private,
                              activeColor:
                                  Provider.of<AmityUIConfiguration>(context)
                                      .primaryColor,
                              groupValue: communityType,
                              onChanged: (CommunityType? value) {
                                setState(() {
                                  communityType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
