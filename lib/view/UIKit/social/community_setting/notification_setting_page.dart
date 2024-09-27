import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/components/theme_config.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/notification_setting_comment_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/community_setting/notification_setting_post.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import AmityCommunity here

class NotificationSettingPage extends StatefulWidget {
  // Assuming AmityCommunity has been defined elsewhere in your codebase
  final AmityCommunity community;

  const NotificationSettingPage({Key? key, required this.community})
      : super(key: key);

  @override
  _NotificationSettingPageState createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ThemeConfig(
      child: Scaffold(
        backgroundColor:
            Provider.of<AmityUIConfiguration>(context).appColors.baseBackground,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: Provider.of<AmityUIConfiguration>(context)
                .titleTextStyle
                .copyWith(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xff292B32)),
        ),
        body: ListView(
          children: [
            // Section 1: Allow Notification
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Allow Notification',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .base),
              ),
            ),
            ListTile(
              title: Text(
                  'Turn on to receive push notification from this community',
                  style: TextStyle(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .base)),
              trailing: Switch(
                activeColor: Provider.of<AmityUIConfiguration>(context)
                    .appColors
                    .primary,
                value: isNotificationEnabled,
                onChanged: (value) {
                  setState(() {
                    isNotificationEnabled = value;
                  });
                },
              ),
            ),
            const Divider(),

            // Section 2: Post and Comment

            !isNotificationEnabled
                ? const SizedBox()
                : Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(
                              8), // Adjust padding to your need
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                8), // Adjust radius to your need
                            color: Colors.grey[
                                200], // Choose the color to fit your design
                          ),
                          child: Icon(Icons.newspaper_outlined,
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base),
                        ), // You may want to replace with your icon
                        title: Text('Posts',
                            style: TextStyle(
                                color:
                                    Provider.of<AmityUIConfiguration>(context)
                                        .appColors
                                        .base)),
                        trailing: Icon(Icons.chevron_right,
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base),
                        onTap: () {
                          // Navigate to post settings page
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PostNotificationSettingPage(
                                  community: widget.community)));
                        },
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(
                              8), // Adjust padding to your need
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                4), // Adjust radius to your need
                            color: const Color(
                                0xfff1f1f1), // Choose the color to fit your design
                          ),
                          child: Icon(
                            Icons.chat_bubble_outlined,
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base,
                          ),
                        ), // You may want to replace with your icon
                        title: Text(
                          'Comments',
                          style: TextStyle(
                              color: Provider.of<AmityUIConfiguration>(context)
                                  .appColors
                                  .base),
                        ),
                        trailing: Icon(Icons.chevron_right,
                            color: Provider.of<AmityUIConfiguration>(context)
                                .appColors
                                .base),
                        onTap: () {
                          // Navigate to comment settings page
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CommentsNotificationSettingPage(
                                      community: widget.community)));
                        },
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
