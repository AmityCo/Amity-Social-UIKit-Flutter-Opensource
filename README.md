# Amity UIKit for Flutter[Beta Service]


## Usage
Example main.dart

```dart
import 'package:amity_uikit_beta_service/amity_sle_uikit.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/view/chat/chat_friend_tab.dart';
import 'package:amity_uikit_beta_service/view/chat/single_chat_room.dart';
import 'package:amity_uikit_beta_service/view/social/home_following_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();
  AmitySLEUIKit()
      .initUIKit("b3babb0b3a89f4341d31dc1a01091edcd70f8de7b23d697f", "sg");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///Step2: Wrap Material App with AmitySLEProvider and Builder
    return AmitySLEProvider(
      child: Builder(builder: (context2) {

        ///If you want to change color of uikit use the following metgod here
        AmitySLEUIKit().configAmityThemeColor(context2, (config) {
          config.primaryColor = Colors.blue;
        });
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const InitialWidget(),
        );
      }),
    );
  }
}

class InitialWidget extends StatelessWidget {
  const InitialWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///Step 3: login with Amity
                  AmitySLEUIKit().registerDevice(context, "johnwick2");
                },
                child: const Text("Login to Amity"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///Step 4: Navigate To channel List page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AmitySLEChannelScreen(),
                  ));
                },
                child: const Text("Navigate to UIKIT: Channel List page"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  ///4.1: Navigate To channel chat screen page with ChannelId

                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SingleChatRoom(
                      channelId: "Flutter_Flutter",
                    ),
                  ));
                },
                child: const Text("Navigate to UIKIT: Chat room page"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  ///4.e: Navigate To Global Feed Screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const Scaffold(body: GlobalFeedScreen()),
                  ));
                },
                child: const Text("Navigate to UIKIT: Global Feed"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

```


