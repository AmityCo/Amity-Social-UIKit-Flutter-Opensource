import 'package:amity_uikit_beta_service/components/custom_user_avatar.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/general_component.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/user_feed_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Custom Widget that mimics ListTile but without padding
class CustomListTile extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final DateTime createdAt;
  final DateTime editedAt;
  final String userId;
  final dynamic user; // Replace 'dynamic' with your actual User class

  const CustomListTile({
    Key? key,
    required this.avatarUrl,
    required this.displayName,
    required this.createdAt,
    required this.editedAt,
    required this.userId,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) =>
                UserFeedVM(), // Assuming UserFeedVM is your ViewModel
            child: UserProfileScreen(
              amityUserId: userId,
              amityUser: user,
            ),
          ),
        ));
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 2, top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) =>
                        UserFeedVM(), // Assuming UserFeedVM is your ViewModel
                    child: UserProfileScreen(
                      amityUserId: userId,
                      amityUser: user,
                    ),
                  ),
                ));
              },
              child: GestureDetector(child: getAvatarImage(avatarUrl)
                  // If avatarUrl can be null, consider handling it with a placeholder image
                  ),
            ),
            const SizedBox(width: 10), // Space between the avatar and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TimeAgoWidget(
                        createdAt: createdAt == editedAt ? createdAt : editedAt,
                      ),
                      if (createdAt != editedAt) ...[
                        const SizedBox(width: 5),
                        const Icon(Icons.circle, size: 5),
                        const SizedBox(width: 5),
                        const Text("Edited"),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
