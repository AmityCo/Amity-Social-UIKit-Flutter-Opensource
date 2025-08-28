import 'dart:developer';

import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/utils/navigation_key.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/chat_home_page.dart';
import 'package:amity_uikit_beta_service/v4/social/comment/comment_tray_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/community_membership_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/globalfeed/global_feed_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/post_content_component_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/pending_requests/user_pending_follow_request_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user/follow/user_relationship_page_behavior.dart';
import 'package:amity_uikit_beta_service/v4/social/user_search_result/user_search_result_behavior.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/explore_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:amity_uikit_beta_service_example/sample_v4.dart';
import 'package:amity_uikit_beta_service_example/social_v4_compatible.dart';
import 'package:amity_uikit_beta_service_example/splash_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> camera = <CameraDescription>[];
void main() async {
  ///Step 1: Initialize amity SDK with the following function
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  // options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> MyAppNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // textTheme: GoogleFonts.almendraDisplayTextTheme(),
          ),
      title: 'Flutter Demo',
      navigatorKey: MyAppNavigatorKey,
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _apiKey = TextEditingController();
  AmityEndpointRegion? _selectedRegion;
  final TextEditingController _customHttpUrl = TextEditingController();
  final TextEditingController _customSocketUrl = TextEditingController();
  final TextEditingController _customMqttUrl = TextEditingController();
  final TextEditingController _customUploadUrl = TextEditingController();
  @override
  void initState() {
    _customHttpUrl.text = "https://api.staging.amity.co/";
    _customSocketUrl.text = "https://api.staging.amity.co/";
    _customUploadUrl.text = "https://upload.staging.amity.co/";
    _customMqttUrl.text = "ssq.staging.amity.co";
    _apiKey.text = "b0efe90c3bdda2304d628918520c1688845889e4bc363d2c";
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey.text = prefs.getString('apiKey') ?? "";

      String? selectedRegionString = prefs.getString('selectedRegion');
      if (selectedRegionString != null) {
        _selectedRegion = AmityEndpointRegion.values.firstWhere(
          (e) => e.toString() == selectedRegionString,
          orElse: () => AmityEndpointRegion.sg,
        );
      }
      if (_selectedRegion == AmityEndpointRegion.custom) {
        _customHttpUrl.text = prefs.getString('customUrl') ?? "";
        _customSocketUrl.text = prefs.getString('customSocketUrl') ?? "";
        _customMqttUrl.text = prefs.getString('customMqttUrl') ?? "";
        _customUploadUrl.text = prefs.getString('customUploadUrl') ?? "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _apiKey,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select Region:'),
            ...AmityEndpointRegion.values.map((region) {
              return RadioListTile<AmityEndpointRegion>(
                title: Text(region.toString().split('.').last.toUpperCase()),
                value: region,
                groupValue: _selectedRegion,
                onChanged: (AmityEndpointRegion? value) {
                  setState(() {
                    _selectedRegion = value;
                    if (value != AmityEndpointRegion.custom) {
                      // Reset custom URL
                      _customHttpUrl.text = "";
                      _customSocketUrl.text = "";
                      _customHttpUrl.text = "";
                    }
                  });
                },
              );
            }).toList(),
            if (_selectedRegion == AmityEndpointRegion.custom) ...[
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Custom HTTP URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customHttpUrl,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Custom Socket URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customSocketUrl,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Custom MQTT URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customMqttUrl,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Custom upload URL',
                  border: OutlineInputBorder(),
                ),
                controller: _customUploadUrl,
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
                child: const Text('Initialize'),
                onPressed: () async {
                  if (_selectedRegion != null) {
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setString('apiKey', _apiKey.text);
                    await prefs.setString(
                        'selectedRegion', _selectedRegion.toString());

                    if (_selectedRegion == AmityEndpointRegion.custom) {
                      await prefs.setString('customUrl', _customHttpUrl.text);
                      await prefs.setString(
                          'customSocketUrl', _customSocketUrl.text);
                      await prefs.setString(
                          'customMqttUrl', _customMqttUrl.text);
                      await prefs.setString(
                          'customUploadUrl', _customUploadUrl.text);
                    }
                    log("save pref");

                    await AmityUIKit().setup(
                      apikey: _apiKey.text,
                      region: _selectedRegion!,
                      customEndpoint: _customHttpUrl.text,
                      customSocketEndpoint: _customSocketUrl.text,
                      customMqttEndpoint: _customMqttUrl.text,
                      customUploadEndpoint: _customUploadUrl.text,
                    );
                    // Navigate to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AmityApp()),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class AmityApp extends StatelessWidget {
  const AmityApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AmityUIKitProvider(
      child: Builder(builder: (context2) {
        return const UserListPage();
      }),
    );
  }

  void applyCustomBehavior() {
    AmityUIKit4Manager.behavior.postContentComponentBehavior = CustomPostContentComponentBehavior();
    AmityUIKit4Manager.behavior.globalFeedComponentBehavior = CustomGlobalFeedComponentBehavior();
    AmityUIKit4Manager.behavior.commentTrayBehavior = CustomCommentTrayBehavior();
    AmityUIKit4Manager.behavior.communityMembershipPageBehavior = CustomCommunityMembershipPageBehavior();
    AmityUIKit4Manager.behavior.userSearchResultBehavior = CustomUserSearchResultBehavior();
    AmityUIKit4Manager.behavior.userPendingFollowRequestsPageBehavior = CustomUserPendingFollowRequestsPageBehavior();
    AmityUIKit4Manager.behavior.userRelationshipPageBehavior = CustomUserRelationshipPageBehavior();
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<String> _usernames = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadUsernames();
  }

  _checkSession() async {
    AmityUIKit().observeSessionState().listen((event) {
      if (event == SessionState.Established) {
        final username = AmityUIKit().getCurrentUser().displayName ??
            AmityUIKit().getCurrentUser().userId ??
            "";
        NavigationService.navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
              builder: (context) => SecondPage(username: username)),
        );
      }
    });
  }

  _loadUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernames = prefs.getStringList('usernames') ?? [];
    });
  }

  _addUsername() async {
    if (_controller.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _usernames.add(_controller.text);
      prefs.setStringList('usernames', _usernames);
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              MyAppNavigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addUsername,
            child: const Text('Add Username'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_usernames[index]),
                  onLongPress: () async {
                    ///Step 3: login with Amity
                    await AmityUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      // authToken: "4c0e41077975e7c477d0db50673c95731d24ebbb",
                      callback: (isSuccess, error) {
                        if (isSuccess) {
                          //ignore call back
                        } else {
                          AmityDialog().showAlertErrorDialog(
                              title: "Error", message: error.toString());
                        }
                      },
                    );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const Scaffold(body: CommunityPage()),
                    ));
                  },
                  onTap: () async {
                    ///Step 3: login with Amity
                    await AmityUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      // authToken: "4c0e41077975e7c477d0db50673c95731d24ebbb",
                      callback: (isSuccess, error) {
                        if (isSuccess) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SecondPage(username: _usernames[index]),
                            ),
                          );
                        } else {
                          AmityDialog().showAlertErrorDialog(
                              title: "Error", message: error.toString());
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key, required this.username});
  final String username;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            AmityUIKit().unRegisterDevice();
            MyAppNavigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
        ),
        title: Text('Welcome, $username'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SocialPage(username: username),
                  ),
                );
              },
              child: const Text('Social'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(username: username),
                  ),
                );
              },
              child: const Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class SocialPage extends StatelessWidget {
  const SocialPage({super.key, required this.username});
  final String username;
  void showColorPickerDialog(BuildContext sourceContext) {
    Color primary = Colors.red;
    Color base = Colors.red;
    Color baseBackground = Colors.red;
    Color baseShade4 = Colors.red;
    AmityUIKit().configAmityThemeColor(sourceContext, (config) {
      primary = config.appColors.primary;
      base = config.appColors.base;
      baseBackground = config.appColors.baseBackground;
      baseShade4 = config.appColors.baseShade4;
    });
    showDialog(
        context: sourceContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select a Color'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      const Text("primary color"),
                      ColorPicker(
                        displayThumbColor: false,
                        showLabel: false,
                        pickerColor: primary,
                        onColorChanged: (Color color) {
                          primary = color;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("base color"),
                      ColorPicker(
                        displayThumbColor: false,
                        showLabel: false,
                        pickerColor: base,
                        onColorChanged: (Color color) {
                          base = color;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("baseBackground color"),
                      ColorPicker(
                        displayThumbColor: false,
                        showLabel: false,
                        pickerColor: baseBackground,
                        onColorChanged: (Color color) {
                          baseBackground = color;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("baseShade4 color"),
                      ColorPicker(
                        displayThumbColor: false,
                        showLabel: false,
                        pickerColor: baseShade4,
                        onColorChanged: (Color color) {
                          baseShade4 = color;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Select'),
                onPressed: () {
                  Navigator.of(context).pop();
                  AppColors appColors = AppColors(
                      primary: primary,
                      // primaryShade3: Colors.red,
                      base: base,
                      baseBackground: baseBackground,
                      baseShade4: baseShade4);
                  configThemeColor(sourceContext, appColors);
                },
              ),
            ],
          );
        });
  }

  void configThemeColor(BuildContext context, AppColors appColors) {
    // Place your AmitySLEUIKit configuration code here
    // For demonstration, the primary color is being used. Adapt as needed.
    AmityUIKit().configAmityThemeColor(context, (config) {
      config.appColors = appColors;
    });

    // Show a simple snackbar to confirm the color has been set
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme color set to $appColors'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        actions: [
          TextButton(
              onPressed: () {
                showColorPickerDialog(context);
              },
              child: const Text("config"))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Register push notification'),
              onTap: () async {},
            ),
            ListTile(
              title: const Text('unregister'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                AmityUIKit().unRegisterDevice();
              },
            ),
            ListTile(
              title: const Text('Custom Post Ranking Feed'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(
                      body: GlobalFeedScreen(
                          //isCustomPostRanking: true,
                          )),
                ));
              },
            ),
            ListTile(
              title: const Text('User Profile'),
              onTap: () {
                // Navigate or perform action based on 'User Profile' tap
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                          amityUserId: username,
                          amityUser: null,
                        )));
              },
            ),
            ListTile(
              title: const Text('Newsfeed'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
              },
            ),
            ListTile(
              title: const Text('Create Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const Scaffold(body: CreateCommunityPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('Create Post'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(body: PostToPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('My Community'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: MyCommunityPage(
                        canCreateCommunity: false,
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Explore'),
              onTap: () {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(body: CommunityPage()),
                ));
              },
            ),
            ListTile(
              title: const Text('Version 4'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SampleV4(),
                ));
              },
            ),
            ListTile(
              title: const Text('Community v4 compatible'),
              onTap: () {
                // Navigate or perform action based on 'Global Feed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AmitySocialV4Compatible(),
                ));
              },
            ),
            ListTile(
              title: const Text('Bitazza Me Page (Custom)'),
              onTap: () {
                // Navigate to custom Bitazza Me Page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BitazzaMePage(
                    userId: username,
                    avatar: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    avatarUrl: null,
                    rarity: "Epic",
                  ),
                ));
              },
            ),
            const ListTile(),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: const Text('Chat V4'),
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: AmityChatHomePage(),
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPostContentComponentBehavior extends AmityPostContentComponentBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomGlobalFeedComponentBehavior extends AmityGlobalFeedComponentBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomCommentTrayBehavior extends AmityCommentTrayBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomCommunityMembershipPageBehavior extends AmityCommunityMembershipPageBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomUserSearchResultBehavior extends AmityUserSearchResultBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomUserPendingFollowRequestsPageBehavior extends AmityUserPendingFollowRequestsPageBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

class CustomUserRelationshipPageBehavior extends AmityUserRelationshipPageBehavior {
  @override
  void goToUserProfilePage(BuildContext context, String userId) {
    // Override the default behavior to navigate to a custom user profile page
  }
}

