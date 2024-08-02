import 'dart:developer';

import 'package:amity_uikit_beta_service/amity_uikit.dart';
import 'package:amity_uikit_beta_service/components/alert_dialog.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/create_community_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/explore_page.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/my_community_feed.dart';
import 'package:amity_uikit_beta_service/view/UIKit/social/post_target_page.dart';
import 'package:amity_uikit_beta_service/view/chat/UIKit/chat_room_page.dart';
import 'package:amity_uikit_beta_service/view/social/global_feed.dart';
import 'package:amity_uikit_beta_service/view/user/user_profile_v2.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:camera/camera.dart';
import 'package:amity_uikit_beta_service_example/sample_v4.dart';
import 'package:amity_uikit_beta_service_example/social_v4_compatible.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          // textTheme: GoogleFonts.almendraDisplayTextTheme(),
          ),
      title: 'Flutter Demo',
      home: const MyHomePage(),
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
  @override
  void initState() {
    _customHttpUrl.text = "https://api.staging.amity.co/";
    _customSocketUrl.text = "https://api.staging.amity.co/";
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
                    }
                    log("save pref");

                    await AmityUIKit().setup(
                      apikey: _apiKey.text,
                      region: _selectedRegion!,
                      customEndpoint: _customHttpUrl.text,
                      customSocketEndpoint: _customSocketUrl.text,
                      customMqttEndpoint: _customMqttUrl.text,
                    );
                    // Navigate to the nextx page
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
    _loadUsernames();
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
                    log("login");

                    ///Step 3: login with Amity
                    await AmityUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      authToken: "4c0e41077975e7c477d0db50673c95731d24ebbb",
                      callback: (isSuccess, error) {
                        log("callback:$isSuccess");
                        if (isSuccess) {
                          log("success");
                          //ignore call back
                        } else {
                          log("fail");
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
                    log("login");

                    ///Step 3: login with Amity
                    await AmityUIKit().registerDevice(
                      context: context,
                      userId: _usernames[index],
                      authToken: "4c0e41077975e7c477d0db50673c95731d24ebbb",
                      callback: (isSuccess, error) {
                        log("callback:$isSuccess");
                        if (isSuccess) {
                          log("success");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  SecondPage(username: _usernames[index]),
                            ),
                          );
                        } else {
                          log("fail");
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
    print("configThemeColor");
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
              title: const Text('Single Chat Room'),
              onTap: () async {
                // Navigate or perform action based on 'Newsfeed' tap
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Scaffold(
                      body: ChatRoomPage(
                    channelId: "65e6d0765b88b140f2e505ae",
                  )),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
