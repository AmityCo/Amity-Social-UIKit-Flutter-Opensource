import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

class StoryCommentSettingPage extends StatefulWidget {
  final AmityCommunity community;

  const StoryCommentSettingPage({Key? key, required this.community}) : super(key: key);

  @override
  _StoryCommentSettingPageState createState() => _StoryCommentSettingPageState();
}

class _StoryCommentSettingPageState extends State<StoryCommentSettingPage> {
  bool isStoryCommentEnabled = false;
  @override
  void initState() {
    // TODO: implement initState
    isStoryCommentEnabled = widget.community.allowCommentInStory!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final communityVm =
        Provider.of<CommunityVM>(context, listen: false); // Get the ViewModel

    return Scaffold(
      backgroundColor:
          Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
      appBar: AppBar(
        title: const Text(
          'Story comments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // Section 1: Post Review Setting

          ListTile(
            title: const Text(
              'Allow comments on community stories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff292B32),
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Turn on to receive comments on stories in this community.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff636878),
                ),
              ),
            ),
            trailing: Switch(
              activeColor:
                  Provider.of<AmityUIConfiguration>(context).primaryColor,
              value: isStoryCommentEnabled,
              onChanged: (value) {
                setState(() {
                  isStoryCommentEnabled = value;
                  communityVm.configStoryCommentEnabled(
                      communityId: widget.community.communityId!,
                      ispublic: widget.community.isPublic!,
                      isEnabled:
                          isStoryCommentEnabled); // Call the function from the ViewModel when the switch is toggled
                });
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
