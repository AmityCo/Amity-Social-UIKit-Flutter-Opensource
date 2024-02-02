import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/category_list.dart';
import 'package:amity_uikit_beta_service/view/social/select_user_page.dart';
import 'package:amity_uikit_beta_service/viewmodel/category_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum CommunityListType { my, recommend, trending }

enum CommunityFeedMenuOption { edit, members }

enum CommunityType { public, private }

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  CommunityType communityType = CommunityType.public;
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserVM>(context, listen: false);
    final communityProvider = Provider.of<CommunityVM>(context, listen: false);
    final categoryVM = Provider.of<CategoryVM>(context, listen: false);
    communityProvider.pickedFile = null;
    categoryVM.clear();
    userProvider.initUserList("");
    userProvider.clearselectedCommunityUsers();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Create community',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: Provider.of<CommunityVM>(context, listen: false).addFile,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9E5FC),
                      image: Provider.of<CommunityVM>(context).pickedFile !=
                              null
                          ? DecorationImage(
                              image: FileImage(Provider.of<CommunityVM>(context)
                                  .pickedFile!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("assets/images/IMG_5637.JPG",
                                  package: 'amity_uikit_beta_service'),
                              fit: BoxFit.cover),
                    ),
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
                      borderRadius:
                          BorderRadius.circular(5.0), // Adding rounded corners
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
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextFieldWithCounter(
                    controller: _communityNameController,
                    title: 'Community name',
                    hintText: 'Name your community',
                    maxCharacters: 30,
                  ),
                  const SizedBox(height: 16.0),
                  buildTextFieldWithCounter(
                    isRequred: false,
                    controller: _aboutController,
                    title: 'About',
                    hintText: 'Enter description',
                    maxCharacters: 180,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  const SizedBox(height: 16.0),
                  buildTextFieldWithCounter(
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
                                  categoryTextController: _categoryController,
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
                              color: Colors.grey[200], shape: BoxShape.circle),
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
                              color: Colors.grey[200], shape: BoxShape.circle),
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
                  _isPublic
                      ? Container()
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'Add members',
                                  style: Provider.of<AmityUIConfiguration>(
                                          context,
                                          listen: false)
                                      .titleTextStyle,
                                  children: const [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const MemberSection()
                            ],
                          ),
                        )
                ],
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    // Collect necessary data
                    final name = _communityNameController.text;
                    final description = _aboutController.text;
                    final imageAvatar =
                        Provider.of<CommunityVM>(context, listen: false)
                            .amityImages;

                    final isPublic = _isPublic;
                    final categoryId =
                        Provider.of<CategoryVM>(context, listen: false)
                            .getSelectedCategory();
                    final List<String> userIds = [];
                    for (var user in Provider.of<UserVM>(context, listen: false)
                        .selectedCommunityUsers) {
                      userIds.add(user.userId!);
                    }

                    // Call the createCommunity method from your ViewModel
                    await Provider.of<CommunityVM>(context, listen: false)
                        .createCommunity(
                      context: context,
                      name: name,
                      description: description,
                      avatar: imageAvatar,
                      categoryIds: categoryId,
                      isPublic: isPublic,
                      userIds: userIds,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Provider.of<AmityUIConfiguration>(context,
                            listen: false)
                        .primaryColor,
                    minimumSize: const Size(10, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the icon and text in the row
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ), // Plus icon
                      SizedBox(width: 10), // Space between icon and text
                      Text(
                        'Create Community',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFieldWithCounter({
    required TextEditingController controller,
    required String title,
    required String hintText,
    required int maxCharacters,
    bool showCount = true,
    bool isRequred = true,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines,
    void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: title,
                style: Provider.of<AmityUIConfiguration>(context, listen: false)
                    .titleTextStyle,
                children: [
                  TextSpan(
                    text: isRequred ? ' *' : "",
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            showCount
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0), // Adding vertical padding for symmetry
                    child: Text(
                      '${controller.text.length}/$maxCharacters',
                      style: const TextStyle(
                          fontSize: 13.4), // Setting font size to 13.4
                    ),
                  )
                : Container(), // Updated here to show the current character count
          ],
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none, // This line removes the underline
            hintText: hintText,
            counterText:
                "", // Added this line to remove the counter below the TextField
          ),
          maxLength: maxCharacters,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          readOnly: onTap != null,
          onChanged: (text) {
            // Added onChanged to update the UI whenever the text changes
            setState(() {});
          },
        ),
        Divider(
          color: Colors.grey[200],
          thickness: 1,
        ),
      ],
    );
  }
}

class MemberSection extends StatelessWidget {
  const MemberSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: [
        // Insert selected user chips here
        for (var user in Provider.of<UserVM>(context).selectedCommunityUsers)
          Chip(
            backgroundColor: Colors.grey[280],
            avatar: CircleAvatar(
              backgroundColor: const Color(0xFFD9E5FC),
              backgroundImage:
                  user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
              child: user.avatarUrl != null
                  ? null
                  : const Icon(Icons.person,
                      size: 13,
                      color: Colors
                          .white), // Adjust to use the correct attribute for avatar URL
            ),

            label: Text(user.displayName ??
                ""), // Display user's name, replace 'name' with the appropriate attribute for the user's name
            onDeleted: () {
              // Handle the logic to remove the user when "X" is tapped
              Provider.of<UserVM>(context, listen: false)
                  .toggleUserSelection(user);
            },
            deleteIcon: const Icon(Icons.close),
            deleteIconColor: Colors.black54,
          ),
        GestureDetector(
          onTap: () async {
            // Navigate to the user list page and update the selected users
            await Navigator.of(context).push<List<AmityUser>>(
                MaterialPageRoute(builder: (context) => const UserListPage()));
          },
          child: Container(
            height: 40,
            width: 40,
            decoration:
                BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
