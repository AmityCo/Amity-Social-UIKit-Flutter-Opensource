import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/viewmodel/community_viewmodel.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

class PostReviewPage extends StatefulWidget {
  final AmityCommunity community;

  const PostReviewPage({Key? key, required this.community}) : super(key: key);

  @override
  _PostReviewPageState createState() => _PostReviewPageState();
}

class _PostReviewPageState extends State<PostReviewPage> {
  bool isPostReviewEnabled = false;
  @override
  void initState() {
    // TODO: implement initState
    isPostReviewEnabled = widget.community.isPostReviewEnabled!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final communityVm =
        Provider.of<CommunityVM>(context, listen: false); // Get the ViewModel

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Review',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          // Section 1: Post Review Setting

          ListTile(
            title: const Text(
              'Approve Member Posts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff292B32),
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Posts by members have to be reviewed and approved by community moderators.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff636878),
                ),
              ),
            ),
            trailing: Switch(
              activeColor:
                  Provider.of<AmityUIConfiguration>(context).primaryColor,
              value: isPostReviewEnabled,
              onChanged: (value) {
                setState(() {
                  isPostReviewEnabled = value;
                  communityVm.configPostReview(
                      communityId: widget.community.communityId!,
                      ispublic: widget.community.isPublic!,
                      isEnabled:
                          isPostReviewEnabled); // Call the function from the ViewModel when the switch is toggled
                });
              },
              // activeColor: Color(0xff292B32),
              // inactiveThumbColor: Color(0xff636878),
              // inactiveTrackColor: Color(0xffEBECEF),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
