import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/components/custom_textfield.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/category_list.dart';
import 'package:amity_uikit_beta_service/viewmodel/category_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For using File class

enum CommunityType { public, private }

class AmityEditCommunityScreen extends StatefulWidget {
  final AmityCommunity community;
  const AmityEditCommunityScreen(this.community, {Key? key}) : super(key: key);

  @override
  AmityEditCommunityScreenState createState() =>
      AmityEditCommunityScreenState();
}

class AmityEditCommunityScreenState extends State<AmityEditCommunityScreen> {
  CommunityType communityType = CommunityType.public;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isPublic = true;
  @override
  void initState() {
    super.initState();

    final communityProvider = Provider.of<CommunityVM>(context, listen: false);
    communityProvider.pickedFile = null;
    _displayNameController.text = widget.community.displayName ?? "";
    _descriptionController.text = widget.community.description ?? "";
    var category = widget.community.categories!;
    var categories = widget.community.categories;
    if (categories != null && categories.isNotEmpty) {
      _categoryController.text = categories[0]!.name ?? "No Name";
    } else {
      _categoryController.text = "No Category";
    }
    communityType = widget.community.isPublic!
        ? CommunityType.public
        : CommunityType.private;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmityCommunity>(
        stream: widget.community.listen.stream,
        builder: (context, snapshot) {
          var community = snapshot.data ?? widget.community;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Edit Community",
                style:
                    Provider.of<AmityUIConfiguration>(context).titleTextStyle,
              ),
              backgroundColor: Colors.white,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left,
                    color: Colors.black, size: 30),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    AmityLoadingDialog.showLoadingDialog();
                    var imageProvider =
                        Provider.of<CommunityVM>(context, listen: false);
                    await imageProvider.uploadSelectedFileToAmity();
                    await Provider.of<CommunityVM>(context, listen: false)
                        .updateCommunity(
                            community.communityId ?? "",
                            imageProvider.amityImages ?? community.avatarImage,
                            _displayNameController.text,
                            _descriptionController.text,
                            Provider.of<CategoryVM>(context, listen: false)
                                .getSelectedCategory(),
                            communityType == CommunityType.public
                                ? true
                                : false);
                    AmityLoadingDialog.hideLoadingDialog();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      Provider.of<CommunityVM>(context, listen: false)
                          .selectFile();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                              color: const Color(0xFFD9E5FC),
                              image: DecorationImage(
                                image: getCustomImageProvider(widget
                                    .community.avatarImage
                                    ?.getUrl(AmityImageSize.LARGE)),
                                fit: BoxFit.cover,
                              )),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                  0.4), // Applying a 40% dark filter to the entire container
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(
                                5.0), // Adding rounded corners
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize
                                .min, // Making the row only as wide as the children need
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ), // Adding a camera icon
                              SizedBox(
                                  width:
                                      8.0), // Adding some space between the icon and the text
                              Text(
                                'Upload image',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        TextFieldWithCounter(
                          controller: _displayNameController,
                          title: 'Community name',
                          hintText: 'Name your community',
                          maxCharacters: 30,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWithCounter(
                          isRequired: false,
                          controller: _descriptionController,
                          title: 'About',
                          hintText: 'Enter description',
                          maxCharacters: 180,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWithCounter(
                          controller: _categoryController,
                          title: 'Category',
                          hintText: 'Select category',
                          showCount: false,
                          maxCharacters: 30,
                          onTap: () async {
                            String? category =
                                await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                  builder: (context) => CategoryList(
                                        categoryTextController:
                                            _categoryController,
                                      )),
                            );
                            if (category != null) {
                              _categoryController.text = category;
                            }
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.public),
                              ),
                              title: const Text('Public'),
                              subtitle: const Text(
                                  'Anyone can join, view and search this community'),
                              trailing: Radio(
                                value: true,
                                groupValue: _isPublic,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPublic = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.lock),
                              ),
                              title: const Text('Private'),
                              subtitle: const Text(
                                  'Only members invited by the moderators can join, view and search this community'),
                              trailing: Radio(
                                value: true,
                                groupValue: !_isPublic,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPublic = !value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  getCustomImageProvider(String? url) {
    var imageProvider = Provider.of<CommunityVM>(context, listen: true);

    if ((imageProvider.pickedFile != null)) {
      return FileImage(Provider.of<CommunityVM>(context).pickedFile!);
    }
    if (url != null) {
      return NetworkImage(url);
    } else {
      return const AssetImage("assets/images/IMG_5637.JPG",
          package: 'amity_uikit_beta_service');
    }
  }
}
